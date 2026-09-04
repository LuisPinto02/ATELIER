import 'package:flutter/material.dart';
import '../../models/cutting_layout_model.dart';
import '../painters/cutting_board_painter.dart';

class CuttingView extends StatefulWidget {
  final OptimizationResult optimization;

  const CuttingView({super.key, required this.optimization});

  @override
  State<CuttingView> createState() => _CuttingViewState();
}

class _CuttingViewState extends State<CuttingView> {
  int _selectedBoardIndex = 0;
  bool _showingMelamine = true;
  PlacedPiece? _selectedPiece;

  @override
  Widget build(BuildContext context) {
    final boards = _showingMelamine
        ? widget.optimization.melamineBoards
        : widget.optimization.backingBoards;

    final currentBoard = boards.isNotEmpty && _selectedBoardIndex < boards.length
        ? boards[_selectedBoardIndex]
        : (boards.isNotEmpty ? boards.first : null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptimizationMetrics(context),
          const SizedBox(height: 16),
          _buildBoardControlBar(context, boards),
          const SizedBox(height: 12),
          if (currentBoard != null) ...[
            _buildCanvasCard(context, currentBoard),
            const SizedBox(height: 16),
            _buildPlacedPiecesList(context, currentBoard),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No hay piezas asignadas para este material.'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptimizationMetrics(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final cardW = isNarrow ? (constraints.maxWidth - 8) / 2 : (constraints.maxWidth - 24) / 4;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMetricTile(
              title: 'Planchas Melamina',
              value: '${widget.optimization.totalMelamineBoardsNeeded} un.',
              subtitle: '2750 x 1830 mm',
              icon: Icons.layers_rounded,
              color: Colors.blue.shade700,
              width: cardW,
            ),
            _buildMetricTile(
              title: 'Planchas Fondo MDF',
              value: '${widget.optimization.totalBackingBoardsNeeded} un.',
              subtitle: 'Fondo 3mm / 5mm',
              icon: Icons.line_style_rounded,
              color: Colors.brown.shade600,
              width: cardW,
            ),
            _buildMetricTile(
              title: 'Aprovechamiento',
              value: '${widget.optimization.overallEfficiencyPercent.toStringAsFixed(1)}%',
              subtitle: 'Superficie útil',
              icon: Icons.pie_chart_rounded,
              color: Colors.green.shade700,
              width: cardW,
            ),
            _buildMetricTile(
              title: 'Desperdicio (Scrap)',
              value: '${widget.optimization.overallWastePercent.toStringAsFixed(1)}%',
              subtitle: 'Incluye Kerf disco 4mm',
              icon: Icons.delete_outline_rounded,
              color: widget.optimization.overallWastePercent > 25 ? Colors.red.shade700 : Colors.amber.shade800,
              width: cardW,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(subtitle, style: TextStyle(fontSize: 10.5, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardControlBar(BuildContext context, List<BoardLayout> boards) {
    return Row(
      children: [
        // Selector Melamina vs Fondo
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: true,
              label: Text('Melamina (${widget.optimization.totalMelamineBoardsNeeded})'),
              icon: const Icon(Icons.table_restaurant_rounded, size: 16),
            ),
            ButtonSegment(
              value: false,
              label: Text('Fondo 3mm (${widget.optimization.totalBackingBoardsNeeded})'),
              icon: const Icon(Icons.layers_rounded, size: 16),
            ),
          ],
          selected: {_showingMelamine},
          onSelectionChanged: (set) {
            if (set.isNotEmpty) {
              setState(() {
                _showingMelamine = set.first;
                _selectedBoardIndex = 0;
                _selectedPiece = null;
              });
            }
          },
        ),
        const Spacer(),
        // Selector de número de tablero si hay más de 1
        if (boards.length > 1) ...[
          const Text('Tablero: ', style: TextStyle(fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 6,
            children: List.generate(boards.length, (idx) {
              final isCur = _selectedBoardIndex == idx;
              return ChoiceChip(
                label: Text('${idx + 1}'),
                selected: isCur,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _selectedBoardIndex = idx;
                      _selectedPiece = null;
                    });
                  }
                },
                visualDensity: VisualDensity.compact,
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildCanvasCard(BuildContext context, BoardLayout board) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.crop_free_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Simulador de Corte Guillotina - Plancha #${board.boardIndex}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Spacer(),
                Text(
                  '${board.placedPieces.length} piezas | Scrap: ${board.wastePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: board.wastePercent > 25 ? Colors.red : Colors.teal[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Distribución 2D de cortes longitudinales y transversales con sierra circular (Disco ${board.kerfMm} mm). Usa zoom o pellizco para acercar.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
            ),
            const SizedBox(height: 14),
            // Canvas interactivo con CustomPainter
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              height: 380,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  maxScale: 5.0,
                  minScale: 0.8,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: AspectRatio(
                        // Proporción estándar del tablero 2750 x 1830 mm = 1.5027
                        aspectRatio: board.boardLengthMm / board.boardWidthMm,
                        child: CustomPaint(
                          painter: CuttingBoardPainter(
                            boardLayout: board,
                            selectedPiece: _selectedPiece,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacedPiecesList(BuildContext context, BoardLayout board) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Piezas Ubicadas en esta Plancha',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: board.placedPieces.map((p) {
                final isSel = _selectedPiece == p;
                return ActionChip(
                  avatar: Icon(
                    p.isRotated ? Icons.rotate_right_rounded : Icons.crop_portrait_rounded,
                    size: 16,
                    color: isSel ? Colors.white : Colors.blueGrey,
                  ),
                  label: Text('${p.piece.name} (${p.cutLength.toInt()} x ${p.cutWidth.toInt()})'),
                  backgroundColor: isSel ? Theme.of(context).colorScheme.primary : null,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedPiece = isSel ? null : p;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

