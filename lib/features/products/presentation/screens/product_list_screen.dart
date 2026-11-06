import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../controllers/products_controller.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final searchKeyword = ref.watch(productsSearchProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('products'),
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26, color: AppColors.primary),
            onPressed: () => context.push('/products/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppTextField(
              initialValue: searchKeyword,
              hint: context.tr('search'),
              prefixIcon: const Icon(Icons.search_rounded),
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
                    description: 'আপনার দোকানে কোনো পণ্য যোগ করা হয়নি।',
                    icon: Icons.inventory_2_outlined,
                    actionText: context.tr('add_new_product'),
                    onAction: () => context.push('/products/add'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        context.push('/products/edit', extra: product);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: AppLoading(message: 'পণ্য লোড হচ্ছে...')),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(productsProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/products/add'),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('add_new_product')),
      ),
    );
  }
}
