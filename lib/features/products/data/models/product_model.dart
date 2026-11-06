import '../../domain/entities/product_entity.dart';

class ProductModel {
  final String id;
  final String name;
  final String? barcode;
  final double purchasePrice;
  final double sellingPrice;
  final double currentStock;
  final double minStock;
  final String unit;
  final String? categoryId;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    this.categoryId,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? json['product_name'] ?? '',
      barcode: json['barcode'] ?? json['sku'],
      purchasePrice: (json['purchase_price'] ?? json['buying_price'] ?? 0.0).toDouble(),
      sellingPrice: (json['selling_price'] ?? json['price'] ?? 0.0).toDouble(),
      currentStock: (json['current_stock'] ?? json['stock'] ?? 0.0).toDouble(),
      minStock: (json['min_stock'] ?? json['minimum_stock'] ?? 5.0).toDouble(),
      unit: json['unit'] ?? 'pcs',
      categoryId: json['category_id']?.toString(),
      imageUrl: json['image_url'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'current_stock': currentStock,
      'min_stock': minStock,
      'unit': unit,
      'category_id': categoryId,
      'image_url': imageUrl,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      barcode: barcode,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      currentStock: currentStock,
      minStock: minStock,
      unit: unit,
      categoryId: categoryId,
      imageUrl: imageUrl,
    );
  }
}
