import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final double quantity;
  final double discount;

  const CartItemEntity({
    required this.product,
    this.quantity = 1.0,
    this.discount = 0.0,
  });

  double get subtotal => (product.sellingPrice * quantity) - discount;

  CartItemEntity copyWith({
    ProductEntity? product,
    double? quantity,
    double? discount,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  @override
  List<Object?> get props => [product, quantity, discount];
}
