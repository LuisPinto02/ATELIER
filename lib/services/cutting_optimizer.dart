import '../models/cut_piece_model.dart';
import '../models/cutting_layout_model.dart';
import '../models/workshop_catalog_model.dart';

class _FreeRect {
  double x;
  double y;
  double width;
  double height;

  _FreeRect(this.x, this.y, this.width, this.height);

  double get area => width * height;
}

class CuttingOptimizer {
  /// Optimiza la distribución de piezas en planchas estándar utilizando Guillotine Bin Packing
  static OptimizationResult optimize({
    required List<CutPiece> pieces,
    required WorkshopCatalog catalog,
    double boardLengthMm = 2750.0,
    double boardWidthMm = 1830.0,
    double kerfMm = 4.0,
  }) {
    final melaminePieces = pieces.where((p) => !p.isBacking).toList();
    final backingPieces = pieces.where((p) => p.isBacking).toList();

    final melamineLayouts = _packPieces(
      pieces: melaminePieces,
      boardLength: boardLengthMm,
      boardWidth: boardWidthMm,
      kerf: kerfMm,
      materialName: 'Melamina Estándar (${boardLengthMm.toInt()} x ${boardWidthMm.toInt()} mm)',
    );

    final backingLayouts = _packPieces(
      pieces: backingPieces,
      boardLength: boardLengthMm,
      boardWidth: boardWidthMm,
      kerf: kerfMm,
      materialName: 'Fondo MDF 3mm (${boardLengthMm.toInt()} x ${boardWidthMm.toInt()} mm)',
    );

    double totalUsefulArea = 0;
    for (final p in pieces) {
      totalUsefulArea += p.totalAreaM2;
    }

    final totalMelamineBoards = melamineLayouts.length;
    final totalBackingBoards = backingLayouts.length;
    final totalBoardArea = (totalMelamineBoards + totalBackingBoards) *
        ((boardLengthMm * boardWidthMm) / 1000000.0);

    double overallWaste = 0;
    if (totalBoardArea > 0) {
      overallWaste = (((totalBoardArea - totalUsefulArea) / totalBoardArea) * 100.0).clamp(0.0, 100.0);
    }
    final overallEfficiency = 100.0 - overallWaste;

    return OptimizationResult(
      melamineBoards: melamineLayouts,
      backingBoards: backingLayouts,
      totalMelamineBoardsNeeded: totalMelamineBoards == 0 && melaminePieces.isNotEmpty ? 1 : totalMelamineBoards,
      totalBackingBoardsNeeded: totalBackingBoards == 0 && backingPieces.isNotEmpty ? 1 : totalBackingBoards,
      totalUsefulAreaM2: totalUsefulArea,
      totalBoardAreaM2: totalBoardArea,
      overallWastePercent: overallWaste,
      overallEfficiencyPercent: overallEfficiency,
    );
  }

  static List<BoardLayout> _packPieces({
    required List<CutPiece> pieces,
    required double boardLength,
    required double boardWidth,
    required double kerf,
    required String materialName,
  }) {
    if (pieces.isEmpty) return [];

    // Desglosar en instancias individuales
    final List<_PieceInstance> instances = [];
    for (final p in pieces) {
      for (int i = 0; i < p.quantity; i++) {
        instances.add(_PieceInstance(piece: p, instanceIndex: i + 1));
      }
    }

    // Ordenar de mayor a menor superficie (Best-Fit Decreasing)
    instances.sort((a, b) => b.area.compareTo(a.area));

    final List<BoardLayout> boards = [];
    final List<_PieceInstance> remaining = List.from(instances);

    int boardCounter = 1;
    while (remaining.isNotEmpty) {
      final List<PlacedPiece> placedInBoard = [];
      final List<_FreeRect> freeRectangles = [_FreeRect(0, 0, boardLength, boardWidth)];
      final List<_PieceInstance> stillUnplaced = [];

      for (final inst in remaining) {
        bool placed = false;
        int bestRectIndex = -1;
        double minRemainderArea = double.infinity;
        bool bestRotated = false;
        double bestW = 0;
        double bestH = 0;

        // Buscar el mejor rectángulo libre donde quepa
        for (int r = 0; r < freeRectangles.length; r++) {
          final fr = freeRectangles[r];

          // Orientación normal
          if (inst.length <= fr.width && inst.width <= fr.height) {
            final remainderArea = (fr.width * fr.height) - (inst.length * inst.width);
            if (remainderArea < minRemainderArea) {
              minRemainderArea = remainderArea;
              bestRectIndex = r;
              bestRotated = false;
              bestW = inst.length;
              bestH = inst.width;
            }
          }

          // Orientación rotada 90°
          if (inst.width <= fr.width && inst.length <= fr.height) {
            final remainderArea = (fr.width * fr.height) - (inst.width * inst.length);
            if (remainderArea < minRemainderArea) {
              minRemainderArea = remainderArea;
              bestRectIndex = r;
              bestRotated = true;
              bestW = inst.width;
              bestH = inst.length;
            }
          }
        }

        if (bestRectIndex != -1) {
          final fr = freeRectangles.removeAt(bestRectIndex);
          placedInBoard.add(PlacedPiece(
            piece: inst.piece,
            instanceIndex: inst.instanceIndex,
            x: fr.x,
            y: fr.y,
            cutLength: bestW,
            cutWidth: bestH,
            isRotated: bestRotated,
          ));

          // Corte Guillotina: partir el rectángulo libre sobrante
          final rightW = fr.width - bestW - kerf;
          final rightH = fr.height;
          final topW = bestW;
          final topH = fr.height - bestH - kerf;

          // Guillotine Split Rule (Shorter Axis Split)
          if (rightW > 0 && fr.height > 0) {
            freeRectangles.add(_FreeRect(fr.x + bestW + kerf, fr.y, rightW, rightH));
          }
          if (topW > 0 && topH > 0) {
            freeRectangles.add(_FreeRect(fr.x, fr.y + bestH + kerf, topW, topH));
          }

          placed = true;
        }

        if (!placed) {
          stillUnplaced.add(inst);
        }
      }

      if (placedInBoard.isEmpty && stillUnplaced.isNotEmpty) {
        // La pieza excede la plancha completa, la forzamos en tablero especial para visualización
        final oversized = stillUnplaced.removeAt(0);
        placedInBoard.add(PlacedPiece(
          piece: oversized.piece,
          instanceIndex: oversized.instanceIndex,
          x: 0,
          y: 0,
          cutLength: oversized.length.clamp(100.0, boardLength),
          cutWidth: oversized.width.clamp(100.0, boardWidth),
          isRotated: false,
        ));
      }

      boards.add(BoardLayout(
        boardIndex: boardCounter++,
        materialName: materialName,
        boardLengthMm: boardLength,
        boardWidthMm: boardWidth,
        placedPieces: placedInBoard,
        kerfMm: kerf,
      ));

      remaining.clear();
      remaining.addAll(stillUnplaced);
    }

    return boards;
  }
}

class _PieceInstance {
  final CutPiece piece;
  final int instanceIndex;

  _PieceInstance({required this.piece, required this.instanceIndex});

  double get length => piece.length;
  double get width => piece.width;
  double get area => piece.length * piece.width;
}

