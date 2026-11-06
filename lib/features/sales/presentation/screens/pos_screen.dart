import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../products/presentation/controllers/products_controller.dart';
import '../controllers/pos_cart_controller.dart';
import '../widgets/cart_item_tile.dart';

class POSScreen extends ConsumerWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';
    final productsAsync = ref.watch(productsProvider);
    final searchKeyword = ref.watch(productsSearchProvider);
    final cartState = ref.watch(posCartProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('pos'),
        showBackButton: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          // Determine catalog cross axis count and aspect ratio based on available pane width
          final leftPaneWidth = totalWidth * 0.5;
          final crossAxisCount = leftPaneWidth < 200 ? 1 : 2;
          final childAspectRatio = crossAxisCount == 1 ? 2.8 : 1.3;

          return Row(
            children: [
              // Left Side: Product Catalog & Search
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppTextField(
                        initialValue: searchKeyword,
                        hint: context.tr('search'),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        onChanged: (val) {
                          ref.read(productsSearchProvider.notifier).state = val;
                        },
                      ),
                    ),
                    Expanded(
                      child: productsAsync.when(
                        data: (products) {
                          if (products.isEmpty) {
                            return AppEmptyState(
                              title: context.tr('no_products_found'),
                              description: '',
                              icon: Icons.inventory_2_outlined,
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return InkWell(
                                onTap: () {
                                  ref.read(posCartProvider.notifier).addToCart(product);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.cardDark : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        CurrencyFormatter.format(product.sellingPrice, isBangla: isBangla),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: AppLoading()),
                        error: (error, _) => AppErrorWidget(message: error.toString()),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              // Right Side: Cart Summary & Checkout
              Expanded(
                flex: 5,
                child: Container(
                  color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
                  child: Column(
                    children: [
                      // Cart Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        color: isDark ? AppColors.cardDark : Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('cart'),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (cartState.items.isNotEmpty)
                              InkWell(
                                onTap: () {
                                  ref.read(posCartProvider.notifier).clearCart();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Text(
                                    context.tr('delete'),
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Cart Items List
                      Expanded(
                        child: cartState.items.isEmpty
                            ? Center(
                                child: Text(
                                  'কার্ট খালি আছে',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemCount: cartState.items.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 6),
                                itemBuilder: (context, index) {
                                  return CartItemTile(item: cartState.items[index]);
                                },
                              ),
                      ),
                      // Checkout Summary Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.tr('subtotal'),
                                  style: theme.textTheme.bodySmall,
                                ),
                                Flexible(
                                  child: Text(
                                    CurrencyFormatter.format(cartState.subtotal, isBangla: isBangla),
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.tr('total'),
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Flexible(
                                  child: Text(
                                    CurrencyFormatter.format(cartState.total, isBangla: isBangla),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AppButton(
                              text: context.tr('checkout'),
                              onPressed: cartState.items.isEmpty
                                  ? null
                                  : () => context.push('/sales/checkout'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
