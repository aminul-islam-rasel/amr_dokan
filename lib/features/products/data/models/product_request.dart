class ProductRequest {
  final String name;
  final String? barcode;
  final double purchasePrice;
  final double sellingPrice;
  final double currentStock;
  final double minStock;
  final String unit;
  final String? categoryId;

  ProductRequest({
    required this.name,
    this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'barcode': barcode,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'current_stock': currentStock,
      'min_stock': minStock,
      'unit': unit,
      'category_id': categoryId,
    };
  }
}
