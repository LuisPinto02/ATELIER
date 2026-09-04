import 'dart:math';
import '../models/furniture_model.dart';
import '../models/workshop_catalog_model.dart';
import '../models/cost_breakdown_model.dart';
import '../models/cutting_layout_model.dart';
import 'bom_engine.dart';

class CostingEngine {
  /// Calcula el desglose industrial de costos (MP, MOD, CIF), gastos operativos,
  /// gastos financieros, precio sugerido y el Estado de Resultados formal en Bolivia.
  static CostBreakdownModel calculateCost({
    required FurnitureModel furniture,
    required BomResult bom,
    required OptimizationResult optimization,
    required WorkshopCatalog catalog,
    double targetMarginPercent = 30.0,
    double? manualPrice,
    BoliviaTaxRegime? taxRegime,
    double? operatingExpensesPercentOverride,
    double? financialExpensesPercentOverride,
  }) {
    final services = catalog.tablaServicios;
    final selectedRegime = taxRegime ?? services.defaultTaxRegime;

    // =========================================================================
    // 1. MATERIA PRIMA DIRECTA (MP)
    // =========================================================================
    // 1.1 Planchas de Melamina
    final melBoardPrice = _findMelamineBoardPrice(catalog, furniture);
    final melBoardsCount = optimization.totalMelamineBoardsNeeded;
    final melTotalBs = melBoardsCount * melBoardPrice;

    // 1.2 Plancha de Fondo MDF (3mm o 5mm)
    final backingBoardPrice = _findBackingBoardPrice(catalog);
    final backingBoardsCount = furniture.hasBacking ? optimization.totalBackingBoardsNeeded : 0;
    final backingTotalBs = backingBoardsCount * backingBoardPrice;

    // 1.3 Tapacantos (con factor de merma 10%)
    final wasteFactor = 1.0 + (services.edgeWasteMarginPercent / 100.0);
    final thinMetersWithWaste = bom.totalThinEdgeMeters * wasteFactor;
    final thickMetersWithWaste = bom.totalThickEdgeMeters * wasteFactor;

    final thinEdgeItem = catalog.tablaHerrajes.firstWhere(
      (h) => h.id == 'h_canto_delgado_m',
      orElse: () => const HardwareCatalogItem(id: 'def', name: 'Canto Delgado', category: 'Canto', unit: 'm', unitCostBs: 2.5),
    );
    final thickEdgeItem = catalog.tablaHerrajes.firstWhere(
      (h) => h.id == 'h_canto_grueso_m',
      orElse: () => const HardwareCatalogItem(id: 'def', name: 'Canto Grueso', category: 'Canto', unit: 'm', unitCostBs: 6.5),
    );

    final thinEdgeTotalBs = thinMetersWithWaste * thinEdgeItem.unitCostBs;
    final thickEdgeTotalBs = thickMetersWithWaste * thickEdgeItem.unitCostBs;

    // 1.4 Subtotal de Herrajes y Consumibles Directos
    double hardwareSubtotal = 0;
    for (final hw in bom.hardware) {
      hardwareSubtotal += hw.subtotalBs;
    }

    // Subtotal MP (Materia Prima Directa)
    final subtotalDirectMaterials = melTotalBs + backingTotalBs + thinEdgeTotalBs + thickEdgeTotalBs + hardwareSubtotal;

    // =========================================================================
    // 2. MANO DE OBRA DIRECTA (MOD)
    // =========================================================================
    // Horas estimadas: 3h base + 1.2h/plancha + 0.8h/cajón + 0.3h/puerta + 0.2h/repisa
    final totalShelves = furniture.shelvesFixedCount + furniture.shelvesMobileCount;
    final estimatedLaborHours = 3.0 +
        (melBoardsCount * 1.2) +
        (furniture.drawersCount * 0.8) +
        (furniture.doorsCount * 0.3) +
        (totalShelves * 0.2);

    final subtotalLabor = estimatedLaborHours * services.laborHourlyRateBs;

    // =========================================================================
    // 3. COSTOS INDIRECTOS DE FABRICACIÓN (CIF)
    // =========================================================================
    // 3.1 Servicios de corte y procesamiento tercerizados
    final cutServiceTotal = (melBoardsCount + backingBoardsCount) * services.cutServiceCostPerBoardBs;
    final edgeApplyTotal = (bom.totalThinEdgeMeters * services.edgeThinApplyCostPerMeterBs) +
        (bom.totalThickEdgeMeters * services.edgeThickApplyCostPerMeterBs);
    final hingeHolesCount = bom.totalHingesCount;
    final hingeHolesTotal = hingeHolesCount * services.hingeHoleCostPerUnitBs;
    final subtotalServices = cutServiceTotal + edgeApplyTotal + hingeHolesTotal;

    // 3.2 Flete y logística de insumos a taller
    final freight = services.freightBaseBs;

    // 3.3 Desgaste de sierras, brocas, lijas de taller y mantenimiento
    final directSumForToolWear = subtotalDirectMaterials + subtotalServices + subtotalLabor;
    final toolWearPercentage = services.indirectExpensePercent;
    final toolWearTotal = directSumForToolWear * (toolWearPercentage / 100.0);

    // Subtotal CIF
    final subtotalCif = subtotalServices + freight + toolWearTotal;

    // COSTO TOTAL DE PRODUCCIÓN / FABRICACIÓN (C_Prod = MP + MOD + CIF)
    final productionCost = subtotalDirectMaterials + subtotalLabor + subtotalCif;

    // =========================================================================
    // 4. GASTOS OPERATIVOS Y GASTOS FINANCIEROS
    // =========================================================================
    // Gastos Operativos (Fijos generales: Alquiler taller, administración, servicios básicos)
    final operatingPercent = operatingExpensesPercentOverride ?? services.operatingExpensePercent;
    final operatingExpenses = productionCost * (operatingPercent / 100.0);

    // Gastos Financieros (Intereses por financiamiento de insumos, líneas de crédito o préstamos)
    final financialPercent = financialExpensesPercentOverride ?? services.financialExpensePercent;
    final financialExpenses = productionCost * (financialPercent / 100.0);

    // COSTO TOTAL INTEGRAL DEL PROYECTO (C_Total = Producción + Operativos + Financieros)
    final totalCost = productionCost + operatingExpenses + financialExpenses;

    // =========================================================================
    // 5. FÓRMULA ESTRICTA DE PRECIO SUGERIDO (MARGEN SOBRE LA VENTA)
    // =========================================================================
    // Fórmula obligatoria: Precio = Costo Total / (1 - M)
    final marginDecimal = (targetMarginPercent / 100.0).clamp(0.01, 0.95);
    final grossMarginPrice = totalCost / (1.0 - marginDecimal);

    // Markup sobre el costo (solo referencial): Costo * (1 + M)
    final markupPrice = totalCost * (1.0 + marginDecimal);

    final isManual = manualPrice != null && manualPrice > 0;
    final activePrice = isManual ? manualPrice : grossMarginPrice;

    // =========================================================================
    // 6. ESTADO DE RESULTADOS (P&L EN BOLIVIA)
    // =========================================================================
    // 1. Ventas (Ingresos Brutos)
    final grossRevenue = activePrice;

    // 2. Utilidad Bruta = Ventas - Costos de Producción (MP + MOD + CIF)
    final grossProfit = grossRevenue - productionCost;
    final grossProfitMargin = grossRevenue > 0 ? (grossProfit / grossRevenue) * 100.0 : 0.0;

    // 3. Utilidad Operativa = Utilidad Bruta - Gastos Operativos
    final operatingProfit = grossProfit - operatingExpenses;
    final operatingProfitMargin = grossRevenue > 0 ? (operatingProfit / grossRevenue) * 100.0 : 0.0;

    // 4. Utilidad Antes de Impuestos (UAI) = Utilidad Operativa - Gastos Financieros
    final uai = operatingProfit - financialExpenses;
    final uaiMargin = grossRevenue > 0 ? (uai / grossRevenue) * 100.0 : 0.0;

    // 5. Deducción de Impuestos según Régimen Tributario Boliviano
    double taxSieteRg = 0.0;
    double taxIva = 0.0;
    double taxIt = 0.0;
    double taxIue = 0.0;
    double totalTaxes = 0.0;

    if (selectedRegime == BoliviaTaxRegime.sieteRg) {
      // Régimen SIETE-RG (Simplificado): Impuesto único plano de 5% bimestral sobre ventas brutas
      taxSieteRg = grossRevenue * 0.05;
      totalTaxes = taxSieteRg;
    } else {
      // Régimen General:
      // IVA: 13% mensual (informativo, se traslada al consumidor en el precio final, no reduce la utilidad directamente)
      taxIva = grossRevenue * 0.13;
      // IT: 3% mensual sobre ingresos brutos
      taxIt = grossRevenue * 0.03;
      // IUE: 25% anual sobre la utilidad neta imponible (utilidad después de descontar el IT)
      final taxableBaseIue = max(0.0, uai - taxIt);
      taxIue = taxableBaseIue * 0.25;
      totalTaxes = taxIt + taxIue;
    }

    // 6. Utilidad Neta = UAI - Impuestos deducibles
    final netProfit = uai - totalTaxes;
    // Margen Neto Real resultante sobre la venta
    final actualMargin = grossRevenue > 0 ? (netProfit / grossRevenue) * 100.0 : 0.0;

    return CostBreakdownModel(
      melamineBoardsCount: melBoardsCount,
      melamineBoardUnitPriceBs: melBoardPrice,
      melamineBoardsTotalBs: melTotalBs,
      backingBoardsCount: backingBoardsCount,
      backingBoardUnitPriceBs: backingBoardPrice,
      backingBoardsTotalBs: backingTotalBs,
      thinEdgeLinearMeters: thinMetersWithWaste,
      thinEdgeMeterUnitPriceBs: thinEdgeItem.unitCostBs,
      thinEdgeTotalBs: thinEdgeTotalBs,
      thickEdgeLinearMeters: thickMetersWithWaste,
      thickEdgeMeterUnitPriceBs: thickEdgeItem.unitCostBs,
      thickEdgeTotalBs: thickEdgeTotalBs,
      hardwareItems: bom.hardware,
      hardwareSubtotalBs: hardwareSubtotal,
      subtotalDirectMaterialsBs: subtotalDirectMaterials,
      estimatedLaborHours: estimatedLaborHours,
      laborHourlyRateBs: services.laborHourlyRateBs,
      subtotalLaborBs: subtotalLabor,
      cutServiceTotalBs: cutServiceTotal,
      edgeApplyTotalBs: edgeApplyTotal,
      hingeHolesCount: hingeHolesCount,
      hingeHolesTotalBs: hingeHolesTotal,
      subtotalServicesBs: subtotalServices,
      freightBs: freight,
      toolWearPercentage: toolWearPercentage,
      toolWearTotalBs: toolWearTotal,
      subtotalCifBs: subtotalCif,
      productionCostBs: productionCost,
      operatingExpensesPercent: operatingPercent,
      operatingExpensesBs: operatingExpenses,
      financialExpensesPercent: financialPercent,
      financialExpensesBs: financialExpenses,
      totalCostBs: totalCost,
      targetMarginPercent: targetMarginPercent,
      grossMarginPriceBs: grossMarginPrice,
      markupPriceBs: markupPrice,
      activePriceBs: activePrice,
      isManualPriceActive: isManual,
      grossRevenueBs: grossRevenue,
      grossProfitBs: grossProfit,
      grossProfitMarginPercent: grossProfitMargin,
      operatingProfitBs: operatingProfit,
      operatingProfitMarginPercent: operatingProfitMargin,
      uaiBs: uai,
      uaiMarginPercent: uaiMargin,
      taxRegime: selectedRegime,
      taxSieteRgBs: taxSieteRg,
      taxIvaBs: taxIva,
      taxItBs: taxIt,
      taxIueBs: taxIue,
      totalTaxesBs: totalTaxes,
      netProfitBs: netProfit,
      actualMarginPercent: actualMargin,
    );
  }

  static double _findMelamineBoardPrice(WorkshopCatalog catalog, FurnitureModel furniture) {
    final isWhite = furniture.melamineColorName.toLowerCase().contains('blanco');
    final is18 = furniture.melamineThickness >= 17.5;

    for (final b in catalog.tablaMateriales) {
      if (is18 && b.thicknessMm == 18) {
        if (isWhite && b.name.toLowerCase().contains('blanco')) return b.priceBs;
        if (!isWhite && !b.name.toLowerCase().contains('blanco')) return b.priceBs;
      }
      if (!is18 && b.thicknessMm == 15) {
        if (isWhite && b.name.toLowerCase().contains('blanco')) return b.priceBs;
        if (!isWhite && !b.name.toLowerCase().contains('blanco')) return b.priceBs;
      }
    }
    return 380.0; // fallback
  }

  static double _findBackingBoardPrice(WorkshopCatalog catalog) {
    for (final b in catalog.tablaMateriales) {
      if (b.thicknessMm == 3 || b.name.toLowerCase().contains('fondo') || b.name.toLowerCase().contains('durolac')) {
        return b.priceBs;
      }
    }
    return 95.0;
  }
}

