import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock_farm_management/models/social_share.dart';

void main() {
  group('SocialShare Model Tests', () {
    test('should create SocialShare from valid JSON', () {
      // Arrange
      final json = {
        'id': 'share123',
        'listingId': 'listing123',
        'userId': 'user123',
        'platform': 'facebook',
        'contentType': 'image',
        'templateId': 'card',
        'shareUrl': 'https://farm-app.com/market/listing123',
        'shareContent': 'ขายโคเนื้อคุณภาพ',
        'viewCount': 100,
        'clickCount': 10,
        'conversionCount': 2,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Act
      final share = SocialShare.fromJson(json);

      // Assert
      expect(share.id, 'share123');
      expect(share.listingId, 'listing123');
      expect(share.platform, 'facebook');
      expect(share.viewCount, 100);
      expect(share.clickCount, 10);
      expect(share.conversionCount, 2);
    });

    test('should convert SocialShare to JSON correctly', () {
      // Arrange
      final share = SocialShare(
        id: 'share123',
        listingId: 'listing123',
        userId: 'user123',
        platform: 'facebook',
        contentType: 'image',
        templateId: 'card',
        shareUrl: 'https://farm-app.com/market/listing123',
        shareContent: 'ขายโคเนื้อคุณภาพ',
        viewCount: 100,
        clickCount: 10,
        conversionCount: 2,
        createdAt: DateTime.now(),
      );

      // Act
      final json = share.toJson();

      // Assert
      expect(json['id'], 'share123');
      expect(json['platform'], 'facebook');
      expect(json['viewCount'], 100);
      expect(json['clickCount'], 10);
      expect(json['conversionCount'], 2);
    });

    test('should calculate conversion rate correctly', () {
      // Arrange & Act
      final share1 = SocialShare(
        id: 'share1',
        listingId: 'listing1',
        userId: 'user1',
        platform: 'facebook',
        contentType: 'image',
        templateId: 'card',
        shareUrl: 'https://farm-app.com/market/listing1',
        clickCount: 100,
        conversionCount: 15,
        createdAt: DateTime.now(),
      );

      final share2 = SocialShare(
        id: 'share2',
        listingId: 'listing2',
        userId: 'user2',
        platform: 'tiktok',
        contentType: 'video',
        templateId: 'video',
        shareUrl: 'https://farm-app.com/market/listing2',
        clickCount: 0,
        conversionCount: 0,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(share1.conversionRate, 15.0);
      expect(share2.conversionRate, 0.0);
    });

    test('should handle null values gracefully', () {
      // Arrange
      final json = {
        'id': 'share123',
        'listingId': 'listing123',
        'userId': 'user123',
        'platform': 'facebook',
        'contentType': 'image',
        'templateId': 'card',
        'shareUrl': 'https://farm-app.com/market/listing123',
        'createdAt': DateTime.now().toIso8601String(),
        'viewCount': null,
        'clickCount': null,
        'conversionCount': null,
      };

      // Act
      final share = SocialShare.fromJson(json);

      // Assert
      expect(share.viewCount, 0);
      expect(share.clickCount, 0);
      expect(share.conversionCount, 0);
      expect(share.conversionRate, 0.0);
    });

    test('should validate platform enum', () {
      // Arrange
      final validPlatforms = ['facebook', 'tiktok', 'x', 'line'];

      // Act & Assert
      for (final platform in validPlatforms) {
        final share = SocialShare(
          id: 'share1',
          listingId: 'listing1',
          userId: 'user1',
          platform: platform,
          contentType: 'image',
          templateId: 'card',
          shareUrl: 'https://farm-app.com/market/listing1',
          createdAt: DateTime.now(),
        );
        expect(share.platform, platform);
      }
    });

    test('should calculate CTR (Click Through Rate) correctly', () {
      // Arrange & Act
      final share = SocialShare(
        id: 'share1',
        listingId: 'listing1',
        userId: 'user1',
        platform: 'facebook',
        contentType: 'image',
        templateId: 'card',
        shareUrl: 'https://farm-app.com/market/listing1',
        viewCount: 1000,
        clickCount: 100,
        conversionCount: 15,
        createdAt: DateTime.now(),
      );

      // Calculate CTR
      final ctr = share.viewCount > 0 
          ? (share.clickCount / share.viewCount) * 100 
          : 0.0;

      // Assert
      expect(ctr, 10.0);
    });
  });

  group('SocialShare Stats Calculations', () {
    test('should aggregate multiple shares correctly', () {
      // Arrange
      final shares = [
        SocialShare(
          id: 'share1',
          listingId: 'listing1',
          userId: 'user1',
          platform: 'facebook',
          contentType: 'image',
          templateId: 'card',
          shareUrl: 'https://farm-app.com/market/listing1',
          viewCount: 100,
          clickCount: 10,
          conversionCount: 2,
          createdAt: DateTime.now(),
        ),
        SocialShare(
          id: 'share2',
          listingId: 'listing1',
          userId: 'user1',
          platform: 'tiktok',
          contentType: 'video',
          templateId: 'video',
          shareUrl: 'https://farm-app.com/market/listing1',
          viewCount: 200,
          clickCount: 25,
          conversionCount: 5,
          createdAt: DateTime.now(),
        ),
      ];

      // Act
      final totalViews = shares.fold<int>(0, (sum, share) => sum + (share.viewCount as int));
      final totalClicks = shares.fold<int>(0, (sum, share) => sum + (share.clickCount as int));
      final totalConversions = shares.fold<int>(0, (sum, share) => sum + (share.conversionCount as int));

      // Assert
      expect(totalViews, 300);
      expect(totalClicks, 35);
      expect(totalConversions, 7);
    });
  });
}
