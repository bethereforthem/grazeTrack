import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

// ─── Screen imports ───────────────────────────────────────────────────────────
import '../features/splash/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/animals/screens/animal_list.dart';
import '../features/animals/screens/add_animal.dart';
import '../features/animals/screens/animal_detail_screen.dart';
import '../features/animals/screens/update_animal_screen.dart';
import '../features/feeding/screens/feed_list.dart';
import '../features/feeding/screens/add_feed.dart';
import '../features/health/screens/health_list.dart';
import '../features/health/screens/add_health.dart';
import '../features/expenses/screens/expense_list.dart';
import '../features/expenses/screens/add_expense.dart';
import '../features/sales/screens/sales_list.dart';
import '../features/sales/screens/add_sale.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/profile_screen.dart';
import '../features/marketplace/screens/marketplace_screen.dart';
import '../features/marketplace/screens/listing_detail_screen.dart';
import '../features/marketplace/screens/farmer_profile_screen.dart';
import '../features/my_listings/screens/my_listings_screen.dart';
import '../features/my_listings/screens/create_listing_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/orders/screens/admin_orders_screen.dart';
import '../features/orders/screens/place_order_screen.dart';
import '../features/orders/screens/order_detail_screen.dart';
import '../features/payment/payment_screen.dart';
import '../features/chat/screens/chat_list_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/reviews/reviews_screen.dart';
import '../features/settings/screens/help_faq_screen.dart';
import '../features/settings/screens/contact_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  redirect: (context, state) async {
    final location = state.matchedLocation;
    final freePages = ['/splash', '/login', '/signup'];
    if (freePages.contains(location)) return null;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token == null) return '/login';
    return null;
  },

  routes: [
    // ─── Splash ────────────────────────────────────────────────────
    GoRoute(path: '/splash', builder: (ctx, state) => const SplashScreen()),

    // ─── Auth ──────────────────────────────────────────────────────
    GoRoute(path: '/login',  builder: (ctx, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (ctx, state) => const SignupScreen()),

    // ─── Main shell — bottom navigation ────────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/dashboard',   builder: (ctx, state) => const DashboardScreen()),
        GoRoute(path: '/marketplace', builder: (ctx, state) => const MarketplaceScreen()),
        GoRoute(path: '/animals',     builder: (ctx, state) => const AnimalListScreen()),
        GoRoute(path: '/feed',        builder: (ctx, state) => const FeedListScreen()),
        GoRoute(path: '/expenses',    builder: (ctx, state) => const ExpenseListScreen()),
        GoRoute(path: '/reports',     builder: (ctx, state) => const ReportsScreen()),
        // Messages tab — lives inside the shell so the bottom nav stays visible
        GoRoute(path: '/chat',        builder: (ctx, state) => const ChatListScreen()),
      ],
    ),

    // ─── Animal detail / add / update ──────────────────────────────
    GoRoute(path: '/animals/add',
        builder: (ctx, state) => const AddAnimalScreen()),
    GoRoute(path: '/animals/update/:id',
        builder: (ctx, state) =>
            UpdateAnimalScreen(animalId: state.pathParameters['id']!)),
    GoRoute(path: '/animals/:id',
        builder: (ctx, state) =>
            AnimalDetailScreen(animalId: state.pathParameters['id']!)),

    // ─── Feed / Health / Sales ─────────────────────────────────────
    GoRoute(path: '/feed/add',     builder: (ctx, state) => const AddFeedScreen()),
    GoRoute(path: '/health',       builder: (ctx, state) => const HealthListScreen()),
    GoRoute(path: '/health/add',   builder: (ctx, state) => const AddHealthScreen()),
    GoRoute(path: '/expenses/add', builder: (ctx, state) => const AddExpenseScreen()),
    GoRoute(path: '/sales',        builder: (ctx, state) => const SalesListScreen()),
    GoRoute(path: '/sales/add',    builder: (ctx, state) => const AddSaleScreen()),

    // ─── Notifications / Settings / Profile ────────────────────────
    GoRoute(path: '/notifications', builder: (ctx, state) => const NotificationsScreen()),
    GoRoute(path: '/settings',      builder: (ctx, state) => const SettingsScreen()),
    GoRoute(path: '/profile',       builder: (ctx, state) => const ProfileScreen()),
    GoRoute(path: '/help-faq',      builder: (ctx, state) => const HelpFaqScreen()),
    GoRoute(path: '/contact',       builder: (ctx, state) => const ContactScreen()),

    // ─── Marketplace listing detail ────────────────────────────────
    GoRoute(
      path: '/marketplace/:id',
      builder: (ctx, state) => ListingDetailScreen(
        listingId: state.pathParameters['id']!,
        listing: state.extra as Map<String, dynamic>?,
      ),
    ),

    // ─── Farmer public profile ─────────────────────────────────────
    GoRoute(
      path: '/farmer/:sellerId',
      builder: (ctx, state) => FarmerProfileScreen(
        sellerId: state.pathParameters['sellerId']!,
        farmerData: state.extra as Map<String, dynamic>?,
      ),
    ),

    // ─── My Listings ───────────────────────────────────────────────
    GoRoute(path: '/my-listings',
        builder: (ctx, state) => const MyListingsScreen()),
    GoRoute(path: '/my-listings/create',
        builder: (ctx, state) => const CreateListingScreen()),
    GoRoute(path: '/my-listings/:id/edit',
        builder: (ctx, state) => CreateListingScreen(
              existingListing: state.extra as Map<String, dynamic>?,
            )),

    // ─── Orders ────────────────────────────────────────────────────
    GoRoute(path: '/orders',       builder: (ctx, state) => const OrdersScreen()),
    GoRoute(path: '/orders/admin', builder: (ctx, state) => const AdminOrdersScreen()),
    GoRoute(path: '/orders/place',
        builder: (ctx, state) =>
            PlaceOrderScreen(listing: state.extra as Map<String, dynamic>)),
    GoRoute(path: '/orders/:id',
        builder: (ctx, state) => OrderDetailScreen(
              orderId: state.pathParameters['id']!,
              order: state.extra as Map<String, dynamic>?,
            )),

    // ─── Payment ───────────────────────────────────────────────────
    GoRoute(
      path: '/payment/:orderId',
      builder: (ctx, state) => PaymentScreen(
        orderId: state.pathParameters['orderId']!,
        order: state.extra as Map<String, dynamic>?,
      ),
    ),

    // ─── Chat conversation screen ──────────────────────────────────
    // NOTE: /chat (the list) is inside the ShellRoute above.
    // Only the individual thread screen lives outside (no bottom nav).
    GoRoute(
      path: '/chat/thread/:threadId',
      builder: (ctx, state) => ChatScreen(
        threadId: state.pathParameters['threadId']!,
        threadMeta: state.extra as Map<String, dynamic>?,
      ),
    ),

    // ─── Reviews ───────────────────────────────────────────────────
    GoRoute(path: '/reviews/write',
        builder: (ctx, state) =>
            WriteReviewScreen(order: state.extra as Map<String, dynamic>)),
    GoRoute(path: '/reviews/seller/:sellerId',
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ReviewsScreen(
            sellerId: state.pathParameters['sellerId']!,
            sellerName: extra['sellerName'] ?? 'Seller',
          );
        }),
  ],
);

// ─── MainShell — bottom navigation bar ───────────────────────────────────────
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/marketplace')) return 1;
    if (location.startsWith('/animals'))     return 2;
    if (location.startsWith('/feed'))        return 3;
    if (location.startsWith('/expenses'))    return 4;
    if (location.startsWith('/reports'))     return 5;
    if (location.startsWith('/chat'))        return 6;
    return 0; // dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/dashboard');   break;
            case 1: context.go('/marketplace'); break;
            case 2: context.go('/animals');     break;
            case 3: context.go('/feed');        break;
            case 4: context.go('/expenses');    break;
            case 5: context.go('/reports');     break;
            case 6: context.go('/chat');        break;
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Market'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pets_outlined),
              activeIcon: Icon(Icons.pets),
              label: 'Animals'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grass_outlined),
              activeIcon: Icon(Icons.grass),
              label: 'Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Expenses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Messages'),
        ],
      ),
    );
  }
}
