import 'package:flutter/material.dart';
import '../../models/cost_breakdown_model.dart';

class CostingView extends StatefulWidget {
  final CostBreakdownModel cost;
  final ValueChanged<double> onTargetMarginChanged;
  final ValueChanged<double?> onManualPriceChanged;
  final ValueChanged<BoliviaTaxRegime> onTaxRegimeChanged;
  final ValueChanged<double>? onOperatingExpensePercentChanged;
  final ValueChanged<double>? onFinancialExpensePercentChanged;

  const CostingView({
    super.key,
    required this.cost,
    required this.onTargetMarginChanged,
    required this.onManualPriceChanged,
    required this.onTaxRegimeChanged,
    this.onOperatingExpensePercentChanged,
    this.onFinancialExpensePercentChanged,
  });

  @override
  State<CostingView> createState() => _CostingViewState();
}

class _CostingViewState extends State<CostingView> {
  late TextEditingController _manualPriceController;

  @override
  void initState() {
    super.initState();
    _manualPriceController = TextEditingController(
      text: widget.cost.isManualPriceActive ? widget.cost.activePriceBs.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(covariant CostingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cost.isManualPriceActive &&
        _manualPriceController.text != widget.cost.activePriceBs.toStringAsFixed(0)) {
      _manualPriceController.text = widget.cost.activePriceBs.toStringAsFixed(0);
    } else if (!widget.cost.isManualPriceActive && _manualPriceController.text.isNotEmpty) {
      _manualPriceController.clear();
    }
  }

  @override
  void dispose() {
    _manualPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialSummaryCards(context),
          const SizedBox(height: 16),
          _buildIncomeStatementCard(context),
          const SizedBox(height: 16),
          _buildPricingSimulatorCard(context),
          const SizedBox(height: 16),
          _buildTaxRegimeSelectorCard(context),
          const SizedBox(height: 16),
          _buildOperatingAndFinancialExpensesCard(context),
          const SizedBox(height: 16),
          _buildCostBreakdownDetails(context),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. TARJETAS DE RESUMEN EJECUTIVO (KPIs)
  // =========================================================================
  Widget _buildFinancialSummaryCards(BuildContext context) {
    final margin = widget.cost.actualMarginPercent;
    Color profitColor = Colors.green.shade700;
    if (margin < 0) {
      profitColor = Colors.red.shade800;
    } else if (margin < 20.0) {
      profitColor = Colors.red.shade700;
    } else if (margin < widget.cost.targetMarginPercent) {
      profitColor = Colors.orange.shade800;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 750;
        final cardW = isNarrow ? (constraints.maxWidth - 12) / 2 : (constraints.maxWidth - 36) / 4;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // 1. Ventas
            _buildMetricTile(
              title: 'Ventas Proyectadas',
              value: 'Bs ${widget.cost.activePriceBs.toStringAsFixed(2)}',
              subtitle: widget.cost.isManualPriceActive ? 'Precio acordado manual' : 'Precio sugerido óptimo',
              icon: Icons.point_of_sale_rounded,
              color: Colors.blueGrey.shade800,
              width: cardW,
            ),
            // 2. Utilidad Bruta
            _buildMetricTile(
              title: 'Utilidad Bruta',
              value: 'Bs ${widget.cost.grossProfitBs.toStringAsFixed(2)}',
              subtitle: 'Margen Bruto: ${widget.cost.grossProfitMarginPercent.toStringAsFixed(1)}%',
              icon: Icons.bar_chart_rounded,
              color: Colors.indigo.shade700,
              width: cardW,
            ),
            // 3. Utilidad Operativa
            _buildMetricTile(
              title: 'Utilidad Operativa',
              value: 'Bs ${widget.cost.operatingProfitBs.toStringAsFixed(2)}',
              subtitle: 'Tras alquiler y admin (${widget.cost.operatingProfitMarginPercent.toStringAsFixed(1)}%)',
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.teal.shade700,
              width: cardW,
            ),
            // 4. Utilidad Neta Final
            _buildMetricTile(
              title: 'Utilidad Neta (Taller)',
              value: 'Bs ${widget.cost.netProfitBs.toStringAsFixed(2)}',
              subtitle: 'Margen Neto: ${widget.cost.actualMarginPercent.toStringAsFixed(1)}%',
              icon: Icons.monetization_on_rounded,
              color: profitColor,
              width: cardW,
              isHighlight: true,
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
    bool isHighlight = false,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: isHighlight ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isHighlight ? BorderSide(color: color.withAlpha(120), width: 1.5) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[800]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isHighlight ? color : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. ESTADO DE RESULTADOS CONTABLE FORMAL (P&L EN BOLIVIA)
  // =========================================================================
  Widget _buildIncomeStatementCard(BuildContext context) {
    final c = widget.cost;
    final isSieteRg = c.taxRegime == BoliviaTaxRegime.sieteRg;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF0F766E).withAlpha(25), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.table_chart_rounded, color: Color(0xFF0F766E), size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado de Resultados (P&L del Proyecto)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Estructura financiera completa: Ventas, Costos de Producción, Gastos Fijos, Intereses e Impuestos',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSieteRg ? Colors.blue.shade50 : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isSieteRg ? Colors.blue.shade300 : Colors.purple.shade300),
                  ),
                  child: Text(
                    c.taxRegime.shortName,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSieteRg ? Colors.blue.shade800 : Colors.purple.shade800),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 1. VENTAS
            _buildPlRow(
              concept: 'Ventas (Ingresos Brutos)',
              amount: c.grossRevenueBs,
              isHeader: true,
              color: Colors.blueGrey.shade900,
              badgeText: '100.0%',
            ),
            const SizedBox(height: 4),

            // 2. COSTOS DE PRODUCCIÓN (MP + MOD + CIF)
            _buildPlRow(
              concept: '(−) Costos de Producción (MP + MOD + CIF)',
              amount: -c.productionCostBs,
              isDeduction: true,
              subtitle: 'Materia Prima Bs ${c.subtotalDirectMaterialsBs.toStringAsFixed(1)} + Mano de Obra Bs ${c.subtotalLaborBs.toStringAsFixed(1)} + CIF Bs ${c.subtotalCifBs.toStringAsFixed(1)}',
            ),
            _buildPlSubDetail('• Materia Prima (MP): Melamina, Fondo, Cantos y Herrajes', c.subtotalDirectMaterialsBs),
            _buildPlSubDetail('• Mano de Obra Directa (MOD): ${c.estimatedLaborHours.toStringAsFixed(1)} hrs × Bs ${c.laborHourlyRateBs}/h', c.subtotalLaborBs),
            _buildPlSubDetail('• Costos Indirectos de Fabricación (CIF): Cortes, Pegado, Flete y Desgaste', c.subtotalCifBs),
            const Divider(height: 16),

            // 3. UTILIDAD BRUTA
            _buildPlRow(
              concept: '(=) Utilidad Bruta',
              amount: c.grossProfitBs,
              isSubtotal: true,
              badgeText: '${c.grossProfitMarginPercent.toStringAsFixed(1)}% mg',
              badgeColor: Colors.indigo,
            ),
            const SizedBox(height: 6),

            // 4. GASTOS OPERATIVOS
            _buildPlRow(
              concept: '(−) Gastos Operativos Generales',
              amount: -c.operatingExpensesBs,
              isDeduction: true,
              subtitle: 'Alquiler del taller, showroom, administración y servicios (${c.operatingExpensesPercent.toStringAsFixed(1)}% de producción)',
            ),
            const Divider(height: 16),

            // 5. UTILIDAD OPERATIVA
            _buildPlRow(
              concept: '(=) Utilidad Operativa',
              amount: c.operatingProfitBs,
              isSubtotal: true,
              badgeText: '${c.operatingProfitMarginPercent.toStringAsFixed(1)}% mg',
              badgeColor: Colors.teal,
            ),
            const SizedBox(height: 6),

            // 6. GASTOS FINANCIEROS
            _buildPlRow(
              concept: '(−) Gastos Financieros (Intereses)',
              amount: -c.financialExpensesBs,
              isDeduction: true,
              subtitle: 'Intereses por créditos bancarios, líneas para insumos o préstamos (${c.financialExpensesPercent.toStringAsFixed(1)}% de producción)',
            ),
            const Divider(height: 16),

            // 7. UTILIDAD ANTES DE IMPUESTOS (UAI)
            _buildPlRow(
              concept: '(=) Utilidad Antes de Impuestos (UAI)',
              amount: c.uaiBs,
              isSubtotal: true,
              badgeText: '${c.uaiMarginPercent.toStringAsFixed(1)}% mg',
              badgeColor: Colors.blueGrey,
            ),
            const SizedBox(height: 6),

            // 8. IMPUESTOS
            if (isSieteRg) ...[
              _buildPlRow(
                concept: '(−) Impuesto SIETE-RG (5% sobre ventas brutas)',
                amount: -c.taxSieteRgBs,
                isDeduction: true,
                subtitle: 'Régimen simplificado monotributo (Ventas < Bs 250.000/año)',
              ),
            ] else ...[
              _buildPlRow(
                concept: '(−) Impuestos Régimen General',
                amount: -c.totalTaxesBs,
                isDeduction: true,
                subtitle: 'IT (3%): Bs ${c.taxItBs.toStringAsFixed(2)} + IUE (25% s/utilidad imponible): Bs ${c.taxIueBs.toStringAsFixed(2)}',
              ),
              _buildPlSubDetail('• IT (Impuesto a las Transacciones 3% sobre ingresos)', c.taxItBs),
              _buildPlSubDetail('• IUE (25% anual sobre base imponible UAI - IT)', c.taxIueBs),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 2, bottom: 4),
                child: Text(
                  'ℹ️ IVA mensual 13% (Bs ${c.taxIvaBs.toStringAsFixed(2)}): Informativo, trasladable al cliente con factura (débito/crédito fiscal), no reduce la utilidad directamente.',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.blueGrey[700]),
                ),
              ),
            ],
            const Divider(height: 20, thickness: 1.8),

            // 9. UTILIDAD NETA FINAL
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.netProfitBs >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.netProfitBs >= 0 ? Colors.green.shade400 : Colors.red.shade400),
              ),
              child: Row(
                children: [
                  Icon(
                    c.netProfitBs >= 0 ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                    color: c.netProfitBs >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UTILIDAD NETA FINAL (Ganancia de Bolsillo Taller)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: c.netProfitBs >= 0 ? Colors.green.shade900 : Colors.red.shade900),
                      ),
                      Text(
                        'Margen Neto Real sobre la Venta: ${c.actualMarginPercent.toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: c.netProfitBs >= 0 ? Colors.green.shade800 : Colors.red.shade800),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Bs ${c.netProfitBs.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: c.netProfitBs >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlRow({
    required String concept,
    required double amount,
    bool isHeader = false,
    bool isSubtotal = false,
    bool isDeduction = false,
    Color? color,
    String? subtitle,
    String? badgeText,
    Color? badgeColor,
  }) {
    final displayAmount = isDeduction ? '- Bs ${(-amount).toStringAsFixed(2)}' : 'Bs ${amount.toStringAsFixed(2)}';
    final textColor = color ?? (isSubtotal ? Colors.black87 : (isDeduction ? Colors.red.shade700 : Colors.black87));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  concept,
                  style: TextStyle(
                    fontWeight: (isHeader || isSubtotal) ? FontWeight.bold : FontWeight.w500,
                    fontSize: (isHeader || isSubtotal) ? 13.5 : 12.5,
                    color: textColor,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? Colors.grey.shade700).withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: badgeColor ?? Colors.grey.shade800),
                  ),
                ),
              ],
              Text(
                displayAmount,
                style: TextStyle(
                  fontWeight: (isHeader || isSubtotal) ? FontWeight.bold : FontWeight.w600,
                  fontSize: (isHeader || isSubtotal) ? 14 : 12.5,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 1),
              child: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlSubDetail(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 2, bottom: 2),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(fontSize: 11.5, color: Colors.grey[750]))),
          Text('Bs ${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 11.5, color: Colors.grey[800], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. SELECTOR DE RÉGIMEN TRIBUTARIO BOLIVIANO
  // =========================================================================
  Widget _buildTaxRegimeSelectorCard(BuildContext context) {
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
                Icon(Icons.account_balance_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Régimen Tributario en Bolivia (Seleccionable)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Selecciona el régimen legal aplicable al taller para determinar con precisión los impuestos y la utilidad neta:',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            SegmentedButton<BoliviaTaxRegime>(
              segments: const [
                ButtonSegment(
                  value: BoliviaTaxRegime.sieteRg,
                  label: Text('Régimen SIETE-RG (5%)'),
                  icon: Icon(Icons.storefront_rounded, size: 16),
                ),
                ButtonSegment(
                  value: BoliviaTaxRegime.general,
                  label: Text('Régimen General (IVA/IT/IUE)'),
                  icon: Icon(Icons.corporate_fare_rounded, size: 16),
                ),
              ],
              selected: {widget.cost.taxRegime},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  widget.onTaxRegimeChanged(selection.first);
                }
              },
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: Colors.teal[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.cost.taxRegime.description,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 4. SIMULADOR DE PRECIOS Y FÓRMULA OBLIGATORIA
  // =========================================================================
  Widget _buildPricingSimulatorCard(BuildContext context) {
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
                Icon(Icons.calculate_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Fórmula de Margen sobre la Venta y Precios',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // FÓRMULA OBLIGATORIA DESTACADA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.teal.shade800, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'FÓRMULA OBLIGATORIA (Margen sobre la Venta):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal.shade900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Precio = Costo Total / (1 − M)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Bs ${widget.cost.totalCostBs.toStringAsFixed(2)} / (1 − ${(widget.cost.targetMarginPercent / 100).toStringAsFixed(2)}) = Bs ${widget.cost.grossMarginPriceBs.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11.5, color: Colors.teal.shade800, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Slider de Margen Objetivo
            Row(
              children: [
                Text(
                  'Margen Objetivo (M%): ${widget.cost.targetMarginPercent.toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                Expanded(
                  child: Slider(
                    value: widget.cost.targetMarginPercent,
                    min: 15.0,
                    max: 60.0,
                    divisions: 45,
                    label: '${widget.cost.targetMarginPercent.toInt()}%',
                    onChanged: (val) => widget.onTargetMarginChanged(val.roundToDouble()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Comparativa de Fórmulas
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final colW = isNarrow ? constraints.maxWidth : (constraints.maxWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Margen sobre la Venta (Mandatorio)
                    _buildFormulaTile(
                      context: context,
                      title: 'Sobre la Venta (Obligatorio)',
                      formula: 'Precio = Costo / (1 - M)',
                      price: widget.cost.grossMarginPriceBs,
                      badge: 'ESTÁNDAR ATELIER',
                      badgeColor: Colors.teal,
                      isCurrent: !widget.cost.isManualPriceActive &&
                          (widget.cost.activePriceBs - widget.cost.grossMarginPriceBs).abs() < 1,
                      onAdopt: () {
                        widget.onManualPriceChanged(null);
                        _manualPriceController.clear();
                      },
                      width: colW,
                    ),
                    // Markup sobre el Costo (Referencial)
                    _buildFormulaTile(
                      context: context,
                      title: 'Sobre el Costo (Markup Clásico)',
                      formula: 'Precio = Costo × (1 + M)',
                      price: widget.cost.markupPriceBs,
                      badge: 'INFORMATIVO / MARKUP',
                      badgeColor: Colors.blueGrey,
                      isCurrent: widget.cost.isManualPriceActive &&
                          (widget.cost.activePriceBs - widget.cost.markupPriceBs).abs() < 1,
                      onAdopt: () {
                        widget.onManualPriceChanged(widget.cost.markupPriceBs);
                        _manualPriceController.text = widget.cost.markupPriceBs.toStringAsFixed(0);
                      },
                      width: colW,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Simulador de Precio Manual
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Evaluar Precio Manual / Acordado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      Text('Ingresa un precio ofertado al cliente para recalcular el Estado de Resultados al instante', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _manualPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'Bs ',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                      hintText: 'Ej. 2800',
                    ),
                    onSubmitted: (text) {
                      final val = double.tryParse(text);
                      widget.onManualPriceChanged(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(_manualPriceController.text);
                    widget.onManualPriceChanged(val);
                  },
                  child: const Text('Calcular'),
                ),
                if (widget.cost.isManualPriceActive) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Restaurar precio sugerido por fórmula',
                    onPressed: () {
                      _manualPriceController.clear();
                      widget.onManualPriceChanged(null);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaTile({
    required BuildContext context,
    required String title,
    required String formula,
    required double price,
    required String badge,
    required Color badgeColor,
    required bool isCurrent,
    required VoidCallback onAdopt,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? badgeColor.withAlpha(20) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? badgeColor : Colors.grey[300]!,
          width: isCurrent ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              if (isCurrent)
                const Icon(Icons.check_circle, size: 16, color: Colors.teal),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(formula, style: TextStyle(fontSize: 10.5, color: Colors.grey[600], fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Text('Bs ${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAdopt,
              style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(isCurrent ? 'Precio Activo Vigente' : 'Adoptar este Precio'),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 5. AJUSTE DE GASTOS OPERATIVOS Y FINANCIEROS
  // =========================================================================
  Widget _buildOperatingAndFinancialExpensesCard(BuildContext context) {
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
                Icon(Icons.business_center_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Gastos Fijos Operativos y Financieros del Taller',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ajusta la tasa proporcional asignada a cada mueble para absorber los costos del negocio y deudas:',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gastos Operativos (Fijos): ${widget.cost.operatingExpensesPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        'Alquiler, administración, showroom, contabilidad = Bs ${widget.cost.operatingExpensesBs.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Slider(
                    value: widget.cost.operatingExpensesPercent,
                    min: 0.0,
                    max: 15.0,
                    divisions: 30,
                    label: '${widget.cost.operatingExpensesPercent.toStringAsFixed(1)}%',
                    onChanged: widget.onOperatingExpensePercentChanged,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gastos Financieros (Intereses): ${widget.cost.financialExpensesPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        'Intereses bancarios, créditos por tableros y maquinaria = Bs ${widget.cost.financialExpensesBs.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Slider(
                    value: widget.cost.financialExpensesPercent,
                    min: 0.0,
                    max: 10.0,
                    divisions: 20,
                    label: '${widget.cost.financialExpensesPercent.toStringAsFixed(1)}%',
                    onChanged: widget.onFinancialExpensePercentChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 6. ESTRUCTURA INDUSTRIAL DETALLADA (MP, MOD, CIF)
  // =========================================================================
  Widget _buildCostBreakdownDetails(BuildContext context) {
    final c = widget.cost;

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
                Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Estructura de Costos de Producción (MP + MOD + CIF)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 1. Materia Prima Directa (MP)
            _buildCostCategoryHeader('1. Materia Prima Directa (MP)', c.subtotalDirectMaterialsBs),
            _buildCostLine('Planchas Melamina (${c.melamineBoardsCount} un.)', c.melamineBoardsTotalBs),
            if (c.backingBoardsCount > 0)
              _buildCostLine('Fondo MDF (${c.backingBoardsCount} un.)', c.backingBoardsTotalBs),
            _buildCostLine(
              'Tapacanto Delgado (${c.thinEdgeLinearMeters.toStringAsFixed(1)} m con merma)',
              c.thinEdgeTotalBs,
            ),
            _buildCostLine(
              'Tapacanto Grueso (${c.thickEdgeLinearMeters.toStringAsFixed(1)} m con merma)',
              c.thickEdgeTotalBs,
            ),
            _buildCostLine('Herrajes y Consumibles Directos', c.hardwareSubtotalBs),
            const Divider(height: 16),

            // 2. Mano de Obra Directa (MOD)
            _buildCostCategoryHeader('2. Mano de Obra Directa (MOD)', c.subtotalLaborBs),
            _buildCostLine(
              'Armado e Instalación (${c.estimatedLaborHours.toStringAsFixed(1)} hrs × Bs ${c.laborHourlyRateBs}/h)',
              c.subtotalLaborBs,
            ),
            const Divider(height: 16),

            // 3. Costos Indirectos de Fabricación (CIF)
            _buildCostCategoryHeader('3. Costos Indirectos de Fabricación (CIF)', c.subtotalCifBs),
            _buildCostLine('Servicio de Corte / Aserrado en Planchas', c.cutServiceTotalBs),
            _buildCostLine('Servicio de Pegado de Canto Termofusionado', c.edgeApplyTotalBs),
            _buildCostLine('Perforaciones Bisagras (${c.hingeHolesCount} huecos)', c.hingeHolesTotalBs),
            _buildCostLine('Flete / Transporte de Materiales al Taller', c.freightBs),
            _buildCostLine(
              'Desgaste de Brocas, Hojas de Sierra y Herramientas (${c.toolWearPercentage.toInt()}%)',
              c.toolWearTotalBs,
            ),
            const Divider(height: 16, thickness: 1.5),

            Row(
              children: [
                const Text('COSTO TOTAL DE PRODUCCIÓN (MP + MOD + CIF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                const Spacer(),
                Text(
                  'Bs ${c.productionCostBs.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('COSTO TOTAL INTEGRAL (+ Gastos Op. y Financieros)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Text(
                  'Bs ${c.totalCostBs.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F766E)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCategoryHeader(String title, double subtotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          const Spacer(),
          Text('Bs ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCostLine(String concept, double amount) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 2, bottom: 2),
      child: Row(
        children: [
          Text('• $concept', style: TextStyle(fontSize: 12, color: Colors.grey[800])),
          const Spacer(),
          Text('Bs ${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey[850])),
        ],
      ),
    );
  }
}


