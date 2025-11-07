/// Deep Link Configuration
class DeepLinkConfig {
  // Base URL for deep links
  static const String baseUrl = 'https://farm-app.com';
  static const String appScheme = 'farmapp';
  
  // Deep link paths
  static const String marketPath = '/market';
  static const String buyPath = '/buy';
  static const String tradePath = '/trade';
  static const String livestockPath = '/livestock';
  
  // URL patterns
  static const List<String> supportedHosts = [
    'farm-app.com',
    'www.farm-app.com',
  ];
  
  /// Generate deep link URL
  static String generateUrl({
    required String path,
    required String id,
    Map<String, String>? queryParams,
  }) {
    final uri = Uri.https('farm-app.com', '$path/$id', queryParams);
    return uri.toString();
  }
  
  /// Generate market listing deep link
  static String marketListingUrl({
    required String listingId,
    required String source,
    String? campaign,
  }) {
    return generateUrl(
      path: marketPath,
      id: listingId,
      queryParams: {
        'source': source,
        'utm_source': source,
        'utm_medium': 'social',
        if (campaign != null) 'campaign': campaign,
        if (campaign != null) 'utm_campaign': campaign,
      },
    );
  }
  
  /// Generate buy direct link
  static String buyDirectUrl({
    required String listingId,
    required String source,
  }) {
    return generateUrl(
      path: buyPath,
      id: listingId,
      queryParams: {
        'source': source,
        'utm_source': source,
        'utm_medium': 'social',
        'action': 'buy_now',
      },
    );
  }
  
  /// Parse deep link URL
  static DeepLinkData? parseUrl(Uri uri) {
    // Check if host is supported
    if (!supportedHosts.contains(uri.host) && uri.scheme != appScheme) {
      return null;
    }
    
    // Parse path segments
    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;
    
    final action = segments[0];
    final id = segments.length > 1 ? segments[1] : null;
    
    if (id == null) return null;
    
    return DeepLinkData(
      action: action,
      id: id,
      source: uri.queryParameters['source'] ?? 'direct',
      campaign: uri.queryParameters['campaign'],
      queryParams: uri.queryParameters,
    );
  }
  
  /// Check if URL is a deep link
  static bool isDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      return supportedHosts.contains(uri.host) || uri.scheme == appScheme;
    } catch (e) {
      return false;
    }
  }
}

/// Deep Link Data
class DeepLinkData {
  final String action; // market, buy, trade, livestock
  final String id; // listingId, livestockId, etc.
  final String source; // facebook, tiktok, x, line, direct
  final String? campaign;
  final Map<String, String> queryParams;
  
  DeepLinkData({
    required this.action,
    required this.id,
    required this.source,
    this.campaign,
    this.queryParams = const {},
  });
  
  /// Get route path for GoRouter
  String get routePath {
    switch (action) {
      case 'market':
        return '/market-detail/$id';
      case 'buy':
        return '/quick-buy/$id';
      case 'trade':
        return '/trade-detail/$id';
      case 'livestock':
        return '/livestock-detail/$id';
      default:
        return '/market-detail/$id';
    }
  }
  
  /// Check if this is a buy action
  bool get isBuyAction => 
      action == 'buy' || queryParams['action'] == 'buy_now';
  
  @override
  String toString() {
    return 'DeepLinkData(action: $action, id: $id, source: $source, campaign: $campaign)';
  }
}
