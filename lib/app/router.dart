import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/animations/page_transitions.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/verify_email_screen.dart';
import '../features/customers/domain/entities/customer_entity.dart';
import '../features/customers/presentation/screens/add_edit_customer_screen.dart';
import '../features/customers/presentation/screens/customer_details_screen.dart';
import '../features/customers/presentation/screens/customer_list_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/products/domain/entities/product_entity.dart';
import '../features/products/presentation/screens/add_edit_product_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/sales/domain/entities/sale_entity.dart';
import '../features/sales/presentation/screens/checkout_screen.dart';
import '../features/sales/presentation/screens/invoice_screen.dart';
import '../features/sales/presentation/screens/pos_screen.dart';
import '../features/shop/presentation/screens/shop_setup_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/shop-setup',
        name: 'shop-setup',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const ShopSetupScreen(),
        ),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const ProductListScreen(),
        ),
      ),
      GoRoute(
        path: '/products/add',
        name: 'product-add',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const AddEditProductScreen(),
        ),
      ),
      GoRoute(
        path: '/products/edit',
        name: 'product-edit',
        pageBuilder: (context, state) {
          final product = state.extra as ProductEntity?;
          return buildFadeSlidePage(
            context: context,
            state: state,
            child: AddEditProductScreen(product: product),
          );
        },
      ),
      GoRoute(
        path: '/customers',
        name: 'customers',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const CustomerListScreen(),
        ),
      ),
      GoRoute(
        path: '/customers/add',
        name: 'customer-add',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const AddEditCustomerScreen(),
        ),
      ),
      GoRoute(
        path: '/customers/edit',
        name: 'customer-edit',
        pageBuilder: (context, state) {
          final customer = state.extra as CustomerEntity?;
          return buildFadeSlidePage(
            context: context,
            state: state,
            child: AddEditCustomerScreen(customer: customer),
          );
        },
      ),
      GoRoute(
        path: '/customers/details',
        name: 'customer-details',
        pageBuilder: (context, state) {
          final customer = state.extra as CustomerEntity;
          return buildFadeSlidePage(
            context: context,
            state: state,
            child: CustomerDetailsScreen(customer: customer),
          );
        },
      ),
      GoRoute(
        path: '/sales/pos',
        name: 'sales-pos',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const POSScreen(),
        ),
      ),
      GoRoute(
        path: '/sales/checkout',
        name: 'sales-checkout',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: '/sales/invoice',
        name: 'sales-invoice',
        pageBuilder: (context, state) {
          final sale = state.extra as SaleEntity;
          return buildFadeSlidePage(
            context: context,
            state: state,
            child: InvoiceScreen(sale: sale),
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return buildFadeSlidePage(
            context: context,
            state: state,
            child: ResetPasswordScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return buildFadeSlidePage(
            context: context,
            state: state,
            child: VerifyEmailScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) => buildFadeSlidePage(
          context: context,
          state: state,
          child: const DashboardScreen(),
        ),
      ),
    ],
  );
});
