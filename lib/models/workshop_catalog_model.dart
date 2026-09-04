import 'cost_breakdown_model.dart';

class BoardMaterialItem {
  final String id;
  final String name;
  final double lengthMm;
  final double widthMm;
  final double thicknessMm;
  final double priceBs;

  const BoardMaterialItem({
    required this.id,
    required this.name,
    required this.lengthMm,
    required this.widthMm,
    required this.thicknessMm,
    required this.priceBs,
  });

  double get areaM2 => (lengthMm * widthMm) / 1000000.0;

  BoardMaterialItem copyWith({
    String? id,
    String? name,
    double? lengthMm,
    double? widthMm,
    double? thicknessMm,
    double? priceBs,
  }) {
    return BoardMaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      lengthMm: lengthMm ?? this.lengthMm,
      widthMm: widthMm ?? this.widthMm,
      thicknessMm: thicknessMm ?? this.thicknessMm,
      priceBs: priceBs ?? this.priceBs,
    );
  }
}

class HardwareCatalogItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double unitCostBs;

  const HardwareCatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.unitCostBs,
  });

  HardwareCatalogItem copyWith({
    String? id,
    String? name,
    String? category,
    String? unit,
    double? unitCostBs,
  }) {
    return HardwareCatalogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      unitCostBs: unitCostBs ?? this.unitCostBs,
    );
  }
}

class WorkshopServices {
  final double cutServiceCostPerBoardBs;
  final double edgeThinApplyCostPerMeterBs;
  final double edgeThickApplyCostPerMeterBs;
  final double hingeHoleCostPerUnitBs;
  final double laborHourlyRateBs;
  final double freightBaseBs;
  final double indirectExpensePercent; // Desgaste de brocas, discos y herramientas (ej. 8.0%)
  final double edgeWasteMarginPercent; // e.g. 10.0 %
  final double sawBladeKerfMm;          // e.g. 4.0 mm

  // Gastos Fijos y Generales del Negocio (Alquiler, administración, showroom, servicios)
  final double operatingExpensePercent; // e.g. 6.0 %

  // Gastos Financieros (Intereses por créditos para insumos, deudas o préstamos de maquinaria)
  final double financialExpensePercent; // e.g. 2.0 %

  // Régimen Tributario Boliviano por defecto
  final BoliviaTaxRegime defaultTaxRegime;

  const WorkshopServices({
    this.cutServiceCostPerBoardBs = 35.0,
    this.edgeThinApplyCostPerMeterBs = 3.5,
    this.edgeThickApplyCostPerMeterBs = 7.0,
    this.hingeHoleCostPerUnitBs = 3.0,
    this.laborHourlyRateBs = 35.0,
    this.freightBaseBs = 120.0,
    this.indirectExpensePercent = 8.0,
    this.edgeWasteMarginPercent = 10.0,
    this.sawBladeKerfMm = 4.0,
    this.operatingExpensePercent = 6.0,
    this.financialExpensePercent = 2.0,
    this.defaultTaxRegime = BoliviaTaxRegime.sieteRg,
  });

  WorkshopServices copyWith({
    double? cutServiceCostPerBoardBs,
    double? edgeThinApplyCostPerMeterBs,
    double? edgeThickApplyCostPerMeterBs,
    double? hingeHoleCostPerUnitBs,
    double? laborHourlyRateBs,
    double? freightBaseBs,
    double? indirectExpensePercent,
    double? edgeWasteMarginPercent,
    double? sawBladeKerfMm,
    double? operatingExpensePercent,
    double? financialExpensePercent,
    BoliviaTaxRegime? defaultTaxRegime,
  }) {
    return WorkshopServices(
      cutServiceCostPerBoardBs: cutServiceCostPerBoardBs ?? this.cutServiceCostPerBoardBs,
      edgeThinApplyCostPerMeterBs: edgeThinApplyCostPerMeterBs ?? this.edgeThinApplyCostPerMeterBs,
      edgeThickApplyCostPerMeterBs: edgeThickApplyCostPerMeterBs ?? this.edgeThickApplyCostPerMeterBs,
      hingeHoleCostPerUnitBs: hingeHoleCostPerUnitBs ?? this.hingeHoleCostPerUnitBs,
      laborHourlyRateBs: laborHourlyRateBs ?? this.laborHourlyRateBs,
      freightBaseBs: freightBaseBs ?? this.freightBaseBs,
      indirectExpensePercent: indirectExpensePercent ?? this.indirectExpensePercent,
      edgeWasteMarginPercent: edgeWasteMarginPercent ?? this.edgeWasteMarginPercent,
      sawBladeKerfMm: sawBladeKerfMm ?? this.sawBladeKerfMm,
      operatingExpensePercent: operatingExpensePercent ?? this.operatingExpensePercent,
      financialExpensePercent: financialExpensePercent ?? this.financialExpensePercent,
      defaultTaxRegime: defaultTaxRegime ?? this.defaultTaxRegime,
    );
  }
}

