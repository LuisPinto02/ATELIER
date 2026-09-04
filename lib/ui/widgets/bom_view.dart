import 'package:flutter/material.dart';
import '../../models/cut_piece_model.dart';
import '../../models/furniture_model.dart';
import '../../services/bom_engine.dart';

class BomView extends StatelessWidget {
  final BomResult bom;

  const BomView({super.key, required this.bom});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context),
          const SizedBox(height: 16),
          _buildCutlistTable(context),
          const SizedBox(height: 20),
          _buildHardwareTable(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildMetricCard(
              context: context,
              title: 'Canto Delgado (0.45mm)',
              value: '${bom.totalThinEdgeMeters.toStringAsFixed(1)} m',
              subtitle: 'Interiores y repisas',
              icon: Icons.linear_scale_rounded,
              color: Colors.teal,
              width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 3,
            ),
            _buildMetricCard(
              context: context,
              title: 'Canto Grueso (2.0mm)',
              value: '${bom.totalThickEdgeMeters.toStringAsFixed(1)} m',
              subtitle: 'Puertas y frentes vistos',
              icon: Icons.line_weight_rounded,
              color: Colors.indigo,
              width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 3,
            ),
            _buildMetricCard(
              context: context,
              title: 'Superficie de Piezas',
              value: '${bom.totalMelamineAreaM2.toStringAsFixed(2)} m²',
              subtitle: 'Melamina neta (+ ${bom.totalBackingAreaM2.toStringAsFixed(2)} m² fondo)',
              icon: Icons.square_foot_rounded,
              color: Colors.deepOrange,
              width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 3,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 11.5, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                    Text(subtitle, style: TextStyle(fontSize: 10.5, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCutlistTable(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_list_numbered_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Despiece Técnico de Madera (Cutlist)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${bom.pieces.fold(0, (sum, p) => sum + p.quantity)} piezas totales',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 38,
                dataRowMaxHeight: 48,
                horizontalMargin: 12,
                columnSpacing: 16,
                headingRowColor: WidgetStateProperty.all(Colors.blueGrey.withAlpha(25)),
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Pieza', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cant.', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Largo (mm)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Ancho (mm)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Esp.', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cantos (L1/L2/A1/A2)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Ajuste / Notas Técnicas', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: bom.pieces.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final piece = entry.value;

                  return DataRow(
                    cells: [
                      DataCell(Text('$idx', style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (piece.isBacking)
                              const Icon(Icons.layers_outlined, size: 14, color: Colors.brown)
                            else
                              const Icon(Icons.crop_square_rounded, size: 14, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text(piece.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${piece.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataCell(Text('${piece.length.toInt()}')),
                      DataCell(Text('${piece.width.toInt()}')),
                      DataCell(Text('${piece.thickness.toInt()}')),
                      DataCell(_buildEdgeBadges(piece)),
                      DataCell(Text(piece.notes, style: TextStyle(fontSize: 11.5, color: Colors.grey[700]))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEdgeBadges(CutPiece piece) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _edgeBadge('L1', piece.cantoL1),
        const SizedBox(width: 3),
        _edgeBadge('L2', piece.cantoL2),
        const SizedBox(width: 6),
        _edgeBadge('A1', piece.cantoA1),
        const SizedBox(width: 3),
        _edgeBadge('A2', piece.cantoA2),
      ],
    );
  }

  Widget _edgeBadge(String side, EdgeType edge) {
    Color bg;
    Color fg;
    String text;

    switch (edge) {
      case EdgeType.none:
        bg = Colors.grey.withAlpha(40);
        fg = Colors.grey[600]!;
        text = '-';
        break;
      case EdgeType.delgado045:
        bg = Colors.teal.withAlpha(40);
        fg = Colors.teal[800]!;
        text = 'D';
        break;
      case EdgeType.grueso2mm:
        bg = Colors.indigo.withAlpha(40);
        fg = Colors.indigo[800]!;
        text = 'G';
        break;
    }

    return Tooltip(
      message: '$side: ${edge.label}',
      child: Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(text, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: fg)),
      ),
    );
  }

  Widget _buildHardwareTable(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Consumo de Herrajes y Consumibles',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 38,
                dataRowMaxHeight: 48,
                horizontalMargin: 12,
                columnSpacing: 20,
                headingRowColor: WidgetStateProperty.all(Colors.blueGrey.withAlpha(25)),
                columns: const [
                  DataColumn(label: Text('Herraje / Insumo', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('P. Unit (Bs)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Subtotal (Bs)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Criterio de Cálculo', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: bom.hardware.map((hw) {
                  return DataRow(
                    cells: [
                      DataCell(Text(hw.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(hw.category)),
                      DataCell(Text(
                        '${hw.quantity % 1 == 0 ? hw.quantity.toInt() : hw.quantity.toStringAsFixed(1)} ${hw.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text('Bs ${hw.unitPriceBs.toStringAsFixed(2)}')),
                      DataCell(Text('Bs ${hw.subtotalBs.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(hw.details, style: TextStyle(fontSize: 11.5, color: Colors.grey[700]))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

