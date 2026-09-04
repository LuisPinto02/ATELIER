import 'package:flutter/material.dart';
import '../../models/cutting_layout_model.dart';

class CuttingBoardPainter extends CustomPainter {
  final BoardLayout boardLayout;
  final PlacedPiece? selectedPiece;

  CuttingBoardPainter({
    required this.boardLayout,
    this.selectedPiece,
  });

  static const List<Color> _piecePalette = [
    Color(0xFF1E88E5), // Blue
    Color(0xFF43A047), // Green
    Color(0xFFFB8C00), // Orange
    Color(0xFF8E24AA), // Purple
    Color(0xFF00ACC1), // Cyan
    Color(0xFFE53935), // Red
    Color(0xFF3949AB), // Indigo
    Color(0xFF00897B), // Teal
    Color(0xFFD81B60), // Pink
    Color(0xFF5E35B1), // Deep purple
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final boardW = boardLayout.boardLengthMm;
    final boardH = boardLayout.boardWidthMm;

    if (boardW <= 0 || boardH <= 0) return;

    // Calcular escala uniforme para que el tablero quepa centrado
    final scaleX = size.width / boardW;
    final scaleY = size.height / boardH;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final renderedW = boardW * scale;
    final renderedH = boardH * scale;

    final offsetX = (size.width - renderedW) / 2;
    final offsetY = (size.height - renderedH) / 2;

    // 1. DIBUJAR FONDO DEL TABLERO / DESPERDICIO (SCRAP)
    final boardRect = Rect.fromLTWH(offsetX, offsetY, renderedW, renderedH);

    final wastePaint = Paint()
      ..color = const Color(0xFFECEFF1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(boardRect, wastePaint);

    // Borde exterior del tablero (chapa de melamina)
    final boardBorderPaint = Paint()
      ..color = const Color(0xFF455A64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRect(boardRect, boardBorderPaint);

    // 2. DIBUJAR PIEZAS UBICADAS
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final selectedPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    int colorIdx = 0;
    for (final p in boardLayout.placedPieces) {
      final px = offsetX + (p.x * scale);
      final py = offsetY + (p.y * scale);
      final pw = p.cutLength * scale;
      final ph = p.cutWidth * scale;
      final pieceRect = Rect.fromLTWH(px, py, pw, ph);

      // Color de relleno según tipo de pieza
      final color = _piecePalette[colorIdx % _piecePalette.length];
      colorIdx++;

      final fillPaint = Paint()
        ..color = color.withAlpha(210)
        ..style = PaintingStyle.fill;
      canvas.drawRect(pieceRect, fillPaint);

      // Borde de la pieza
      if (selectedPiece == p) {
        canvas.drawRect(pieceRect, selectedPaint);
      } else {
        canvas.drawRect(pieceRect, borderPaint);
      }

      // Dibujar línea de disco de corte (Kerf) alrededor
      final kerfW = boardLayout.kerfMm * scale;
      if (kerfW > 0.5) {
        final kerfPaint = Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = kerfW.clamp(0.5, 3.0);
        canvas.drawRect(Rect.fromLTWH(px - (kerfW / 2), py - (kerfW / 2), pw + kerfW, ph + kerfW), kerfPaint);
      }

      // TEXTO INFORMATIVO DENTRO DE LA PIEZA
      if (pw > 30 && ph > 18) {
        final textSpan = TextSpan(
          text: '${p.piece.name}\n${p.cutLength.toInt()} x ${p.cutWidth.toInt()} mm',
          style: TextStyle(
            color: Colors.white,
            fontSize: (ph * 0.22).clamp(8.0, 12.0),
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1)),
            ],
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: 2,
          ellipsis: '...',
        );
        textPainter.layout(maxWidth: pw - 4);

        final textOffset = Offset(
          px + (pw - textPainter.width) / 2,
          py + (ph - textPainter.height) / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // 3. REGLA / MEDIDAS GENERALES EN EL BORDE
    final dimStyle = TextStyle(
      color: Colors.blueGrey[800],
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    final topDim = TextPainter(
      text: TextSpan(text: '${boardW.toInt()} mm (Largo Plancha)', style: dimStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    topDim.paint(canvas, Offset(offsetX + (renderedW - topDim.width) / 2, offsetY - 14));

    final sideDim = TextPainter(
      text: TextSpan(text: '${boardH.toInt()} mm (Ancho)', style: dimStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    sideDim.paint(canvas, Offset(offsetX - sideDim.width - 6, offsetY + (renderedH - sideDim.height) / 2));
  }

  @override
  bool shouldRepaint(covariant CuttingBoardPainter oldDelegate) {
    return oldDelegate.boardLayout != boardLayout || oldDelegate.selectedPiece != selectedPiece;
  }
}

