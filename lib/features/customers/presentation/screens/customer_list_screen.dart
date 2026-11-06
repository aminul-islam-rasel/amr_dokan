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
import '../controllers/customers_controller.dart';
import '../widgets/collect_due_dialog.dart';
import '../widgets/customer_card.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);
    final searchKeyword = ref.watch(customersSearchProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('customers'),
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, size: 24, color: AppColors.primary),
            onPressed: () => context.push('/customers/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppTextField(
              initialValue: searchKeyword,
              hint: context.tr('search'),
              prefixIcon: const Icon(Icons.search_rounded),
              onChanged: (val) {
                ref.read(customersSearchProvider.notifier).state = val;
              },
            ),
          ),
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                if (customers.isEmpty) {
                  return AppEmptyState(
                    title: context.tr('no_customers_found'),
                    description: 'আপনার দোকানে কোনো কাস্টমার যোগ করা হয়নি।',
                    icon: Icons.people_outline_rounded,
                    actionText: context.tr('add_customer'),
                    onAction: () => context.push('/customers/add'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: customers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return CustomerCard(
                      customer: customer,
                      onTap: () {
                        context.push('/customers/details', extra: customer);
                      },
                      onCollectDue: () {
                        showDialog(
                          context: context,
                          builder: (_) => CollectDueDialog(customer: customer),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: AppLoading(message: 'কাস্টমার লোড হচ্ছে...')),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(customersProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/customers/add'),
        icon: const Icon(Icons.person_add_rounded),
        label: Text(context.tr('add_customer')),
      ),
    );
  }
}
