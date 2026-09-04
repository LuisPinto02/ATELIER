import 'furniture_model.dart';

class CutPiece {
  final String id;
  final String name;
  final double length; // Largo en mm
  final double width;  // Ancho en mm
  final double thickness; // Espesor en mm
  final int quantity;
  final EdgeType cantoL1; // Canto en Largo 1
  final EdgeType cantoL2; // Canto en Largo 2
  final EdgeType cantoA1; // Canto en Ancho 1
  final EdgeType cantoA2; // Canto en Ancho 2
  final String notes;
  final bool isBacking; // true si es MDF fondo (3mm / 5mm)

  const CutPiece({
    required this.id,
    required this.name,
    required this.length,
    required this.width,
    required this.thickness,
    this.quantity = 1,
    this.cantoL1 = EdgeType.none,
    this.cantoL2 = EdgeType.none,
    this.cantoA1 = EdgeType.none,
    this.cantoA2 = EdgeType.none,
    this.notes = '',
    this.isBacking = false,
  });

  // Superficie total de todas las unidades de esta pieza en m²
  double get totalAreaM2 => (length * width * quantity) / 1000000.0;

  // Metros lineales de tapacanto delgado (0.45mm) para todas las unidades
  double get linearMetersEdgeThin {
    double totalMmPerUnit = 0;
    if (cantoL1 == EdgeType.delgado045) totalMmPerUnit += length;
    if (cantoL2 == EdgeType.delgado045) totalMmPerUnit += length;
    if (cantoA1 == EdgeType.delgado045) totalMmPerUnit += width;
    if (cantoA2 == EdgeType.delgado045) totalMmPerUnit += width;
    return (totalMmPerUnit * quantity) / 1000.0;
  }

  // Metros lineales de tapacanto grueso (2.0mm) para todas las unidades
  double get linearMetersEdgeThick {
    double totalMmPerUnit = 0;
    if (cantoL1 == EdgeType.grueso2mm) totalMmPerUnit += length;
    if (cantoL2 == EdgeType.grueso2mm) totalMmPerUnit += length;
    if (cantoA1 == EdgeType.grueso2mm) totalMmPerUnit += width;
    if (cantoA2 == EdgeType.grueso2mm) totalMmPerUnit += width;
    return (totalMmPerUnit * quantity) / 1000.0;
  }

  String get edgeSummary {
    final l1 = cantoL1.shortLabel;
    final l2 = cantoL2.shortLabel;
    final a1 = cantoA1.shortLabel;
    final a2 = cantoA2.shortLabel;
    return 'L:[$l1 / $l2]  A:[$a1 / $a2]';
  }

  CutPiece copyWith({
    String? id,
    String? name,
    double? length,
    double? width,
    double? thickness,
    int? quantity,
    EdgeType? cantoL1,
    EdgeType? cantoL2,
    EdgeType? cantoA1,
    EdgeType? cantoA2,
    String? notes,
    bool? isBacking,
  }) {
    return CutPiece(
      id: id ?? this.id,
      name: name ?? this.name,
      length: length ?? this.length,
      width: width ?? this.width,
      thickness: thickness ?? this.thickness,
      quantity: quantity ?? this.quantity,
      cantoL1: cantoL1 ?? this.cantoL1,
      cantoL2: cantoL2 ?? this.cantoL2,
      cantoA1: cantoA1 ?? this.cantoA1,
      cantoA2: cantoA2 ?? this.cantoA2,
      notes: notes ?? this.notes,
      isBacking: isBacking ?? this.isBacking,
    );
  }
}

