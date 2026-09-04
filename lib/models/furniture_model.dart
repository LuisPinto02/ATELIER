import 'package:flutter/material.dart';

enum FurniturePreset {
  muebleBajoCocina,
  roperoCloset,
  repiseroLibrero,
  escritorio,
  personalizado,
}

enum DoorType {
  batiente,
  corrediza,
}

enum BackingType {
  none,
  mdf3mm,
  mdf5mm,
}

enum EdgeType {
  none,
  delgado045,
  grueso2mm,
}

extension EdgeTypeExtension on EdgeType {
  String get label {
    switch (this) {
      case EdgeType.none:
        return '-';
      case EdgeType.delgado045:
        return 'Delgado (0.45mm)';
      case EdgeType.grueso2mm:
        return 'Grueso (2.0mm)';
    }
  }

  String get shortLabel {
    switch (this) {
      case EdgeType.none:
        return '-';
      case EdgeType.delgado045:
        return 'D (0.45)';
      case EdgeType.grueso2mm:
        return 'G (2.0)';
    }
  }

  double get thicknessMm {
    switch (this) {
      case EdgeType.none:
        return 0.0;
      case EdgeType.delgado045:
        return 0.45;
      case EdgeType.grueso2mm:
        return 2.0;
    }
  }
}

class MelamineColorOption {
  final String name;
  final Color previewColor;
  final Color textColor;

  const MelamineColorOption({
    required this.name,
    required this.previewColor,
    required this.textColor,
  });
}

class FurnitureModel {
  final String name;
  final FurniturePreset preset;

  // Dimensiones generales (en milímetros)
  final double height; // H (Alto)
  final double width;  // W (Ancho)
  final double depth;  // D (Profundidad)

  // Componentes internos
  final int doorsCount;
  final DoorType doorType;
  final int drawersCount;
  final int shelvesFixedCount;
  final int shelvesMobileCount;
  final int verticalDividersCount;
  final bool hasBacking;
  final BackingType backingType;

  // Especificaciones del material
  final double melamineThickness; // 15 o 18 mm
  final String melamineColorName;
  final Color melamineColor;
  final EdgeType internalEdgeType; // Generalmente delgado 0.45mm
  final EdgeType frontEdgeType;    // Generalmente grueso 2mm para frentes y puertas

  // Altura del zócalo (mm)
  final double zocaloHeight;

  const FurnitureModel({
    required this.name,
    required this.preset,
    required this.height,
    required this.width,
    required this.depth,
    this.doorsCount = 2,
    this.doorType = DoorType.batiente,
    this.drawersCount = 0,
    this.shelvesFixedCount = 1,
    this.shelvesMobileCount = 2,
    this.verticalDividersCount = 0,
    this.hasBacking = true,
    this.backingType = BackingType.mdf3mm,
    this.melamineThickness = 18.0,
    this.melamineColorName = 'Roble Bardolino',
    this.melamineColor = const Color(0xFFC4A482),
    this.internalEdgeType = EdgeType.delgado045,
    this.frontEdgeType = EdgeType.grueso2mm,
    this.zocaloHeight = 80.0,
  });

  static const List<MelamineColorOption> availableColors = [
    MelamineColorOption(
      name: 'Blanco Glaciar',
      previewColor: Color(0xFFF5F5F5),
      textColor: Colors.black87,
    ),
    MelamineColorOption(
      name: 'Roble Bardolino',
      previewColor: Color(0xFFC8A579),
      textColor: Colors.black87,
    ),
    MelamineColorOption(
      name: 'Nogal Terracota',
      previewColor: Color(0xFF6E432A),
      textColor: Colors.white,
    ),
    MelamineColorOption(
      name: 'Gris Humo',
      previewColor: Color(0xFF757575),
      textColor: Colors.white,
    ),
    MelamineColorOption(
      name: 'Negro Mate',
      previewColor: Color(0xFF212121),
      textColor: Colors.white,
    ),
    MelamineColorOption(
      name: 'Cedro Natural',
      previewColor: Color(0xFF9E572E),
      textColor: Colors.white,
    ),
  ];

