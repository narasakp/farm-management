import 'package:go_router/go_router.dart';
import '../../config/deep_link_config.dart';
import '../../screens/social_commerce/quick_buy_screen.dart';
import '../../services/social_commerce/deep_link_service.dart';

/// Router Integration สำหรับ Deep Links
class RouterIntegration {
  static final DeepLinkService _deepLinkService = DeepLinkService();
  
  /// เพิ่ม routes สำหรับ Social Commerce
  static List<GoRoute> getSocialCommerceRoutes() {
    return [
      // Quick Buy Route
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
      
      // Market Listing Detail (with social tracking)
      GoRoute(
        path: '/market-detail/:listingId',
        name: 'market-detail-social',
        builder: (context, state) {
          final listingId = state.pathParameters['listingId']!;
          final source = state.uri.queryParameters['source'];
          
          // Track deep link click
          if (source != null) {
            _deepLinkService.handleDeepLink(state.uri);
          }
          
          // Return your existing market detail screen
          // This is a placeholder - replace with your actual screen
          return QuickBuyScreen(
            listingId: listingId,
            source: source,
          );
        },
      ),
    ];
  }
  
  /// Handle incoming deep link
  static Future<String?> handleIncomingLink(Uri uri) async {
    try {
      // Parse deep link
      final deepLinkData = DeepLinkConfig.parseUrl(uri);
      
      if (deepLinkData == null) {
        print('❌ Invalid deep link: $uri');
        return null;
      }
      
      print('✅ Handling deep link: $deepLinkData');
      
      // Track the click
      await _deepLinkService.handleDeepLink(uri);
      
      // Return route path for GoRouter
      if (deepLinkData.isBuyAction) {
        return '/quick-buy/${deepLinkData.id}?source=${deepLinkData.source}';
      } else {
        return '/market-detail/${deepLinkData.id}?source=${deepLinkData.source}';
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
      return null;
    }
  }
  
  /// Initialize deep link listener
  static Future<void> initialize(GoRouter router) async {
    try {
      // Initialize deep link service
      await _deepLinkService.initialize();
      
      print('✅ Router integration initialized');
    } catch (e) {
      print('❌ Error initializing router integration: $e');
    }
  }
  
  /// Handle deep link and navigate
  static Future<void> handleAndNavigate(GoRouter router, Uri uri) async {
    final path = await handleIncomingLink(uri);
    
    if (path != null) {
      router.go(path);
    }
  }
}

/// GoRouter Redirect Handler สำหรับ Deep Links
class DeepLinkRedirect {
  /// Check if should redirect to deep link path
  static String? redirect(GoRouterState state) {
    final uri = state.uri;
    
    // Check if this is a deep link
    if (DeepLinkConfig.isDeepLink(uri.toString())) {
      final deepLinkData = DeepLinkConfig.parseUrl(uri);
      
      if (deepLinkData != null) {
        // Track the click
        DeepLinkService().handleDeepLink(uri);
        
        // Return the route path
        return deepLinkData.routePath;
      }
    }
    
    return null;
  }
}

/// Example GoRouter setup with Social Commerce routes
GoRouter createRouterWithSocialCommerce() {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      // Existing routes...
      
      // Add Social Commerce routes
      ...RouterIntegration.getSocialCommerceRoutes(),
      
      // Catch-all for deep links
      GoRoute(
        path: '/market/:listingId',
        redirect: (context, state) {
          // Redirect to appropriate handler based on query params
          final source = state.uri.queryParameters['source'];
          final action = state.uri.queryParameters['action'];
          
          if (action == 'buy_now') {
            return '/quick-buy/${state.pathParameters['listingId']}?source=$source';
          }
          
          return '/market-detail/${state.pathParameters['listingId']}?source=$source';
        },
      ),
    ],
    redirect: (context, state) {
      // Global redirect handler for deep links
      return DeepLinkRedirect.redirect(state);
    },
  );
}
