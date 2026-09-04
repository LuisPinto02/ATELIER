class HardwareItem {
  final String id;
  final String name;
  final String category; // 'Bisagras', 'Correderas', 'Tiradores', 'Tornillería', 'Soportes', 'Consumibles'
  final double quantity;
  final String unit; // 'par', 'pza', 'cto', 'm', 'tubo'
  final double unitPriceBs;
  final String details;

  const HardwareItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitPriceBs,
    this.details = '',
  });

  double get subtotalBs => quantity * unitPriceBs;

  HardwareItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? unitPriceBs,
    String? details,
  }) {
    return HardwareItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPriceBs: unitPriceBs ?? this.unitPriceBs,
      details: details ?? this.details,
    );
  }
}

