import '../models/furniture_model.dart';
import '../models/cut_piece_model.dart';
import '../models/hardware_item_model.dart';
import '../models/workshop_catalog_model.dart';

class BomResult {
  final List<CutPiece> pieces;
  final List<HardwareItem> hardware;
  final double totalThinEdgeMeters;
  final double totalThickEdgeMeters;
  final double totalMelamineAreaM2;
  final double totalBackingAreaM2;
  final int totalHingesCount;
  final int totalSlidePairsCount;

  const BomResult({
    required this.pieces,
    required this.hardware,
    required this.totalThinEdgeMeters,
    required this.totalThickEdgeMeters,
    required this.totalMelamineAreaM2,
    required this.totalBackingAreaM2,
    required this.totalHingesCount,
    required this.totalSlidePairsCount,
  });
}

class BomEngine {
  /// Genera el despiece completo de piezas de madera y el listado de herrajes
  static BomResult generateBom(FurnitureModel furniture, WorkshopCatalog catalog) {
    final t = furniture.melamineThickness; // Espesor en mm (15 o 18)
    final h = furniture.height;
    final w = furniture.width;
    final d = furniture.depth;
    final zocalo = furniture.zocaloHeight;

    final List<CutPiece> pieces = [];

    // Altura útil de laterales y cuerpo interior
    final effectiveSideHeight = zocalo > 0 ? h : h;
    final internalHeight = zocalo > 0 ? (h - zocalo - 2 * t) : (h - 2 * t);
    final internalWidth = w - (2 * t);

    // 1. LATERALES / COSTADOS (2 piezas)
    pieces.add(CutPiece(
      id: 'lat_ext',
      name: 'Laterales Principales',
      length: effectiveSideHeight,
      width: d,
      thickness: t,
      quantity: 2,
      cantoL1: furniture.frontEdgeType, // Frente canteado
      cantoL2: EdgeType.none,          // Posterior
      cantoA1: furniture.internalEdgeType, // Superior
      cantoA2: furniture.internalEdgeType, // Inferior
      notes: 'Laterales estructurales exteriores',
    ));

    // 2. TECHO / TAPA SUPERIOR (1 pieza)
    pieces.add(CutPiece(
      id: 'techo_sup',
      name: 'Techo / Tapa Superior',
      length: internalWidth,
      width: d,
      thickness: t,
      quantity: 1,
      cantoL1: furniture.frontEdgeType,
      cantoL2: EdgeType.none,
      cantoA1: EdgeType.none,
      cantoA2: EdgeType.none,
      notes: 'Encaje entre laterales (W - 2t)',
    ));

    // 3. BASE / PISO INFERIOR (1 pieza)
    pieces.add(CutPiece(
      id: 'base_inf',
      name: 'Base / Piso Inferior',
      length: internalWidth,
      width: d,
      thickness: t,
      quantity: 1,
      cantoL1: furniture.frontEdgeType,
      cantoL2: EdgeType.none,
      cantoA1: EdgeType.none,
      cantoA2: EdgeType.none,
      notes: 'Piso sobre zócalo o apoyado',
    ));

    // 4. ZÓCALOS (si aplica)
    if (zocalo > 0) {
      pieces.add(CutPiece(
        id: 'zocalo_fr_post',
        name: 'Zócalos (Frontal y Posterior)',
        length: internalWidth,
        width: zocalo,
        thickness: t,
        quantity: 2,
        cantoL1: furniture.internalEdgeType, // Canto superior/inferior para humedad
        cantoL2: furniture.internalEdgeType,
        cantoA1: EdgeType.none,
        cantoA2: EdgeType.none,
        notes: 'Zócalo de apoyo contra piso',
      ));
    }

    // 5. PARANTES / DIVISIONES VERTICALES
    final numDividers = furniture.verticalDividersCount;
    if (numDividers > 0) {
      pieces.add(CutPiece(
        id: 'parante_div',
        name: 'Divisiones Verticales / Parantes',
        length: internalHeight,
        width: (d - 20).clamp(100.0, d), // 20mm de retranqueo para puertas o fondo
        thickness: t,
        quantity: numDividers,
        cantoL1: furniture.frontEdgeType,
        cantoL2: EdgeType.none,
        cantoA1: EdgeType.none,
        cantoA2: EdgeType.none,
        notes: 'Parante divisor interior',
      ));
    }

    // Ancho del compartimento para repisas y cajones
    final compartmentWidth = numDividers > 0
        ? (internalWidth - (numDividers * t)) / (numDividers + 1)
        : internalWidth;

    // 6. REPISAS FIJAS
    if (furniture.shelvesFixedCount > 0) {
      final totalFixedShelves = furniture.shelvesFixedCount * (numDividers > 0 ? (numDividers + 1) : 1);
      pieces.add(CutPiece(
        id: 'repisa_fija',
        name: 'Repisas Fijas Estructurales',
        length: compartmentWidth,
        width: (d - 20).clamp(100.0, d),
        thickness: t,
        quantity: totalFixedShelves,
        cantoL1: furniture.internalEdgeType,
        cantoL2: EdgeType.none,
        cantoA1: EdgeType.none,
        cantoA2: EdgeType.none,
        notes: 'Atornilladas fijas para rigidizar',
      ));
    }

    // 7. REPISAS MÓVILES / GRADUABLES
    if (furniture.shelvesMobileCount > 0) {
      final totalMobileShelves = furniture.shelvesMobileCount * (numDividers > 0 ? (numDividers + 1) : 1);
      pieces.add(CutPiece(
        id: 'repisa_movil',
        name: 'Repisas Móviles (Graduables)',
        length: (compartmentWidth - 2.0).clamp(50.0, compartmentWidth), // 2mm holgura
        width: (d - 25).clamp(100.0, d),
        thickness: t,
        quantity: totalMobileShelves,
        cantoL1: furniture.internalEdgeType,
        cantoL2: EdgeType.none,
        cantoA1: EdgeType.none,
        cantoA2: EdgeType.none,
        notes: 'Holgura de 2mm para pitones/ménsulas',
      ));
    }

    // 8. FONDO / TRASERA (MDF 3mm o 5mm)
    if (furniture.hasBacking && furniture.backingType != BackingType.none) {
      final backingThickness = furniture.backingType == BackingType.mdf5mm ? 5.0 : 3.0;
      pieces.add(CutPiece(
        id: 'fondo_mdf',
        name: 'Fondo / Trasera (MDF)',
        length: (h - 10).clamp(100.0, h),
        width: (w - 10).clamp(100.0, w),
        thickness: backingThickness,
        quantity: 1,
        cantoL1: EdgeType.none,
        cantoL2: EdgeType.none,
        cantoA1: EdgeType.none,
        cantoA2: EdgeType.none,
        notes: 'MDF ranurado o clavado por posterior',
        isBacking: true,
      ));
    }

    // 9. PUERTAS
    int calculatedHinges = 0;
    if (furniture.doorsCount > 0) {
      final numDoors = furniture.doorsCount;
      double doorHeight;
      double doorWidth;

      if (furniture.doorType == DoorType.batiente) {
        // Huelgo perimetral estándar de 3-4 mm
        doorHeight = zocalo > 0 ? (h - zocalo - 4) : (h - 4);
        // Huelgo entre puertas: 3mm
        final totalClearance = 4.0 + (numDoors - 1) * 3.0;
        doorWidth = (w - totalClearance) / numDoors;

        // Cálculo de bisagras según alto de puerta
        int hingesPerDoor;
        if (doorHeight < 900) {
          hingesPerDoor = 2;
        } else if (doorHeight < 1600) {
          hingesPerDoor = 3;
        } else {
          hingesPerDoor = 4;
        }
        calculatedHinges = numDoors * hingesPerDoor;

        pieces.add(CutPiece(
          id: 'puerta_batiente',
          name: 'Puertas Batientes',
          length: doorHeight,
          width: doorWidth,
          thickness: t,
          quantity: numDoors,
          cantoL1: furniture.frontEdgeType,
          cantoL2: furniture.frontEdgeType,
          cantoA1: furniture.frontEdgeType,
          cantoA2: furniture.frontEdgeType,
          notes: '4 cantos gruesos, $hingesPerDoor bisagras c/u (descuento 3mm)',
        ));
      } else {
        // Corredizas con solape de 30mm
        doorHeight = (h - (zocalo > 0 ? zocalo : 0) - 45).clamp(100.0, h); // Espacio riel
        doorWidth = (w + 30.0) / numDoors;

        pieces.add(CutPiece(
          id: 'puerta_corrediza',
          name: 'Puertas Corredizas',
          length: doorHeight,
          width: doorWidth,
          thickness: t,
          quantity: numDoors,
          cantoL1: furniture.frontEdgeType,
          cantoL2: furniture.frontEdgeType,
          cantoA1: furniture.frontEdgeType,
          cantoA2: furniture.frontEdgeType,
          notes: '4 cantos, solape 30mm, kit de ruedas corredizas',
        ));
      }
    }

    // 10. CAJONES
    int slidePairsCount = 0;
    if (furniture.drawersCount > 0) {
      final numDrawers = furniture.drawersCount;
      slidePairsCount = numDrawers;

      // Profundidad de correderas estándar (300, 350, 400, 450, 500, 550)
      final rawSlideDepth = ((d - 50) / 50).floor() * 50.0;
      final slideDepth = rawSlideDepth.clamp(300.0, 550.0);

      // Ancho del módulo cajonero (compartimento)
      final drawerBayWidth = compartmentWidth;
      // Altura disponible estimada para cajonera (ej. zona de 700mm o repartida)
      final availableDrawerHeight = (internalHeight * 0.5).clamp(400.0, internalHeight);
      final drawerFrontHeight = (availableDrawerHeight / numDrawers) - 3.0; // Huelgo 3mm
      final drawerBoxHeight = (drawerFrontHeight - 35.0).clamp(100.0, 200.0);

      // 10.1 Frentes de cajón
      pieces.add(CutPiece(
        id: 'cajon_frente',
        name: 'Frentes de Cajón Exterior',
        length: drawerBayWidth - 3.0,
        width: drawerFrontHeight,
        thickness: t,
        quantity: numDrawers,
        cantoL1: furniture.frontEdgeType,
        cantoL2: furniture.frontEdgeType,
        cantoA1: furniture.frontEdgeType,
        cantoA2: furniture.frontEdgeType,
        notes: 'Frente visto con 4 cantos gruesos (huelgo 3mm)',
      ));

      // 10.2 Laterales de cajón (2 por cajón)
      pieces.add(CutPiece(
        id: 'cajon_lateral',
        name: 'Laterales de Cajón (Caja)',
        length: slideDepth,
        width: drawerBoxHeight,
        thickness: 15.0, // Típicamente melamina 15mm para aligerar o 18mm
        quantity: numDrawers * 2,
        cantoL1: furniture.internalEdgeType,
        cantoL2: EdgeType.none,
        cantoA1: EdgeType.none,
        cantoA2: EdgeType.none,
        notes: 'Medida corredera ${slideDepth.toInt()}mm',
      ));

      // 10.3 Testeros y Traseras de cajón (2 por cajón)
      // REGLA CRÍTICA: Descuento de 26mm para el par de correderas telescópicas
      final drawerInternalBoxWidth = drawerBayWidth - (2 * 15.0) - 26.0;
      pieces.add(CutPiece(
        id: 'cajon_testero_trasera',
        name: 'Testero y Contrafrente de Cajón',
        length: drawerInternalBoxWidth.clamp(100.0, drawerBayWidth),
        width: drawerBoxHeight,
        thickness: 15.0,
        quantity: numDrawers * 2,
        cantoL1: furniture.internalEdgeType,
        cantoL2: EdgeType.none,
        cantoA1: EdgeType.none,
        cantoA2: EdgeType.none,
        notes: 'Descuento correderas telescópicas: -26mm',
      ));

      // 10.4 Fondos de cajón (MDF 3mm)
      pieces.add(CutPiece(
        id: 'cajon_fondo_mdf',
        name: 'Fondos de Cajón (MDF 3mm)',
        length: slideDepth - 6.0,
        width: (drawerInternalBoxWidth + 18.0).clamp(100.0, drawerBayWidth),
        thickness: 3.0,
        quantity: numDrawers,
        cantoL1: EdgeType.none,
        cantoL2: EdgeType.none,
        cantoA1: EdgeType.none,
        cantoA2: EdgeType.none,
        notes: 'Ranurado en laterales y frentes de caja',
        isBacking: true,
      ));
    }

    // CÁLCULO DE TOTALES DE CANTOS Y ÁREAS
    double thinMeters = 0;
    double thickMeters = 0;
    double melamineArea = 0;
    double backingArea = 0;

    for (final p in pieces) {
      thinMeters += p.linearMetersEdgeThin;
      thickMeters += p.linearMetersEdgeThick;
      if (p.isBacking) {
        backingArea += p.totalAreaM2;
      } else {
        melamineArea += p.totalAreaM2;
      }
    }

    // LISTADO CONSOLIDADO DE HERRAJES Y CONSUMIBLES
    final List<HardwareItem> hardware = [];

    // Bisagras (si hay puertas batientes)
    if (calculatedHinges > 0) {
      final hingeCat = catalog.tablaHerrajes.firstWhere(
        (h) => h.category == 'Bisagras',
        orElse: () => const HardwareCatalogItem(
          id: 'def_hinge',
          name: 'Bisagra Cazoleta 35mm Cierre Suave',
          category: 'Bisagras',
          unit: 'par',
          unitCostBs: 14.0,
        ),
      );
      // Cantidad en pares (cada par = 2 bisagras)
      final pairs = (calculatedHinges / 2.0).ceilToDouble();
      hardware.add(HardwareItem(
        id: 'hw_bisagras',
        name: '${hingeCat.name} ($calculatedHinges unid.)',
        category: 'Bisagras',
        quantity: pairs,
        unit: 'par',
        unitPriceBs: hingeCat.unitCostBs,
        details: 'Cálculo por altura: ${calculatedHinges ~/ furniture.doorsCount} bisagras x puerta',
      ));
    }

    // Correderas
    if (slidePairsCount > 0) {
      final rawSlideDepth = ((d - 50) / 50).floor() * 50.0;
      final slideDepth = rawSlideDepth.clamp(300.0, 550.0);
      final slideCat = catalog.tablaHerrajes.firstWhere(
        (h) => h.category == 'Correderas',
        orElse: () => const HardwareCatalogItem(
          id: 'def_slide',
          name: 'Corredera Telescópica Pesada',
          category: 'Correderas',
          unit: 'par',
          unitCostBs: 38.0,
        ),
      );
      hardware.add(HardwareItem(
        id: 'hw_correderas',
        name: '${slideCat.name} ${slideDepth.toInt()}mm',
        category: 'Correderas',
        quantity: slidePairsCount.toDouble(),
        unit: 'par',
        unitPriceBs: slideCat.unitCostBs,
        details: '1 par por cada cajón',
      ));
    }

    // Tiradores / Manijas
    final totalHandles = furniture.doorsCount + furniture.drawersCount;
    if (totalHandles > 0) {
      final handleCat = catalog.tablaHerrajes.firstWhere(
        (h) => h.category == 'Tiradores',
        orElse: () => const HardwareCatalogItem(
          id: 'def_handle',
          name: 'Tirador / Manija Perfil',
          category: 'Tiradores',
          unit: 'pza',
          unitCostBs: 18.0,
        ),
      );
      hardware.add(HardwareItem(
        id: 'hw_tiradores',
        name: handleCat.name,
        category: 'Tiradores',
        quantity: totalHandles.toDouble(),
        unit: 'pza',
        unitPriceBs: handleCat.unitCostBs,
        details: '${furniture.doorsCount} p/puertas + ${furniture.drawersCount} p/cajones',
      ));
    }

    // Tornillos Soberbios 4x50 (Estructura: laterales con base, techo, parantes, repisas)
    final jointsCount = 4 + (zocalo > 0 ? 4 : 0) + (numDividers * 4) + (furniture.shelvesFixedCount * 4) + (furniture.drawersCount * 4);
    final soberbioCount = (jointsCount * 3.5).round();
    final soberbioCat = catalog.tablaHerrajes.firstWhere(
      (h) => h.name.contains('Soberbios'),
      orElse: () => const HardwareCatalogItem(
        id: 'def_sob',
        name: 'Tornillos Soberbios 4x50 + Tapacaps',
        category: 'Tornillería',
        unit: 'pza',
        unitCostBs: 0.35,
      ),
    );
    hardware.add(HardwareItem(
      id: 'hw_soberbios',
      name: soberbioCat.name,
      category: 'Tornillería',
      quantity: soberbioCount.toDouble(),
      unit: 'pza',
      unitPriceBs: soberbioCat.unitCostBs,
      details: 'Uniones estructurales de melamina',
    ));

    // Tornillos de fijación 3.5x15 (Herrajes, correderas, bisagras, fondo)
    final screw35Count = (calculatedHinges * 6) + (slidePairsCount * 12) + (furniture.hasBacking ? 28 : 0) + 16;
    final screwCat = catalog.tablaHerrajes.firstWhere(
      (h) => h.name.contains('3.5x15') || h.category == 'Tornillería',
      orElse: () => const HardwareCatalogItem(
        id: 'def_screw',
        name: 'Tornillos Fijación 3.5x15',
        category: 'Tornillería',
        unit: 'pza',
        unitCostBs: 0.15,
      ),
    );
    hardware.add(HardwareItem(
      id: 'hw_tornillos_fijacion',
      name: screwCat.name,
      category: 'Tornillería',
      quantity: screw35Count.toDouble(),
      unit: 'pza',
      unitPriceBs: screwCat.unitCostBs,
      details: 'Fijación de bisagras, correderas y trasera',
    ));

    // Patas regulables o deslizadores
    final legsCount = w > 1200 ? 6 : 4;
    final legCat = catalog.tablaHerrajes.firstWhere(
      (h) => h.category == 'Patas',
      orElse: () => const HardwareCatalogItem(
        id: 'def_leg',
        name: 'Pata Regulable 10cm',
        category: 'Patas',
        unit: 'pza',
        unitCostBs: 6.5,
      ),
    );
    hardware.add(HardwareItem(
      id: 'hw_patas',
      name: legCat.name,
      category: 'Patas',
      quantity: legsCount.toDouble(),
      unit: 'pza',
      unitPriceBs: legCat.unitCostBs,
      details: w > 1200 ? '6 patas para W > 1.20m' : '4 patas estándar',
    ));

    // Soportes de repisas móviles (pitones)
    if (furniture.shelvesMobileCount > 0) {
      final mobileShelvesTotal = furniture.shelvesMobileCount * (numDividers > 0 ? (numDividers + 1) : 1);
      final pitonesCount = mobileShelvesTotal * 4;
      final pitonCat = catalog.tablaHerrajes.firstWhere(
        (h) => h.category == 'Soportes',
        orElse: () => const HardwareCatalogItem(
          id: 'def_piton',
          name: 'Soporte Repisa Móvil (Pitón metálico)',
          category: 'Soportes',
          unit: 'pza',
          unitCostBs: 1.5,
        ),
      );
      hardware.add(HardwareItem(
        id: 'hw_pitones',
        name: pitonCat.name,
        category: 'Soportes',
        quantity: pitonesCount.toDouble(),
        unit: 'pza',
        unitPriceBs: pitonCat.unitCostBs,
        details: '4 pitones por cada repisa graduable',
      ));
    }

    // Consumibles generales
    final consumiblesCat = catalog.tablaHerrajes.firstWhere(
      (h) => h.category == 'Consumibles',
      orElse: () => const HardwareCatalogItem(
        id: 'def_consumibles',
        name: 'Consumibles de Armado',
        category: 'Consumibles',
        unit: 'global',
        unitCostBs: 35.0,
      ),
    );
    hardware.add(HardwareItem(
      id: 'hw_consumibles',
      name: consumiblesCat.name,
      category: 'Consumibles',
      quantity: 1.0,
      unit: 'global',
      unitPriceBs: consumiblesCat.unitCostBs,
      details: 'Cola de contacto, solvente, lijas, broca',
    ));

    return BomResult(
      pieces: pieces,
      hardware: hardware,
      totalThinEdgeMeters: thinMeters,
      totalThickEdgeMeters: thickMeters,
      totalMelamineAreaM2: melamineArea,
      totalBackingAreaM2: backingArea,
      totalHingesCount: calculatedHinges,
      totalSlidePairsCount: slidePairsCount,
    );
  }
}