class WorkshopCatalog {
  final List<BoardMaterialItem> tablaMateriales;
  final List<HardwareCatalogItem> tablaHerrajes;
  final WorkshopServices tablaServicios;

  const WorkshopCatalog({
    required this.tablaMateriales,
    required this.tablaHerrajes,
    required this.tablaServicios,
  });

  static WorkshopCatalog defaultCatalog() {
    return const WorkshopCatalog(
      tablaMateriales: [
        BoardMaterialItem(
          id: 'mat_mel_18_blanco',
          name: 'Melamina Blanca 18mm (2750 x 1830)',
          lengthMm: 2750,
          widthMm: 1830,
          thicknessMm: 18,
          priceBs: 310.0,
        ),
        BoardMaterialItem(
          id: 'mat_mel_18_color',
          name: 'Melamina Color/Diseño 18mm (2750 x 1830)',
          lengthMm: 2750,
          widthMm: 1830,
          thicknessMm: 18,
          priceBs: 380.0,
        ),
        BoardMaterialItem(
          id: 'mat_mel_15_blanco',
          name: 'Melamina Blanca 15mm (2750 x 1830)',
          lengthMm: 2750,
          widthMm: 1830,
          thicknessMm: 15,
          priceBs: 260.0,
        ),
        BoardMaterialItem(
          id: 'mat_mel_15_color',
          name: 'Melamina Color/Diseño 15mm (2750 x 1830)',
          lengthMm: 2750,
          widthMm: 1830,
          thicknessMm: 15,
          priceBs: 320.0,
        ),
        BoardMaterialItem(
          id: 'mat_mdf_3_fondo',
          name: 'Fondo MDF/Durolac 3mm (2750 x 1830)',
          lengthMm: 2750,
          widthMm: 1830,
          thicknessMm: 3,
          priceBs: 95.0,
        ),
      ],
      tablaHerrajes: [
        HardwareCatalogItem(
          id: 'h_bisagra_suave',
          name: 'Bisagra Cazoleta 35mm Cierre Suave',
          category: 'Bisagras',
          unit: 'par',
          unitCostBs: 14.0,
        ),
        HardwareCatalogItem(
          id: 'h_corredera_tele',
          name: 'Corredera Telescópica Pesada (par)',
          category: 'Correderas',
          unit: 'par',
          unitCostBs: 38.0,
        ),
        HardwareCatalogItem(
          id: 'h_tirador_aluminio',
          name: 'Tirador / Manija Perfil de Aluminio',
          category: 'Tiradores',
          unit: 'pza',
          unitCostBs: 18.0,
        ),
        HardwareCatalogItem(
          id: 'h_tornillo_soberbio',
          name: 'Tornillos Soberbios 4x50 + Tapacaps',
          category: 'Tornillería',
          unit: 'pza',
          unitCostBs: 0.35,
        ),
        HardwareCatalogItem(
          id: 'h_tornillo_fijacion',
          name: 'Tornillos Fijación 3.5x15 / 4x16',
          category: 'Tornillería',
          unit: 'pza',
          unitCostBs: 0.15,
        ),
        HardwareCatalogItem(
          id: 'h_pata_regulable',
          name: 'Pata Regulable 10cm Plástica/Metálica',
          category: 'Patas',
          unit: 'pza',
          unitCostBs: 6.5,
        ),
        HardwareCatalogItem(
          id: 'h_soporte_repisa',
          name: 'Soporte Repisa Móvil (Pitón metálico)',
          category: 'Soportes',
          unit: 'pza',
          unitCostBs: 1.5,
        ),
        HardwareCatalogItem(
          id: 'h_canto_delgado_m',
          name: 'Tapacanto Delgado PVC 0.45mm (Material)',
          category: 'Canto',
          unit: 'm',
          unitCostBs: 2.5,
        ),
        HardwareCatalogItem(
          id: 'h_canto_grueso_m',
          name: 'Tapacanto Grueso PVC 2.0mm (Material)',
          category: 'Canto',
          unit: 'm',
          unitCostBs: 6.5,
        ),
        HardwareCatalogItem(
          id: 'h_consumibles',
          name: 'Consumibles (Cola, lija, broca, solvente)',
          category: 'Consumibles',
          unit: 'global',
          unitCostBs: 35.0,
        ),
      ],
      tablaServicios: WorkshopServices(),
    );
  }

  WorkshopCatalog copyWith({
    List<BoardMaterialItem>? tablaMateriales,
    List<HardwareCatalogItem>? tablaHerrajes,
    WorkshopServices? tablaServicios,
  }) {
    return WorkshopCatalog(
      tablaMateriales: tablaMateriales ?? this.tablaMateriales,
      tablaHerrajes: tablaHerrajes ?? this.tablaHerrajes,
      tablaServicios: tablaServicios ?? this.tablaServicios,
    );
  }
}

