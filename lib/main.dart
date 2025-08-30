import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';
import 'providers/financial_provider.dart';
import 'providers/survey_provider.dart';
import 'providers/trading_provider.dart';
import 'providers/transport_provider.dart';
import 'providers/farmer_group_provider.dart';
import 'providers/livestock_provider.dart';
import 'providers/farm_record_provider.dart';
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
import 'screens/transport/transport_screen.dart';
import 'screens/farmer_group/farmer_group_screen.dart';
import 'screens/survey/survey_list_screen.dart';
import 'screens/survey/survey_detail_screen.dart';
import 'models/survey_form.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
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
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'ระบบจัดการฟาร์มปศุสัตว์',
            theme: AppTheme.lightTheme,
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
          path: '/transport',
          builder: (context, state) => const TransportScreen(),
        ),
        GoRoute(
          path: '/farmer-group',
          builder: (context, state) => const FarmerGroupScreen(),
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

