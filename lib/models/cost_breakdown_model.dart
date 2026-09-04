import 'hardware_item_model.dart';

/// Régimen tributario seleccionable en Bolivia
enum BoliviaTaxRegime {
  sieteRg, // Régimen SIETE-RG (Simplificado para pequeños emprendimientos)
  general, // Régimen General (Empresas de cualquier tamaño)
}

extension BoliviaTaxRegimeExtension on BoliviaTaxRegime {
  String get name {
    switch (this) {
      case BoliviaTaxRegime.sieteRg:
        return 'Régimen SIETE-RG (Simplificado)';
      case BoliviaTaxRegime.general:
        return 'Régimen General';
    }
  }

  String get shortName {
    switch (this) {
      case BoliviaTaxRegime.sieteRg:
        return 'SIETE-RG (5%)';
      case BoliviaTaxRegime.general:
        return 'General (IVA/IT/IUE)';
    }
  }

  String get description {
    switch (this) {
      case BoliviaTaxRegime.sieteRg:
        return 'Impuesto único plano del 5% bimestral sobre ventas brutas. Exclusivo para negocios con ingresos menores a Bs 250.000 al año.';
      case BoliviaTaxRegime.general:
        return 'IVA 13% (informativo/trasladable), IT 3% mensual sobre ingresos brutos e IUE 25% anual sobre la utilidad neta imponible.';
    }
  }
}

class CostBreakdownModel {
  // ==========================================
  // 1. COSTOS DIRECTOS E INDUSTRIALES (MP, MOD, CIF)
  // ==========================================

  // 1.1 Materia Prima Directa (MP)
  final int melamineBoardsCount;
  final double melamineBoardUnitPriceBs;
  final double melamineBoardsTotalBs;

  final int backingBoardsCount;
  final double backingBoardUnitPriceBs;
  final double backingBoardsTotalBs;

  final double thinEdgeLinearMeters;
  final double thinEdgeMeterUnitPriceBs;
  final double thinEdgeTotalBs; // con 10% merma

  final double thickEdgeLinearMeters;
  final double thickEdgeMeterUnitPriceBs;
  final double thickEdgeTotalBs; // con 10% merma

  final List<HardwareItem> hardwareItems;
  final double hardwareSubtotalBs;

  /// Total Materia Prima Directa (MP = Melamina + Fondo + Cantos + Herrajes)
  final double subtotalDirectMaterialsBs; // MP

  // 1.2 Mano de Obra Directa (MOD)
  final double estimatedLaborHours;
  final double laborHourlyRateBs;
  /// Total Mano de Obra Directa (MOD = Horas * Tarifa)
  final double subtotalLaborBs; // MOD

  // 1.3 Costos Indirectos de Fabricación (CIF)
  final double cutServiceTotalBs;
  final double edgeApplyTotalBs;
  final int hingeHolesCount;
  final double hingeHolesTotalBs;
  final double subtotalServicesBs;
  final double freightBs;
  final double toolWearPercentage; // Desgaste de brocas, sierras, depreciación
  final double toolWearTotalBs;
  /// Total Costos Indirectos de Fabricación (CIF = Servicios + Flete + Desgaste)
  final double subtotalCifBs; // CIF

  /// Costo Total de Producción / Costo de Fabricación (C_Prod = MP + MOD + CIF)
  final double productionCostBs;

  // ==========================================
  // 2. GASTOS OPERATIVOS Y FINANCIEROS
  // ==========================================

  /// Gastos Operativos Generales (Fijos: Alquiler taller/showroom, luz administrativa, contabilidad)
  final double operatingExpensesPercent; // % atribuido
  final double operatingExpensesBs;

  /// Gastos Financieros (Intereses por créditos o préstamos para compras/maquinaria)
  final double financialExpensesPercent; // % atribuido
  final double financialExpensesBs;

  /// Costo Total Integral del Proyecto (C_Total = Producción + Operativos + Financieros)
  final double totalCostBs;

  // ==========================================
  // 3. ANÁLISIS DE PRECIOS Y MARGEN OBJETIVO
  // ==========================================
  final double targetMarginPercent; // M (ej. 30%)
  
  /// Fórmula obligatoria de margen sobre la venta:
  /// Precio = Costo Total / (1 - M)
  final double grossMarginPriceBs;