  static FurnitureModel fromPreset(FurniturePreset preset) {
    switch (preset) {
      case FurniturePreset.muebleBajoCocina:
        return const FurnitureModel(
          name: 'Mueble Bajo de Cocina',
          preset: FurniturePreset.muebleBajoCocina,
          height: 850,
          width: 1200,
          depth: 580,
          doorsCount: 2,
          doorType: DoorType.batiente,
          drawersCount: 3,
          shelvesFixedCount: 0,
          shelvesMobileCount: 1,
          verticalDividersCount: 1,
          hasBacking: true,
          backingType: BackingType.mdf3mm,
          melamineThickness: 18.0,
          melamineColorName: 'Blanco Glaciar',
          melamineColor: Color(0xFFF5F5F5),
          zocaloHeight: 100.0,
        );

      case FurniturePreset.roperoCloset:
        return const FurnitureModel(
          name: 'Ropero / Clóset 2 Cuerpos',
          preset: FurniturePreset.roperoCloset,
          height: 2100,
          width: 1600,
          depth: 550,
          doorsCount: 4,
          doorType: DoorType.batiente,
          drawersCount: 4,
          shelvesFixedCount: 2,
          shelvesMobileCount: 4,
          verticalDividersCount: 1,
          hasBacking: true,
          backingType: BackingType.mdf3mm,
          melamineThickness: 18.0,
          melamineColorName: 'Roble Bardolino',
          melamineColor: Color(0xFFC8A579),
          zocaloHeight: 80.0,
        );

      case FurniturePreset.repiseroLibrero:
        return const FurnitureModel(
          name: 'Repisero / Librero Moderno',
          preset: FurniturePreset.repiseroLibrero,
          height: 1900,
          width: 900,
          depth: 320,
          doorsCount: 0,
          doorType: DoorType.batiente,
          drawersCount: 0,
          shelvesFixedCount: 2,
          shelvesMobileCount: 3,
          verticalDividersCount: 0,
          hasBacking: true,
          backingType: BackingType.mdf3mm,
          melamineThickness: 18.0,
          melamineColorName: 'Nogal Terracota',
          melamineColor: Color(0xFF6E432A),
          zocaloHeight: 70.0,
        );

      case FurniturePreset.escritorio:
        return const FurnitureModel(
          name: 'Escritorio con Cajonera',
          preset: FurniturePreset.escritorio,
          height: 750,
          width: 1300,
          depth: 600,
          doorsCount: 0,
          doorType: DoorType.batiente,
          drawersCount: 3,
          shelvesFixedCount: 1,
          shelvesMobileCount: 0,
          verticalDividersCount: 1,
          hasBacking: false,
          backingType: BackingType.none,
          melamineThickness: 18.0,
          melamineColorName: 'Gris Humo',
          melamineColor: Color(0xFF757575),
          zocaloHeight: 0.0,
        );

      case FurniturePreset.personalizado:
        return const FurnitureModel(
          name: 'Mueble a Medida Personalizado',
          preset: FurniturePreset.personalizado,
          height: 1000,
          width: 1000,
          depth: 450,
          doorsCount: 2,
          doorType: DoorType.batiente,
          drawersCount: 2,
          shelvesFixedCount: 1,
          shelvesMobileCount: 1,
          verticalDividersCount: 0,
          hasBacking: true,
          backingType: BackingType.mdf3mm,
          melamineThickness: 18.0,
          melamineColorName: 'Roble Bardolino',
          melamineColor: Color(0xFFC8A579),
          zocaloHeight: 80.0,
        );
    }
  }

  FurnitureModel copyWith({
    String? name,
    FurniturePreset? preset,
    double? height,
    double? width,
    double? depth,
    int? doorsCount,
    DoorType? doorType,
    int? drawersCount,
    int? shelvesFixedCount,
    int? shelvesMobileCount,
    int? verticalDividersCount,
    bool? hasBacking,
    BackingType? backingType,
    double? melamineThickness,
    String? melamineColorName,
    Color? melamineColor,
    EdgeType? internalEdgeType,
    EdgeType? frontEdgeType,
    double? zocaloHeight,
  }) {
    return FurnitureModel(
      name: name ?? this.name,
      preset: preset ?? this.preset,
      height: height ?? this.height,
      width: width ?? this.width,
      depth: depth ?? this.depth,
      doorsCount: doorsCount ?? this.doorsCount,
      doorType: doorType ?? this.doorType,
      drawersCount: drawersCount ?? this.drawersCount,
      shelvesFixedCount: shelvesFixedCount ?? this.shelvesFixedCount,
      shelvesMobileCount: shelvesMobileCount ?? this.shelvesMobileCount,
      verticalDividersCount: verticalDividersCount ?? this.verticalDividersCount,
      hasBacking: hasBacking ?? this.hasBacking,
      backingType: backingType ?? this.backingType,
      melamineThickness: melamineThickness ?? this.melamineThickness,
      melamineColorName: melamineColorName ?? this.melamineColorName,
      melamineColor: melamineColor ?? this.melamineColor,
      internalEdgeType: internalEdgeType ?? this.internalEdgeType,
      frontEdgeType: frontEdgeType ?? this.frontEdgeType,
      zocaloHeight: zocaloHeight ?? this.zocaloHeight,
    );
  }
}

