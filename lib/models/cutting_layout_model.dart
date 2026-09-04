import 'cut_piece_model.dart';

class PlacedPiece {
  final CutPiece piece;
  final int instanceIndex;
  final double x; // en mm desde esquina superior izquierda
  final double y; // en mm
  final double cutLength; // dimensión en eje X (mm)
  final double cutWidth;  // dimensión en eje Y (mm)
  final bool isRotated;

  const PlacedPiece({
    required this.piece,
    required this.instanceIndex,
    required this.x,
    required this.y,
    required this.cutLength,
    required this.cutWidth,
    required this.isRotated,
  });

  double get areaM2 => (cutLength * cutWidth) / 1000000.0;
}

class BoardLayout {
  final int boardIndex; // 1, 2, ...
  final String materialName;
  final double boardLengthMm;
  final double boardWidthMm;
  final List<PlacedPiece> placedPieces;
  final double kerfMm;

  const BoardLayout({
    required this.boardIndex,
    required this.materialName,
    required this.boardLengthMm,
    required this.boardWidthMm,
    required this.placedPieces,
    this.kerfMm = 4.0,
  });

  double get totalBoardAreaM2 => (boardLengthMm * boardWidthMm) / 1000000.0;

  double get usedAreaM2 {
    double sum = 0;
    for (final p in placedPieces) {
      sum += p.areaM2;
    }
    return sum;
  }

  double get wasteAreaM2 => (totalBoardAreaM2 - usedAreaM2).clamp(0.0, double.infinity);

  double get wastePercent {
    if (totalBoardAreaM2 == 0) return 0;
    return ((wasteAreaM2 / totalBoardAreaM2) * 100.0).clamp(0.0, 100.0);
  }

  double get efficiencyPercent => 100.0 - wastePercent;
}

class OptimizationResult {
  final List<BoardLayout> melamineBoards;
  final List<BoardLayout> backingBoards;
  final int totalMelamineBoardsNeeded;
  final int totalBackingBoardsNeeded;
  final double totalUsefulAreaM2;
  final double totalBoardAreaM2;
  final double overallWastePercent;
  final double overallEfficiencyPercent;
  final List<CutPiece> unplacedPieces;

  const OptimizationResult({
    required this.melamineBoards,
    required this.backingBoards,
    required this.totalMelamineBoardsNeeded,
    required this.totalBackingBoardsNeeded,
    required this.totalUsefulAreaM2,
    required this.totalBoardAreaM2,
    required this.overallWastePercent,
    required this.overallEfficiencyPercent,
    this.unplacedPieces = const [],
  });
}

