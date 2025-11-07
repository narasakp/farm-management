import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/trading.dart';
import '../../models/livestock.dart';
import '../../providers/trading_provider.dart';
import '../../providers/production_auth_provider.dart';
import '../../services/social_commerce/deep_link_service.dart';
import '../../widgets/shopee_image_gallery.dart';
import '../../widgets/cors_image.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import 'package:intl/intl.dart';

/// หน้าซื้อด่วน (1-Click Purchase)
class QuickBuyScreen extends ConsumerStatefulWidget {
  final String listingId;
  final String? source;
  final String? campaign;
  
  const QuickBuyScreen({
    Key? key,
    required this.listingId,
    this.source,
    this.campaign,
  }) : super(key: key);
  
  @override
  ConsumerState<QuickBuyScreen> createState() => _QuickBuyScreenState();
}

class _QuickBuyScreenState extends ConsumerState<QuickBuyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;
  bool _isGuest = false;
  String _paymentMethod = 'promptpay';
  bool _hasError = false;
  String _errorMessage = '';
  int _retryCount = 0;
  
  MarketListing? _listing;
  Livestock? _livestock;
  
  @override
  void initState() {
    super.initState();
    // Delay loading to avoid setState during build
    Future.microtask(() => _loadListing());
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  Future<void> _loadListing() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    
    try {
      // Load listing data
      final provider = context.read<TradingProvider>();
      print('🔍 Loading all market listings...');
      await provider.loadMarketListings();
      
      print('🔍 Total listings loaded: ${provider.marketListings.length}');
      print('🔍 Looking for ID: ${widget.listingId}');
      
      // Print all IDs for debugging
      for (var listing in provider.marketListings) {
        print('🔍 Available ID: ${listing.id}');
      }
      
      // Find listing by ID
      final listings = provider.marketListings
          .where((listing) => listing.id == widget.listingId)
          .toList();
      
      print('🔍 Found ${listings.length} matching listings');
      
      if (listings.isEmpty) {
        throw Exception('ไม่พบรายการที่มี ID: ${widget.listingId}');
      }
      
      _listing = listings.first;
      print('✅ Listing loaded: ${_listing!.id}');
      
      setState(() => _isLoading = false);
      _retryCount = 0; // Reset retry count on success
    } catch (e) {
      print('❌ Error loading listing: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }
  
  Future<void> _retryLoading() async {
    _retryCount++;
    print('🔄 Retry attempt $_retryCount');
    await _loadListing();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.detail,  // ชั้นที่ 2: มี Back, Home, Logout
        title: 'ซื้อด่วน',
        onBackPressed: () {
          print('🔙 Back button pressed from Quick Buy');
          print('🔙 Current URL: ${GoRouterState.of(context).uri}');
          print('🔙 Can pop: ${context.canPop()}');
          
          // Force go to market
          print('🔙 Forcing navigation to /market');
          context.go('/market');
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listing == null
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: _listing != null ? _buildBottomBar() : null,
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'ไม่พบรายข้อมูลสินค้า',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_hasError)
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _retryLoading,
                  icon: const Icon(Icons.refresh),
                  label: const Text('ลองใหม่'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('กลับ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation Icons
            _buildNavigationIcons(),
            
            const SizedBox(height: 16),
            
            // Source indicator
            if (widget.source != null) Center(child: _buildSourceBadge()),
            
            const SizedBox(height: 16),
            
            // Product info
            _buildProductInfo(),
            
            const SizedBox(height: 24),
            
            // Buyer info
            _buildBuyerInfo(),
            
            const SizedBox(height: 24),
            
            // Payment method
            _buildPaymentMethod(),
            
            const SizedBox(height: 200), // Space for bottom bar + floating icon
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavigationIcons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavIcon(
            icon: Icons.home,
            label: 'หน้าแรก',
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          const SizedBox(width: 32),
          _buildNavIcon(
            icon: Icons.shopping_cart,
            label: 'ตลาด',
            onTap: () => Navigator.pushReplacementNamed(context, '/trading'),
          ),
          const SizedBox(width: 32),
          _buildNavIcon(
            icon: Icons.chat_bubble,
            label: 'แชท',
            onTap: () {
              // TODO: Implement chat functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ฟีเจอร์แชทกำลังพัฒนา')),
              );
            },
          ),
          const SizedBox(width: 32),
          _buildNavIcon(
            icon: Icons.person,
            label: 'โปรไฟล์',
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: const Color(0xFF228B22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF228B22),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSourceBadge() {
    final sourceNames = {
      'facebook': 'Facebook',
      'tiktok': 'TikTok',
      'x': 'X (Twitter)',
      'line': 'LINE',
    };
    
    final sourceColors = {
      'facebook': Color(0xFF1877F2),
      'tiktok': Colors.black,
      'x': Colors.black,
      'line': Color(0xFF00B900),
    };
    
    final sourceName = sourceNames[widget.source] ?? widget.source;
    final sourceColor = sourceColors[widget.source] ?? Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: sourceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sourceColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link, size: 16, color: sourceColor),
          const SizedBox(width: 4),
          Text(
            'มาจาก $sourceName',
            style: TextStyle(
              color: sourceColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'รายละเอียดสินค้า',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Product Image Gallery (Shopee Style)
            _buildProductImageGallery(),
            
            const SizedBox(height: 16),
            
            // Title
            Center(
              child: Text(
                _listing!.shareTitle ?? 'สินค้าปศุสัตว์',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Description
            if (_listing!.description != null)
              Center(
                child: Text(
                  _listing!.description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ราคา: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  _formatPrice(_listing!.askingPrice),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
            
            // Negotiable badge
            if (_listing!.isNegotiable)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: const Text(
                  'ต่อรองราคาได้',
                  style: TextStyle(
                    color: Color(0xFF228B22),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBuyerInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'ข้อมูลผู้ซื้อ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่อ-นามสกุล *',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกชื่อ-นามสกุล';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'เบอร์โทรศัพท์ *',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกเบอร์โทรศัพท์';
                }
                if (value.length < 10) {
                  return 'เบอร์โทรศัพท์ไม่ถูกต้อง';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Address
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'ที่อยู่จัดส่ง',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethod() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'วิธีการชำระเงิน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            RadioListTile<String>(
              value: 'promptpay',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() => _paymentMethod = value!);
              },
              title: const Row(
                children: [
                  Icon(Icons.qr_code, color: Color(0xFF1C4E9A)),
                  SizedBox(width: 12),
                  Text('PromptPay'),
                ],
              ),
              subtitle: const Text('สแกน QR Code ชำระเงิน'),
            ),
            
            RadioListTile<String>(
              value: 'bank_transfer',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() => _paymentMethod = value!);
              },
              title: const Row(
                children: [
                  Icon(Icons.account_balance, color: Color(0xFF228B22)),
                  SizedBox(width: 12),
                  Text('โอนเงินผ่านธนาคาร'),
                ],
              ),
              subtitle: const Text('โอนเงินเข้าบัญชีธนาคาร'),
            ),
            
            RadioListTile<String>(
              value: 'cod',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() => _paymentMethod = value!);
              },
              title: const Row(
                children: [
                  Icon(Icons.local_shipping, color: Color(0xFFFF6B35)),
                  SizedBox(width: 12),
                  Text('เก็บเงินปลายทาง (COD)'),
                ],
              ),
              subtitle: const Text('ชำระเงินเมื่อได้รับสินค้า'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ยอดรวม',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _formatPrice(_listing!.askingPrice),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Buy button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_checkout),
                          SizedBox(width: 8),
                          Text(
                            'ยืนยันการสั่งซื้อ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handlePurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Create order
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      
      // Mark conversion in deep link service
      final deepLinkService = DeepLinkService();
      await deepLinkService.markConversion(
        listingId: widget.listingId,
        orderId: orderId,
      );
      
      // Show success
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildSuccessDialog(orderId),
        );
        
        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Error processing purchase: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Widget _buildSuccessDialog(String orderId) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF228B22),
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'สั่งซื้อสำเร็จ!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'เลขที่คำสั่งซื้อ: $orderId',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ทีมงานจะติดต่อกลับภายใน 24 ชั่วโมง',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
  
  /// Builds product image widget
  /// 
  /// Supported formats:
  /// - SVG: Vector graphics (SvgPicture.asset/network)
  /// - JPG/JPEG: Photos (Image.asset/network)
  /// - PNG: Transparent images (Image.asset/network)
  /// - WEBP: Modern format (Image.asset/network)
  /// - GIF: Animated images (Image.asset/network)
  /// 
  /// Shopee-style Image Gallery with thumbnails
  Widget _buildProductImageGallery() {
    if (_listing == null || _listing!.images.isEmpty) {
      return _buildImagePlaceholder();
    }
    
    // If only one image or images are SVG assets, use simple display
    if (_listing!.images.length == 1 || 
        _listing!.images[0].endsWith('.svg')) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 400,
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildSingleImage(_listing!.images[0]),
          ),
        ),
      );
    }
    
    // Multiple images: Use Shopee Gallery
    return ShopeeImageGallery(
      imageUrls: _listing!.images,
      height: 400,
      thumbnailHeight: 80,
    );
  }
  
  /// Build single image (for fallback)
  Widget _buildSingleImage(String imageUrl) {
    final extension = imageUrl.toLowerCase().split('.').last;
    
    // Firebase Storage URL
    if (imageUrl.startsWith('https://firebasestorage.googleapis.com') ||
        imageUrl.startsWith('https://') ||
        imageUrl.startsWith('http://')) {
      print('🌐 Loading from URL: $imageUrl');
      
      // SVG from network
      if (extension == 'svg') {
        return SvgPicture.network(
          imageUrl,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      // Use CorsImage for other formats
      return CorsImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        errorWidget: _buildImagePlaceholder(),
      );
    }
    
    // Asset path (Local)
    print('📁 Loading from asset: $imageUrl');
    
    // SVG asset
    if (extension == 'svg') {
      return SvgPicture.asset(
        imageUrl,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Other asset formats
    return Image.asset(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Asset image error: $error');
        return _buildImagePlaceholder();
      },
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      height: 300, // ปรับให้ตรงกับ container หลัก
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'ไม่มีรูปภาพสินค้า',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '₿${NumberFormat('#,##0').format(price)}';
    }
    return '₿${price.toStringAsFixed(0)}';
  }

  String _getAssetImagePath() {
    if (_listing == null) return 'images/livestock/cattle.svg';
    final livestockId = _listing!.livestockId.toLowerCase();
    if (livestockId.contains('cattle')) return 'images/livestock/cattle.svg';
    if (livestockId.contains('pig')) return 'images/livestock/pig.svg';
    if (livestockId.contains('chicken')) return 'images/livestock/chicken.svg';
    if (livestockId.contains('duck')) return 'images/livestock/duck.svg';
    if (livestockId.contains('goat')) return 'images/livestock/goat.svg';
    return 'images/livestock/cattle.svg';
  }
}
