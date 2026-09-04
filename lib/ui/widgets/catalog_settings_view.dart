import 'package:flutter/material.dart';
import '../../models/workshop_catalog_model.dart';
import '../../models/cost_breakdown_model.dart';

class CatalogSettingsView extends StatelessWidget {
  final WorkshopCatalog catalog;
  final ValueChanged<WorkshopCatalog> onCatalogChanged;

  const CatalogSettingsView({
    super.key,
    required this.catalog,
    required this.onCatalogChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_suggest_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Tablas Base de Datos y Tarifario del Taller',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Restaurar Tarifas Predeterminadas'),
                onPressed: () {
                  onCatalogChanged(WorkshopCatalog.defaultCatalog());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tarifas restauradas a valores predeterminados.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Modifica los costos unitarios de insumos, planchas y servicios para que todos los cálculos de ATELIER se actualicen al instante.',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          _buildServiciosCard(context),
          const SizedBox(height: 16),
          _buildMaterialesCard(context),
          const SizedBox(height: 16),
          _buildHerrajesCard(context),
        ],
      ),
    );
  }

  // TABLA DE SERVICIOS
  Widget _buildServiciosCard(BuildContext context) {
    final s = catalog.tablaServicios;

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
                Icon(Icons.handyman_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text('tabla_servicios: Tarifas y Mano de Obra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            _buildEditablePriceRow(
              context: context,
              label: 'Corte / Aserrado (por plancha completa)',
              value: s.cutServiceCostPerBoardBs,
              unit: 'Bs/plancha',
              onChanged: (v) => onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(cutServiceCostPerBoardBs: v))),
            ),
            _buildEditablePriceRow(
              context: context,
              label: 'Pegado Tapacanto Delgado 0.60mm',
              value: s.edgeThinApplyCostPerMeterBs,
              unit: 'Bs/metro',
              onChanged: (v) => onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(edgeThinApplyCostPerMeterBs: v))),
            ),
            _buildEditablePriceRow(
              context: context,
              label: 'Pegado Tapacanto Grueso 1.50mm',
              value: s.edgeThickApplyCostPerMeterBs,
              unit: 'Bs/metro',
              onChanged: (v) => onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(edgeThickApplyCostPerMeterBs: v))),
            ),
            _buildEditablePriceRow(
              context: context,
              label: 'Perforación Cazoleta Bisagra 35mm',
              value: s.hingeHoleCostPerUnitBs,
              unit: 'Bs/hueco',
              onChanged: (v) => onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(hingeHoleCostPerUnitBs: v))),
            ),
            _buildEditablePriceRow(
              context: context,
              label: 'Valor Mano de Obra Armado (Hora/Hombre)',
              value: s.laborHourlyRateBs,
              unit: 'Bs/hora',
              onChanged: (v) => onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(laborHourlyRateBs: v))),
            ),
            _buildEditablePriceRow(
              context: context,
              label: 'Flete y Transporte Base',
              value: s.freightBaseBs,
              unit: 'Bs',
              onChanged: (v) => onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(freightBaseBs: v))),
            ),
            _buildEditablePriceRow(
              context: context,
              label: 'Desgaste Herramientas e Indirectos Taller (CIF)',
              value: s.indirectExpensePercent,
              unit: '%',
              onChanged: (v) => onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(indirectExpensePercent: v))),
            ),
            _buildEditablePriceRow(
              context: context,
              label: 'Gastos Operativos Generales (Alquiler, Admin)',
              value: s.operatingExpensePercent,
              unit: '%',
              onChanged: (v) => onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(operatingExpensePercent: v))),
            ),
            _buildEditablePriceRow(
              context: context,
              label: 'Gastos Financieros (Intereses Préstamos/Deuda)',
              value: s.financialExpensePercent,
              unit: '%',
              onChanged: (v) => onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(financialExpensePercent: v))),
            ),
            const Divider(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Régimen Tributario Predeterminado:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('Aplicado inicialmente a los nuevos proyectos', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                DropdownButton<BoliviaTaxRegime>(
                  value: s.defaultTaxRegime,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: BoliviaTaxRegime.sieteRg,
                      child: Text('SIETE-RG (5% monotributo)'),
                    ),
                    DropdownMenuItem(
                      value: BoliviaTaxRegime.general,
                      child: Text('Régimen General (IVA/IT/IUE)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      onCatalogChanged(catalog.copyWith(tablaServicios: s.copyWith(defaultTaxRegime: val)));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TABLA DE MATERIALES
  Widget _buildMaterialesCard(BuildContext context) {
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
                Icon(Icons.layers_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text('tabla_materiales: Planchas e Inventario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 36,
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Material', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Medidas (mm)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Espesor', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Precio (Bs)', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: catalog.tablaMateriales.map((m) {
                  return DataRow(cells: [
                    DataCell(Text(m.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text('${m.lengthMm.toInt()} x ${m.widthMm.toInt()}')),
                    DataCell(Text('${m.thicknessMm.toInt()} mm')),
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          key: ValueKey('mat_${m.id}_${m.priceBs}'),
                          initialValue: m.priceBs.toStringAsFixed(0),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            border: OutlineInputBorder(),
                            prefixText: 'Bs ',
                          ),
                          onFieldSubmitted: (text) {
                            final p = double.tryParse(text);
                            if (p != null && p > 0) {
                              final updated = catalog.tablaMateriales.map((item) {
                                return item.id == m.id ? item.copyWith(priceBs: p) : item;
                              }).toList();
                              onCatalogChanged(catalog.copyWith(tablaMateriales: updated));
                            }
                          },
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TABLA DE HERRAJES
  Widget _buildHerrajesCard(BuildContext context) {
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
                Icon(Icons.hardware_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text('tabla_herrajes: Catálogo de Insumos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 36,
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Ítem', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Unidad', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Costo Unit. (Bs)', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: catalog.tablaHerrajes.map((h) {
                  return DataRow(cells: [
                    DataCell(Text(h.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(h.category)),
                    DataCell(Text(h.unit)),
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          key: ValueKey('hw_${h.id}_${h.unitCostBs}'),
                          initialValue: h.unitCostBs.toStringAsFixed(2),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            border: OutlineInputBorder(),
                            prefixText: 'Bs ',
                          ),
                          onFieldSubmitted: (text) {
                            final p = double.tryParse(text);
                            if (p != null && p >= 0) {
                              final updated = catalog.tablaHerrajes.map((item) {
                                return item.id == h.id ? item.copyWith(unitCostBs: p) : item;
                              }).toList();
                              onCatalogChanged(catalog.copyWith(tablaHerrajes: updated));
                            }
                          },
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditablePriceRow({
    required BuildContext context,
    required String label,
    required double value,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          SizedBox(
            width: 100,
            child: TextFormField(
              key: ValueKey('${label}_$value'),
              initialValue: value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: const OutlineInputBorder(),
                suffixText: ' $unit',
                suffixStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              onFieldSubmitted: (text) {
                final v = double.tryParse(text);
                if (v != null && v >= 0) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

