import 'package:flutter/material.dart';
import '../../models/furniture_model.dart';

class FurnitureConfigView extends StatelessWidget {
  final FurnitureModel furniture;
  final ValueChanged<FurnitureModel> onChanged;

  const FurnitureConfigView({
    super.key,
    required this.furniture,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPresetSelector(context),
          const SizedBox(height: 16),
          _buildDimensionsSection(context),
          const SizedBox(height: 16),
          _buildComponentsSection(context),
          const SizedBox(height: 16),
          _buildMaterialsSection(context),
        ],
      ),
    );
  }

  Widget _buildPresetSelector(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Plantillas Rápidas de Muebles',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip(context, 'Bajo Cocina', FurniturePreset.muebleBajoCocina, Icons.countertops_outlined),
                _buildPresetChip(context, 'Ropero / Clóset', FurniturePreset.roperoCloset, Icons.door_sliding_outlined),
                _buildPresetChip(context, 'Repisero / Librero', FurniturePreset.repiseroLibrero, Icons.shelves),
                _buildPresetChip(context, 'Escritorio', FurniturePreset.escritorio, Icons.desk_outlined),
                _buildPresetChip(context, 'Personalizado', FurniturePreset.personalizado, Icons.tune_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(BuildContext context, String label, FurniturePreset preset, IconData icon) {
    final isSelected = furniture.preset == preset;
    return FilterChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : null),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onChanged(FurnitureModel.fromPreset(preset));
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12.5,
      ),
    );
  }

  Widget _buildDimensionsSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.straighten_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '1. Dimensiones Generales del Mueble',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'mm / cm',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDimensionRow(
              context: context,
              label: 'Alto Total (H)',
              value: furniture.height,
              min: 400,
              max: 2600,
              onChanged: (val) => onChanged(furniture.copyWith(height: val)),
            ),
            const Divider(height: 16),
            _buildDimensionRow(
              context: context,
              label: 'Ancho Total (W)',
              value: furniture.width,
              min: 300,
              max: 3000,
              onChanged: (val) => onChanged(furniture.copyWith(width: val)),
            ),
            const Divider(height: 16),
            _buildDimensionRow(
              context: context,
              label: 'Profundidad (D)',
              value: furniture.depth,
              min: 200,
              max: 900,
              onChanged: (val) => onChanged(furniture.copyWith(depth: val)),
            ),
            const Divider(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Altura Zócalo / Patas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Espacio inferior contra humedad', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                DropdownButton<double>(
                  value: furniture.zocaloHeight,
                  items: const [
                    DropdownMenuItem(value: 0.0, child: Text('Sin zócalo (0 mm)')),
                    DropdownMenuItem(value: 70.0, child: Text('70 mm (7 cm)')),
                    DropdownMenuItem(value: 80.0, child: Text('80 mm (8 cm)')),
                    DropdownMenuItem(value: 100.0, child: Text('100 mm (10 cm)')),
                  ],
                  onChanged: (val) {
                    if (val != null) onChanged(furniture.copyWith(zocaloHeight: val));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionRow({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(
                '${value.toInt()} mm (${(value / 10).toStringAsFixed(1)} cm)',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) / 10).round(),
            label: '${value.toInt()} mm',
            onChanged: (val) => onChanged(val.roundToDouble()),
          ),
        ),
        SizedBox(
          width: 65,
          child: TextFormField(
            key: ValueKey('${label}_${value.toInt()}'),
            initialValue: value.toInt().toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (text) {
              final parsed = double.tryParse(text);
              if (parsed != null && parsed >= min && parsed <= max) {
                onChanged(parsed);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComponentsSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard_customize_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '2. Componentes Internos y Puertas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Puertas
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Puertas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Define cantidad y bisagras', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                _buildCounter(
                  value: furniture.doorsCount,
                  min: 0,
                  max: 6,
                  onChanged: (val) => onChanged(furniture.copyWith(doorsCount: val)),
                ),
                if (furniture.doorsCount > 0) ...[
                  const SizedBox(width: 10),
                  DropdownButton<DoorType>(
                    value: furniture.doorType,
                    items: const [
                      DropdownMenuItem(value: DoorType.batiente, child: Text('Batiente')),
                      DropdownMenuItem(value: DoorType.corrediza, child: Text('Corrediza')),
                    ],
                    onChanged: (val) {
                      if (val != null) onChanged(furniture.copyWith(doorType: val));
                    },
                  ),
                ],
              ],
            ),
            const Divider(height: 16),
            // Cajones
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cajones', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Define pares de correderas', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                _buildCounter(
                  value: furniture.drawersCount,
                  min: 0,
                  max: 8,
                  onChanged: (val) => onChanged(furniture.copyWith(drawersCount: val)),
                ),
              ],
            ),
            const Divider(height: 16),
            // Divisiones Verticales / Parantes
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Divisiones Verticales (Parantes)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Evita pandeo y divide cuerpos', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                _buildCounter(
                  value: furniture.verticalDividersCount,
                  min: 0,
                  max: 4,
                  onChanged: (val) => onChanged(furniture.copyWith(verticalDividersCount: val)),
                ),
              ],
            ),
            const Divider(height: 16),
            // Repisas Fijas y Móviles
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Repisas Fijas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      _buildCounter(
                        value: furniture.shelvesFixedCount,
                        min: 0,
                        max: 6,
                        onChanged: (val) => onChanged(furniture.copyWith(shelvesFixedCount: val)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Repisas Móviles (Graduables)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      _buildCounter(
                        value: furniture.shelvesMobileCount,
                        min: 0,
                        max: 8,
                        onChanged: (val) => onChanged(furniture.copyWith(shelvesMobileCount: val)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Fondo / Trasera
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fondo / Trasera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Cierra posterior en MDF 3mm o 5mm', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                  value: furniture.hasBacking,
                  onChanged: (val) => onChanged(furniture.copyWith(hasBacking: val)),
                ),
                if (furniture.hasBacking) ...[
                  const SizedBox(width: 8),
                  DropdownButton<BackingType>(
                    value: furniture.backingType,
                    items: const [
                      DropdownMenuItem(value: BackingType.mdf3mm, child: Text('MDF 3 mm')),
                      DropdownMenuItem(value: BackingType.mdf5mm, child: Text('MDF 5 mm')),
                    ],
                    onChanged: (val) {
                      if (val != null) onChanged(furniture.copyWith(backingType: val));
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

  Widget _buildCounter({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 22),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          visualDensity: VisualDensity.compact,
        ),
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 22),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildMaterialsSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '3. Especificaciones del Material y Acabados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Espesor Melamina
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Espesor de Melamina', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('18 mm estándar o 15 mm económico', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 15.0, label: Text('15 mm')),
                    ButtonSegment(value: 18.0, label: Text('18 mm')),
                  ],
                  selected: {furniture.melamineThickness},
                  onSelectionChanged: (set) {
                    if (set.isNotEmpty) onChanged(furniture.copyWith(melamineThickness: set.first));
                  },
                ),
              ],
            ),
            const Divider(height: 16),
            // Color / Textura
            const Text('Color / Textura de Melamina', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FurnitureModel.availableColors.map((colorOpt) {
                final isSelected = furniture.melamineColorName == colorOpt.name;
                return InkWell(
                  onTap: () {
                    onChanged(furniture.copyWith(
                      melamineColorName: colorOpt.name,
                      melamineColor: colorOpt.previewColor,
                    ));
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorOpt.previewColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[400]!,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withAlpha(60),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Icon(Icons.check, size: 14, color: colorOpt.textColor),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          colorOpt.name,
                          style: TextStyle(
                            color: colorOpt.textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 16),
            // Tapacanto
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tapacanto Piezas Internas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const Text('Repisas, laterales de cajón', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      DropdownButton<EdgeType>(
                        isExpanded: true,
                        value: furniture.internalEdgeType,
                        items: const [
                          DropdownMenuItem(value: EdgeType.delgado045, child: Text('Delgado (0.60 mm)')),
                          DropdownMenuItem(value: EdgeType.grueso2mm, child: Text('Grueso (1.50 mm)')),
                          DropdownMenuItem(value: EdgeType.none, child: Text('Sin Canto')),
                        ],
                        onChanged: (val) {
                          if (val != null) onChanged(furniture.copyWith(internalEdgeType: val));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tapacanto Puertas y Frentes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const Text('Bordes vistos y de impacto', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      DropdownButton<EdgeType>(
                        isExpanded: true,
                        value: furniture.frontEdgeType,
                        items: const [
                          DropdownMenuItem(value: EdgeType.grueso2mm, child: Text('Grueso (1.50 mm)')),
                          DropdownMenuItem(value: EdgeType.delgado045, child: Text('Delgado (0.60 mm)')),
                        ],
                        onChanged: (val) {
                          if (val != null) onChanged(furniture.copyWith(frontEdgeType: val));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
