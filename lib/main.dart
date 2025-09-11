import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'providers/research_provider.dart';
// import 'providers/advanced_financial_provider.dart';
// import 'providers/gps_provider.dart';
import 'models/livestock.dart';
import 'screens/auth/login_screen.dart';
import 'screens/farm/add_edit_livestock_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/farm/livestock_screen.dart';
import 'screens/livestock/livestock_management_screen.dart';
import 'screens/farm/farm_list_screen.dart';
import 'screens/trading/trading_list_screen.dart';
import 'screens/transport/transport_list_screen.dart';
import 'screens/financial_screen.dart';
import 'screens/survey/livestock_survey_screen.dart';
import 'screens/trading/market_screen.dart';
import 'screens/farmer_group/farmer_group_screen.dart';
import 'screens/survey/survey_list_screen.dart';
import 'screens/survey/survey_detail_screen.dart';
import 'screens/dashboard/project_report_screen.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/research/research_screen.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => FinancialProvider()),
        ChangeNotifierProvider(create: (_) => SurveyProvider()),
        ChangeNotifierProvider(create: (_) => TradingProvider()),
        ChangeNotifierProvider(create: (_) => TransportProvider()),
        ChangeNotifierProvider(create: (_) => FarmerGroupProvider()),
        ChangeNotifierProvider(create: (_) => LivestockProvider()),
        ChangeNotifierProvider(create: (_) => FarmRecordProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ChangeNotifierProvider(create: (_) => ResearchProvider()),
        // ChangeNotifierProvider(create: (_) => AdvancedFinancialProvider()),
        // ChangeNotifierProvider(create: (_) => GPSProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'ระบบจัดการฟาร์มปศุสัตว์',
            theme: AppTheme.lightTheme.copyWith(
              textTheme: AppTheme.lightTheme.textTheme.apply(
                fontSizeFactor: 1.4, // เพิ่มขนาดฟอนต์ 40%
                fontSizeDelta: 2.0,   // เพิ่มขนาดฟอนต์อีก 2pt
              ),
            ),
            routerConfig: _createRouter(authProvider),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isLoggedIn ? '/dashboard' : '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
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
          builder: (context, state) => const LivestockSurveyScreen(),
        ),
        GoRoute(
          path: '/survey-list',
          builder: (context, state) => const SurveyListScreen(),
        ),
        GoRoute(
          path: '/survey-detail',
          builder: (context, state) {
            final survey = state.extra as FarmSurvey;
            return SurveyDetailScreen(survey: survey);
          },
        ),
        GoRoute(
          path: '/market',
          builder: (context, state) => const MarketScreen(),
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
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/feed-management',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isLoggingIn = state.matchedLocation == '/login';
        
        if (!isLoggedIn && !isLoggingIn) return '/login';
        if (isLoggedIn && isLoggingIn) return '/dashboard';
        return null;
      },
    );
  }
}

