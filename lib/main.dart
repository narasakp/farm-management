import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:js' as js;
import 'core/firebase_service.dart';
import 'core/hive_service.dart';
import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';
import 'providers/financial_provider.dart';
import 'providers/survey_provider.dart';
import 'providers/trading_provider.dart';
import 'providers/transport_provider.dart';
import 'providers/farmer_group_provider.dart';
import 'providers/livestock_provider.dart';
import 'providers/farm_record_provider.dart';
import 'providers/feedback_provider.dart';
import 'providers/feedback_replies_provider.dart';
import 'providers/webboard_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/research_provider.dart';
import 'providers/production_auth_provider.dart';
import 'providers/production_provider.dart';
import 'providers/production_records_provider.dart';
import 'providers/market_provider.dart';
import 'providers/booking_provider.dart';
import 'widgets/rbac_initializer.dart';
// import 'providers/advanced_financial_provider.dart';
// import 'providers/gps_provider.dart';
import 'models/livestock.dart';
import 'screens/auth/unified_login_screen.dart';
import 'screens/auth/production_register_screen.dart';
import 'screens/farm/add_edit_livestock_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/farm/livestock_screen.dart';
import 'screens/livestock/livestock_management_screen.dart';
import 'screens/production/production_management_screen.dart';
import 'screens/farm/farm_list_screen.dart';
import 'screens/trading/trading_list_screen.dart';
import 'screens/transport/transport_list_screen.dart';
import 'screens/financial_screen.dart';
import 'screens/survey/livestock_survey_screen.dart';
import 'screens/trading/market_screen.dart';
import 'screens/farmer_group/farmer_group_screen.dart';
import 'screens/survey/survey_list_screen.dart';
// import 'screens/survey/survey_detail_screen.dart'; // File not found - using survey_detail_with_privacy_screen.dart instead
import 'screens/survey/survey_detail_with_privacy_screen.dart';
import 'screens/dashboard/project_report_screen.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/webboard/webboard_screen.dart';
import 'screens/webboard/thread_detail_screen.dart';
import 'screens/webboard/user_profile_screen.dart';
import 'screens/webboard/webboard_stats_screen.dart';
import 'screens/webboard/moderator_dashboard_screen.dart';
import 'screens/webboard/mentions_screen.dart';
import 'screens/webboard/activity_feed_screen.dart';
import 'screens/research/research_screen.dart';
import 'screens/contact_admin_screen.dart';
// import 'screens/search/search_screen.dart'; // ❌ REMOVED: ไม่ใช้แล้ว (ใช้ guest_search_screen แทน)
// import 'screens/rbac/rbac_test_screen.dart'; // ❌ REMOVED: Test screen ไม่ใช้แล้ว
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_contact_settings_screen.dart';
import 'screens/admin/admin_users_new_screen.dart';
import 'screens/admin/admin_roles_screen.dart';
import 'screens/admin/admin_permissions_screen.dart';
import 'screens/debug/seed_data_screen.dart';
import 'screens/social_commerce/analytics_dashboard_screen.dart';
import 'screens/social_commerce/quick_buy_screen.dart';
import 'screens/queue/payment_screen.dart';
import 'models/market_booking.dart';
// import 'screens/financial/advanced_financial_screen.dart';
// import 'screens/gps/gps_tracking_screen.dart';
import 'models/survey_form.dart';
import 'utils/app_theme.dart';
import 'utils/font_override.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await FirebaseService.initialize();
  await HiveService.initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  static String? _savedTargetRoute; // Static to share across router recreations
  late GoRouter _router;
  bool _lastAuthState = false;
  String? _targetRoute; // Store target route from URL fragment

  @override
  void initState() {
    super.initState();
    
    // Capture URL fragment BEFORE router is created (for ALL routes)
    try {
      if (Uri.base.fragment.isNotEmpty) {
        final fragment = Uri.base.fragment;
        // Preserve ANY valid route fragment (not just quick-buy)
        if (fragment != '/' && fragment.isNotEmpty) {
          _targetRoute = fragment.startsWith('/') ? fragment : '/$fragment';
          _savedTargetRoute = _targetRoute; // Save to static for router access
          print('💾 Saved target route for hard refresh: $_targetRoute');
        }
      }
    } catch (e) {
      // Silently ignore URL parsing errors
    }
    
    final authState = ref.read(productionAuthProvider);
    _lastAuthState = authState.isAuthenticated;
    _router = _createRouter(authState.isAuthenticated);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(productionAuthProvider);

    // Only rebuild router when auth state ACTUALLY changes
    if (!authState.isLoading && authState.isAuthenticated != _lastAuthState) {
      _lastAuthState = authState.isAuthenticated;
      _router = _createRouter(authState.isAuthenticated);
      
      // Clear saved target route after stable auth state
      if (_savedTargetRoute != null && authState.isAuthenticated) {
        _savedTargetRoute = null;
      }
    }

    if (authState.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // Wrap with MultiProvider for legacy components (e.g. Cascade Dropdown)
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        provider.ChangeNotifierProvider(create: (_) => FarmProvider()),
        provider.ChangeNotifierProvider(create: (_) => FinancialProvider()),
        provider.ChangeNotifierProvider(create: (_) => SurveyProvider()),
        provider.ChangeNotifierProvider(create: (_) => TradingProvider()),
        provider.ChangeNotifierProvider(create: (_) => TransportProvider()),
        provider.ChangeNotifierProvider(create: (_) => FarmerGroupProvider()),
        provider.ChangeNotifierProvider(create: (_) => LivestockProvider()),
        provider.ChangeNotifierProvider(create: (_) => FarmRecordProvider()),
        provider.ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        provider.ChangeNotifierProvider(create: (_) => FeedbackRepliesProvider()),
        provider.ChangeNotifierProvider(create: (_) => WebboardProvider()),
        provider.ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        provider.ChangeNotifierProvider(create: (_) => NotificationProvider()),
        provider.ChangeNotifierProvider(create: (_) => ResearchProvider()),
        provider.ChangeNotifierProvider(create: (_) => ProductionProvider()),
        provider.ChangeNotifierProvider(create: (_) => ProductionRecordsProvider()),
        // Queue Booking System
        provider.ChangeNotifierProvider(create: (_) => MarketProvider()),
        provider.ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: RbacInitializer(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'ระบบจัดการฟาร์มปศุสัตว์',
          theme: AppTheme.lightTheme,
          routerConfig: _router,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            quill.FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('th', 'TH'),
            Locale('en', 'US'),
          ],
        ),
      ),
    );
  }

  // Feedback icon controller (Flutter commands JavaScript)
  static void _updateFeedbackIcon(GoRouterState state) {
    final location = state.matchedLocation;
    
    // Hide icon on login and feedback pages
    if (location == '/login' || location == '/feedback') {
      try {
        js.context.callMethod('hideFeedbackIcon');
      } catch (e) {
        // Ignore if JS not available
      }
    } else {
      try {
        js.context.callMethod('showFeedbackIcon');
      } catch (e) {
        // Ignore if JS not available
      }
    }
  }

  static GoRouter _createRouter(bool isAuthenticated) {
    // Use saved target route if available, otherwise use default
    String initialLocation = _savedTargetRoute ?? '/';
    
    final router = GoRouter(
      initialLocation: initialLocation,
      refreshListenable: null, // Let Riverpod handle state changes
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) {
            // Default to market (guest browsing enabled)
            return '/market';
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const UnifiedLoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const ProductionRegisterScreen(),
        ),
        // Quick Buy Route - MUST BE FIRST for guest checkout
        GoRoute(
          path: '/quick-buy/:listingId',
          name: 'quick-buy',
          builder: (context, state) {
            final listingId = state.pathParameters['listingId']!;
            final source = state.uri.queryParameters['source'];
            final campaign = state.uri.queryParameters['campaign'];
            return QuickBuyScreen(
              listingId: listingId,
              source: source,
              campaign: campaign,
            );
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/livestock',
          builder: (context, state) => const LivestockScreen(),
        ),
        GoRoute(
          path: '/livestock-management',
          builder: (context, state) => const LivestockManagementScreen(),
        ),
        GoRoute(
          path: '/farm-list',
          builder: (context, state) => const FarmListScreen(),
        ),
        GoRoute(
          path: '/trading-list',
          builder: (context, state) => const TradingListScreen(),
        ),
        GoRoute(
          path: '/transport-list',
          builder: (context, state) => const TransportListScreen(),
        ),
        GoRoute(
          path: '/add-livestock',
          builder: (context, state) => const AddEditLivestockScreen(),
        ),
        GoRoute(
          path: '/edit-livestock',
          builder: (context, state) {
            final livestock = state.extra as Livestock?;
            return AddEditLivestockScreen(livestock: livestock);
          },
        ),
        GoRoute(
          path: '/financial',
          builder: (context, state) => const FinancialScreen(),
        ),
        GoRoute(
          path: '/survey',
          builder: (context, state) {
            final survey = state.extra as FarmSurvey?;
            return LivestockSurveyScreen(editingSurvey: survey);
          },
        ),
        GoRoute(
          path: '/survey-list',
          builder: (context, state) => const SurveyListScreen(),
        ),
        GoRoute(
          path: '/survey-detail',
          builder: (context, state) {
            final survey = state.extra as FarmSurvey;
            return SurveyDetailWithPrivacyScreen(survey: survey);
          },
        ),
        GoRoute(
          path: '/market',
          builder: (context, state) => const MarketScreen(),
        ),
        GoRoute(
          path: '/payment',
          builder: (context, state) {
            final booking = state.extra as MarketBooking;
            return PaymentScreen(booking: booking);
          },
        ),
        GoRoute(
          path: '/farmer-group',
          builder: (context, state) => const FarmerGroupScreen(),
        ),
        GoRoute(
          path: '/project-report',
          builder: (context, state) => const ProjectReportScreen(),
        ),
        GoRoute(
          path: '/reports-analytics',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/research-development',
          builder: (context, state) => const ResearchScreen(),
        ),
        GoRoute(
          path: '/feedback',
          builder: (context, state) => const FeedbackScreen(),
        ),
        GoRoute(
          path: '/webboard',
          builder: (context, state) => const WebboardScreen(),
        ),
        GoRoute(
          path: '/webboard/:id',
          builder: (context, state) {
            final threadId = state.pathParameters['id']!;
            return ThreadDetailScreen(threadId: threadId);
          },
        ),
        GoRoute(
          path: '/user-profile/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return UserProfileScreen(userId: userId);
          },
        ),
        GoRoute(
          path: '/webboard-stats',
          builder: (context, state) => const WebboardStatsScreen(),
        ),
        GoRoute(
          path: '/mentions',
          builder: (context, state) => const MentionsScreen(),
        ),
        GoRoute(
          path: '/activity-feed',
          builder: (context, state) => const ActivityFeedScreen(),
        ),
        GoRoute(
          path: '/moderator-dashboard',
          builder: (context, state) => const ModeratorDashboardScreen(),
        ),
        GoRoute(
          path: '/contact-admin',
          builder: (context, state) => const ContactAdminScreen(),
        ),
        // ❌ REMOVED: /search route (ไม่ใช้แล้ว - ใช้ /guest-search แทน)
        // ❌ REMOVED: /rbac-test route (Test screen ไม่ใช้แล้ว)
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin-contact-settings',
          builder: (context, state) => const AdminContactSettingsScreen(),
        ),
        GoRoute(
          path: '/admin-users',
          builder: (context, state) => const AdminUsersNewScreen(),
        ),
        GoRoute(
          path: '/admin-roles',
          builder: (context, state) => const AdminRolesScreen(),
        ),
        GoRoute(
          path: '/admin-permissions',
          builder: (context, state) => const AdminPermissionsScreen(),
        ),
        GoRoute(
          path: '/seed-data',  // ✅ Dev tool for seeding test data
          builder: (context, state) => const SeedDataScreen(),
        ),
        GoRoute(
          path: '/social-analytics',
          builder: (context, state) => const AnalyticsDashboardScreen(),
        ),
        // GoRoute(
        //   path: '/advanced-financial',
        //   builder: (context, state) => const AdvancedFinancialScreen(),
        // ),
        // GoRoute(
        //   path: '/gps-tracking',
        //   builder: (context, state) => const GPSTrackingScreen(),
        // ),
        GoRoute(
          path: '/health-management',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/breeding-management',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/production-management',
          builder: (context, state) => const ProductionManagementScreen(),
        ),
        GoRoute(
          path: '/feed-management',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      redirect: (context, state) {
        final location = state.matchedLocation;
        
        // Define public routes (accessible without login)
        final publicRoutes = [
          '/',           // Allow root access (will redirect to market)
          '/login',
          '/register',   // Allow registration without login
          '/market',
          '/search',
          '/quick-buy/',
          '/market-detail/',
        ];
        
        // Check if current route is public
        final isPublicRoute = publicRoutes.any((route) => 
          location == route || location.startsWith(route)
        );

        // Update feedback icon based on current route
        _updateFeedbackIcon(state);

        // Allow access to public routes without authentication
        if (isPublicRoute) {
          // If logged in, redirect to market from login page or root
          if (isAuthenticated) {
            if (location == '/login' || location == '/') {
              print('🔀 Authenticated user on $location, redirecting to /market');
              return '/market';
            }
          }
          return null; // No redirect for other public routes (logged in users can access market)
        }

        // Private routes require authentication
        if (!isAuthenticated) {
          return '/login';
        }

        // No redirect needed
        return null;
      },
    );
    
    // Listen to route changes
    router.routerDelegate.addListener(() {
      final location = router.routerDelegate.currentConfiguration.uri.path;
      
      // Control feedback icon based on location
      if (location == '/login' || location == '/feedback') {
        try {
          js.context.callMethod('hideFeedbackIcon');
        } catch (e) {
          // Ignore if JS not available
        }
      } else {
        try {
          js.context.callMethod('showFeedbackIcon');
        } catch (e) {
          // Ignore if JS not available
        }
      }
    });
    
    return router;
  }
}
