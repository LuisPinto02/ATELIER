import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/furniture_model.dart';
import '../../models/cost_breakdown_model.dart';
import '../../models/cutting_layout_model.dart';
import '../../services/bom_engine.dart';

class QuotationView extends StatefulWidget {
  final FurnitureModel furniture;
  final BomResult bom;
  final CostBreakdownModel cost;
  final OptimizationResult optimization;

  const QuotationView({
    super.key,
    required this.furniture,
    required this.bom,
    required this.cost,
    required this.optimization,
  });

  @override
  State<QuotationView> createState() => _QuotationViewState();
}

class _QuotationViewState extends State<QuotationView> {
  bool _isClientView = true; // true = Vista Cliente, false = Vista Taller
  final String _clientName = 'Juan Pérez';
  final String _clientPhone = '+591 700-12345';
  final String _quoteNumber = 'COT-2026-084';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildViewSelector(context),
          const SizedBox(height: 16),
          if (_isClientView)
            _buildClientCommercialQuote(context)
          else
            _buildWorkshopProductionSheet(context),
        ],
      ),
    );
  }

  Widget _buildViewSelector(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Vista Cliente (Comercial)'),
                  icon: Icon(Icons.person_pin_rounded, size: 18),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Vista Taller (Ficha Técnica)'),
                  icon: Icon(Icons.precision_manufacturing_rounded, size: 18),
                ),
              ],
              selected: {_isClientView},
              onSelectionChanged: (set) {
                if (set.isNotEmpty) {
                  setState(() {
                    _isClientView = set.first;
                  });
                }
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copiar Propuesta'),
              onPressed: () => _copyProposalToClipboard(context),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              icon: const Icon(Icons.print_rounded, size: 16),
              label: const Text('Imprimir / PDF'),
              onPressed: () => _showPrintPreviewDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  // VISTA CLIENTE: COTIZACIÓN COMERCIAL PROFESIONAL (Sin desgloses internos de costo)
  Widget _buildClientCommercialQuote(BuildContext context) {
    final f = widget.furniture;
    final c = widget.cost;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Membrete del taller
            _buildWorkshopHeader(context),
            const Divider(height: 32, thickness: 1.5),

            // Datos del Cliente y Presupuesto
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PREPARADO PARA:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(_clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Contacto: $_clientPhone', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('N° Cotización: $_quoteNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Fecha: 03/09/2026', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    const Text('Validez: 15 días calendario', style: TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Resumen del Mueble y Especificaciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_box_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        f.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSpecRow('Dimensiones Totales', '${f.height.toInt()} mm (Alto) × ${f.width.toInt()} mm (Ancho) × ${f.depth.toInt()} mm (Prof.)'),
                  _buildSpecRow('Material Principal', 'Melamina ${f.melamineThickness.toInt()} mm - Tono "${f.melamineColorName}"'),
                  _buildSpecRow('Acabado de Bordes', 'Tapacanto PVC termofusionado de 2.0 mm en frentes/puertas'),
                  _buildSpecRow('Puertas', f.doorsCount > 0 ? '${f.doorsCount} puertas ${f.doorType.name}s con bisagras cierre suave' : 'Sin puertas (módulo abierto)'),
                  _buildSpecRow('Cajones', f.drawersCount > 0 ? '${f.drawersCount} cajones con correderas telescópicas reforzadas' : 'Sin cajones'),
                  _buildSpecRow('Distribución Interna', '${f.shelvesFixedCount} repisas fijas, ${f.shelvesMobileCount} graduables, ${f.verticalDividersCount} divisiones'),
                  _buildSpecRow('Garantía y Armado', 'Incluye armado en obra, herrajes de primera línea y 1 año de garantía'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // PRECIO FINAL DE VENTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRECIO TOTAL DE VENTA',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      Text(
                        'Materiales, herrajes, transporte e instalación incluidos',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Bs ${c.activePriceBs.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Condiciones Comerciales
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Condiciones Comerciales y de Pago:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 6),
                  Text('• 50% de anticipo para firma de contrato y habilitación de compra de materiales.'),
                  Text('• 50% restante contra entrega e instalación a entera satisfacción.'),
                  Text('• Tiempo estimado de fabricación: 7 a 10 días hábiles a partir del anticipo.'),
                  Text('• Validez de la oferta: 15 días calendario a partir de la fecha de emisión.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // VISTA TALLER: FICHA TÉCNICA DE PRODUCCIÓN Y DESPIECE
  Widget _buildWorkshopProductionSheet(BuildContext context) {
    final f = widget.furniture;
    final b = widget.bom;
    final c = widget.cost;
    final opt = widget.optimization;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera Técnica
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.precision_manufacturing_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FICHA TÉCNICA DE PRODUCCIÓN - TALLER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey[900])),
                    Text('Mueble: ${f.name} (${f.height.toInt()}x${f.width.toInt()}x${f.depth.toInt()} mm) | Color: ${f.melamineColorName}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.teal)),
                  child: Text('Margen Proyectado: ${c.actualMarginPercent.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                ),
              ],
            ),
            const Divider(height: 24),

            // Requerimiento Consolidado de Insumos para Proveeduría
            const Text('1. Insumos y Tableros para Proveeduría / Compra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
              child: Column(
                children: [
                  _buildWorkshopItemRow('Planchas Melamina (${f.melamineThickness.toInt()} mm)', '${opt.totalMelamineBoardsNeeded} planchas estándar 2750 x 1830 mm'),
                  if (f.hasBacking)
                    _buildWorkshopItemRow('Planchas Fondo MDF (3 mm)', '${opt.totalBackingBoardsNeeded} plancha 2750 x 1830 mm'),
                  _buildWorkshopItemRow('Tapacanto Delgado 0.60 mm', '${c.thinEdgeLinearMeters.toStringAsFixed(1)} metros lineales (incluye 10% merma)'),
                  _buildWorkshopItemRow('Tapacanto Grueso 1.50 mm', '${c.thickEdgeLinearMeters.toStringAsFixed(1)} metros lineales (incluye 10% merma)'),
                  _buildWorkshopItemRow('Bisagras 35mm Cierre Suave', '${b.totalHingesCount} bisagras (${(b.totalHingesCount / 2).ceil()} pares)'),
                  if (b.totalSlidePairsCount > 0)
                    _buildWorkshopItemRow('Correderas Telescópicas', '${b.totalSlidePairsCount} pares reforzadas'),
                  _buildWorkshopItemRow('Tornillería Soberbios 4x50', '${b.hardware.firstWhere((h) => h.id == 'hw_soberbios', orElse: () => b.hardware.first).quantity.toInt()} unidades'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hoja de Despiece para Mesa de Armado
            Row(
              children: [
                const Text('2. Hoja de Despiece de Corte (Mesa de Taller)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Text('${b.pieces.length} ítems / ${b.pieces.fold(0, (s, p) => s + p.quantity)} piezas', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 40,
                columnSpacing: 16,
                headingRowColor: WidgetStateProperty.all(Colors.blueGrey[100]!),
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Pieza', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cant', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Largo', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Ancho', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Esp.', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cantos L1/L2/A1/A2', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Notas de Taller', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: b.pieces.asMap().entries.map((e) {
                  final p = e.value;
                  return DataRow(cells: [
                    DataCell(Text('${e.key + 1}')),
                    DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('${p.quantity}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('${p.length.toInt()}')),
                    DataCell(Text('${p.width.toInt()}')),
                    DataCell(Text('${p.thickness.toInt()}')),
                    DataCell(Text(p.edgeSummary, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
                    DataCell(Text(p.notes, style: const TextStyle(fontSize: 11))),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Resumen de Costos y Utilidad Interna (Exclusivo Taller)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_person_rounded, color: Colors.brown, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Estado de Resultados y Rentabilidad Interna (Exclusivo Taller)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.brown),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.brown.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(c.taxRegime.shortName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown.shade900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• Ventas (Facturado / Cobrado):', style: TextStyle(fontSize: 12, color: Colors.brown.shade900)),
                      Text('Bs ${c.grossRevenueBs.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• (-) Costo Producción (MP Bs ${c.subtotalDirectMaterialsBs.toStringAsFixed(0)} + MOD Bs ${c.subtotalLaborBs.toStringAsFixed(0)} + CIF Bs ${c.subtotalCifBs.toStringAsFixed(0)}):', style: TextStyle(fontSize: 12, color: Colors.brown.shade800)),
                      Text('- Bs ${c.productionCostBs.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• (=) Utilidad Bruta:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.brown.shade900)),
                      Text('Bs ${c.grossProfitBs.toStringAsFixed(2)} (${c.grossProfitMarginPercent.toStringAsFixed(1)}%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• (-) Gastos Operativos (${c.operatingExpensesPercent.toStringAsFixed(1)}%):', style: TextStyle(fontSize: 12, color: Colors.brown.shade800)),
                      Text('- Bs ${c.operatingExpensesBs.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• (-) Gastos Financieros / Intereses (${c.financialExpensesPercent.toStringAsFixed(1)}%):', style: TextStyle(fontSize: 12, color: Colors.brown.shade800)),
                      Text('- Bs ${c.financialExpensesBs.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• (=) Utilidad Antes de Impuestos (UAI):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.brown.shade900)),
                      Text('Bs ${c.uaiBs.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• (-) Impuestos deducibles (${c.taxRegime.shortName}):', style: TextStyle(fontSize: 12, color: Colors.brown.shade800)),
                      Text('- Bs ${c.totalTaxesBs.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
                    ],
                  ),
                  const Divider(height: 12, color: Colors.brown),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GANANCIA NETA FINAL EN BOLSILLO:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown.shade900),
                      ),
                      Text(
                        'Bs ${c.netProfitBs.toStringAsFixed(2)} (${c.actualMarginPercent.toStringAsFixed(1)}% Neto)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: c.netProfitBs >= 0 ? Colors.green.shade800 : Colors.red.shade800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Text('AT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ATELIER', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            Text('Carpintería & Mobiliario a Medida', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Av. Las Américas #450 • Telf: +591 712-34567 • taller@atelier.bo', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'COTIZACIÓN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text('• $label:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12.5, color: Colors.grey[850])),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopItemRow(String item, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: Text('• $item:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
          Expanded(
            child: Text(detail, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  void _copyProposalToClipboard(BuildContext context) {
    final text = '''
==================================================
COTIZACIÓN COMERCIAL - ATELIER MOBILIARIO
==================================================
N° Cotización: $_quoteNumber
Cliente: $_clientName
Fecha: 03/09/2026 | Validez: 15 días

MUEBLE: ${widget.furniture.name}
Dimensiones: ${widget.furniture.height.toInt()} x ${widget.furniture.width.toInt()} x ${widget.furniture.depth.toInt()} mm
Color: ${widget.furniture.melamineColorName} (${widget.furniture.melamineThickness.toInt()} mm)
Puertas: ${widget.furniture.doorsCount} (${widget.furniture.doorType.name}s)
Cajones: ${widget.furniture.drawersCount} correderas telescópicas
Repisas: ${widget.furniture.shelvesFixedCount} fijas, ${widget.furniture.shelvesMobileCount} móviles

PRECIO TOTAL: Bs ${widget.cost.activePriceBs.toStringAsFixed(2)}
Condiciones: 50% anticipo, 50% contra entrega
Tiempo de entrega: 7 a 10 días hábiles
==================================================
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Propuesta comercial copiada al portapapeles.')),
    );
  }

  void _showPrintPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.print_rounded, color: Colors.teal),
            SizedBox(width: 8),
            Text('Vista de Impresión / Exportación PDF'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Documento listo para generar en formato A4 / PDF: "${_isClientView ? "Cotización Comercial - $_clientName" : "Ficha Técnica de Producción Taller"}".',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Encabezado: ATELIER Carpintería & Mobiliario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[800])),
                    Text('Total: Bs ${widget.cost.activePriceBs.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal)),
                    Text('Formato: Hoja Membretada con sellos y términos de garantía.', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.download_done_rounded, size: 16),
            label: const Text('Simular Generación PDF'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF generado con éxito. Listo para enviar al cliente o imprimir.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