  /// Fórmula de Markup sobre el costo (informativa):
  /// Precio = Costo Total * (1 + M)
  final double markupPriceBs;

  /// Precio activo de venta del mueble (sugerido o manual)
  final double activePriceBs;
  final bool isManualPriceActive;

  // ==========================================
  // 4. ESTADO DE RESULTADOS (P&L FORMAL)
  // ==========================================
  /// 1. Ventas (Ingresos Brutos = Precio activo)
  final double grossRevenueBs;

  /// 2. Utilidad Bruta = Ventas - Costo de Producción (MP + MOD + CIF)
  final double grossProfitBs;
  final double grossProfitMarginPercent; // (Utilidad Bruta / Ventas) * 100

  /// 3. Utilidad Operativa = Utilidad Bruta - Gastos Operativos
  final double operatingProfitBs;
  final double operatingProfitMarginPercent; // (Utilidad Operativa / Ventas) * 100

  /// 4. Utilidad Antes de Impuestos (UAI) = Utilidad Operativa - Gastos Financieros
  final double uaiBs;
  final double uaiMarginPercent; // (UAI / Ventas) * 100

  /// 5. Régimen Tributario Boliviano y Desglose de Impuestos
  final BoliviaTaxRegime taxRegime;

  // Régimen SIETE-RG: Impuesto único 5% sobre ventas brutas
  final double taxSieteRgBs;

  // Régimen General:
  final double taxIvaBs; // IVA 13% mensual (informativo trasladable al cliente)
  final double taxItBs;  // IT 3% mensual sobre ventas brutas
  final double taxIueBs; // IUE 25% anual sobre utilidad imponible (UAI - IT)

  /// Total de impuestos que reducen la utilidad
  final double totalTaxesBs;

  /// 6. Utilidad Neta Final = UAI - Impuestos
  final double netProfitBs;
  final double actualMarginPercent; // Margen Neto Real sobre la venta: (Utilidad Neta / Ventas) * 100

  const CostBreakdownModel({
    required this.melamineBoardsCount,
    required this.melamineBoardUnitPriceBs,
    required this.melamineBoardsTotalBs,
    required this.backingBoardsCount,
    required this.backingBoardUnitPriceBs,
    required this.backingBoardsTotalBs,
    required this.thinEdgeLinearMeters,
    required this.thinEdgeMeterUnitPriceBs,
    required this.thinEdgeTotalBs,
    required this.thickEdgeLinearMeters,
    required this.thickEdgeMeterUnitPriceBs,
    required this.thickEdgeTotalBs,
    required this.hardwareItems,
    required this.hardwareSubtotalBs,
    required this.subtotalDirectMaterialsBs,
    required this.estimatedLaborHours,
    required this.laborHourlyRateBs,
    required this.subtotalLaborBs,
    required this.cutServiceTotalBs,
    required this.edgeApplyTotalBs,
    required this.hingeHolesCount,
    required this.hingeHolesTotalBs,
    required this.subtotalServicesBs,
    required this.freightBs,
    required this.toolWearPercentage,
    required this.toolWearTotalBs,
    required this.subtotalCifBs,
    required this.productionCostBs,
    required this.operatingExpensesPercent,
    required this.operatingExpensesBs,
    required this.financialExpensesPercent,
    required this.financialExpensesBs,
    required this.totalCostBs,
    required this.targetMarginPercent,
    required this.grossMarginPriceBs,
    required this.markupPriceBs,
    required this.activePriceBs,
    required this.isManualPriceActive,
    required this.grossRevenueBs,
    required this.grossProfitBs,
    required this.grossProfitMarginPercent,
    required this.operatingProfitBs,
    required this.operatingProfitMarginPercent,
    required this.uaiBs,
    required this.uaiMarginPercent,
    required this.taxRegime,
    required this.taxSieteRgBs,
    required this.taxIvaBs,
    required this.taxItBs,
    required this.taxIueBs,
    required this.totalTaxesBs,
    required this.netProfitBs,
    required this.actualMarginPercent,
  });

  // Alias para retrocompatibilidad con referencias existentes
  double get indirectPercentage => toolWearPercentage;
  double get indirectExpenseTotalBs => toolWearTotalBs;
}

