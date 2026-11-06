import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
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

  const ProductEntity({
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

  bool get isLowStock => currentStock <= minStock;
  bool get isOutOfStock => currentStock <= 0;

  @override
  List<Object?> get props => [
        id,
        name,
        barcode,
        purchasePrice,
        sellingPrice,
        currentStock,
        minStock,
        unit,
        categoryId,
        imageUrl,
      ];
}
