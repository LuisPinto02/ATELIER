import 'package:flutter_test/flutter_test.dart';
import 'package:atelier/models/furniture_model.dart';
import 'package:atelier/models/workshop_catalog_model.dart';
import 'package:atelier/models/cost_breakdown_model.dart';
import 'package:atelier/models/alert_model.dart';
import 'package:atelier/models/cutting_layout_model.dart';
import 'package:atelier/services/bom_engine.dart';
import 'package:atelier/services/cutting_optimizer.dart';
import 'package:atelier/services/costing_engine.dart';
import 'package:atelier/services/validation_engine.dart';

void main() {
  group('ATELIER - Estado de Resultados, Costeo y Regímenes Tributarios', () {
    late WorkshopCatalog catalog;
    late FurnitureModel closet;
    late BomResult bom;
    late OptimizationResult optimization;

    setUp(() {
      catalog = WorkshopCatalog.defaultCatalog();
      closet = FurnitureModel.fromPreset(FurniturePreset.roperoCloset);
      bom = BomEngine.generateBom(closet, catalog);
      optimization = CuttingOptimizer.optimize(pieces: bom.pieces, catalog: catalog);
    });

    test('Fórmula obligatoria de Margen sobre la Venta: Precio = Costo Total / (1 - M)', () {
      const targetMargin = 30.0; // 30%
      final cost = CostingEngine.calculateCost(
        furniture: closet,
        bom: bom,
        optimization: optimization,
        catalog: catalog,
        targetMarginPercent: targetMargin,
      );

      final expectedPrice = cost.totalCostBs / (1.0 - 0.30);
      expect(cost.grossMarginPriceBs, closeTo(expectedPrice, 0.01));
      expect(cost.activePriceBs, closeTo(expectedPrice, 0.01));
      expect(cost.isManualPriceActive, isFalse);

      // El markup sobre costo (informativo) debe ser estrictamente menor al precio sobre venta
      expect(cost.markupPriceBs, lessThan(cost.grossMarginPriceBs));
    });

    test('Clasificación de Costos Industriales: Producción = MP + MOD + CIF', () {
      final cost = CostingEngine.calculateCost(
        furniture: closet,
        bom: bom,
        optimization: optimization,
        catalog: catalog,
      );

      expect(cost.subtotalDirectMaterialsBs, greaterThan(0));
      expect(cost.subtotalLaborBs, greaterThan(0));
      expect(cost.subtotalCifBs, greaterThan(0));

      final calculatedProdCost = cost.subtotalDirectMaterialsBs + cost.subtotalLaborBs + cost.subtotalCifBs;
      expect(cost.productionCostBs, closeTo(calculatedProdCost, 0.01));

      final calculatedTotalCost = cost.productionCostBs + cost.operatingExpensesBs + cost.financialExpensesBs;
      expect(cost.totalCostBs, closeTo(calculatedTotalCost, 0.01));
    });

    test('Estado de Resultados con Régimen SIETE-RG (5% monotributo sobre ventas brutas)', () {
      final cost = CostingEngine.calculateCost(
        furniture: closet,
        bom: bom,
        optimization: optimization,
        catalog: catalog,
        targetMarginPercent: 30.0,
        taxRegime: BoliviaTaxRegime.sieteRg,
      );

      expect(cost.taxRegime, BoliviaTaxRegime.sieteRg);
      expect(cost.grossRevenueBs, equals(cost.activePriceBs));

      // Utilidad Bruta = Ventas - Costos de Producción
      expect(cost.grossProfitBs, closeTo(cost.grossRevenueBs - cost.productionCostBs, 0.01));

      // Utilidad Operativa = Utilidad Bruta - Gastos Operativos
      expect(cost.operatingProfitBs, closeTo(cost.grossProfitBs - cost.operatingExpensesBs, 0.01));

      // UAI = Utilidad Operativa - Gastos Financieros
      expect(cost.uaiBs, closeTo(cost.operatingProfitBs - cost.financialExpensesBs, 0.01));

      // Impuesto SIETE-RG = 5% sobre ventas brutas
      final expectedSieteRg = cost.grossRevenueBs * 0.05;
      expect(cost.taxSieteRgBs, closeTo(expectedSieteRg, 0.01));
      expect(cost.totalTaxesBs, closeTo(expectedSieteRg, 0.01));

      // Utilidad Neta = UAI - Impuestos
      expect(cost.netProfitBs, closeTo(cost.uaiBs - cost.totalTaxesBs, 0.01));
    });

    test('Estado de Resultados con Régimen General (IVA 13% informativo, IT 3%, IUE 25%)', () {
      final cost = CostingEngine.calculateCost(
        furniture: closet,
        bom: bom,
        optimization: optimization,
        catalog: catalog,
        targetMarginPercent: 35.0,
        taxRegime: BoliviaTaxRegime.general,
      );

      expect(cost.taxRegime, BoliviaTaxRegime.general);

      // IVA 13% informativo
      expect(cost.taxIvaBs, closeTo(cost.grossRevenueBs * 0.13, 0.01));

      // IT 3% sobre ingresos brutos
      final expectedIt = cost.grossRevenueBs * 0.03;
      expect(cost.taxItBs, closeTo(expectedIt, 0.01));

      // Base imponible IUE = max(0, UAI - IT)
      final expectedTaxableBase = (cost.uaiBs - expectedIt) > 0 ? (cost.uaiBs - expectedIt) : 0.0;
      final expectedIue = expectedTaxableBase * 0.25;
      expect(cost.taxIueBs, closeTo(expectedIue, 0.01));

      // Total impuestos deducibles = IT + IUE
      expect(cost.totalTaxesBs, closeTo(expectedIt + expectedIue, 0.01));

      // Utilidad Neta
      expect(cost.netProfitBs, closeTo(cost.uaiBs - cost.totalTaxesBs, 0.01));
    });

    test('Alerta de Margen Crítico (< 20%) y Pérdida con precio manual bajo', () {
      // Simular un precio manual que deja margen menor a 20%
      final costCritical = CostingEngine.calculateCost(
        furniture: closet,
        bom: bom,
        optimization: optimization,
        catalog: catalog,
        manualPrice: costProductionFloor(closet, bom, optimization, catalog) * 1.05,
      );

      final alerts = ValidationEngine.validate(
        furniture: closet,
        pieces: bom.pieces,
        cost: costCritical,
        optimization: optimization,
      );

      expect(alerts.any((a) => a.id == 'alert_margin_critical' || a.id == 'alert_margin_loss'), isTrue);
      if (alerts.any((a) => a.id == 'alert_margin_critical')) {
        final critAlert = alerts.firstWhere((a) => a.id == 'alert_margin_critical');
        expect(critAlert.severity, AlertSeverity.critical);
        expect(critAlert.message, contains('por debajo del límite mínimo recomendado (30%)'));
      }
    });
  });
}

double costProductionFloor(FurnitureModel f, BomResult b, OptimizationResult o, WorkshopCatalog c) {
  final cost = CostingEngine.calculateCost(furniture: f, bom: b, optimization: o, catalog: c);
  return cost.totalCostBs;
}
