import 'package:flutter/material.dart';
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

/// Custom Image Widget that bypasses CORS for Firebase Storage
/// Works by using HTML <img> element with crossOrigin="anonymous"
class CorsImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onTap;

  const CorsImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.onTap,
  }) : super(key: key);

  @override
  State<CorsImage> createState() => _CorsImageState();
}

class _CorsImageState extends State<CorsImage> {
  late html.ImageElement _imgElement;
  String? _viewType;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CorsImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  void _loadImage() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Create unique view type with timestamp to avoid conflicts
    _viewType = 'cors-image-${widget.imageUrl.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
    print('🔧 Creating CorsImage viewType: $_viewType');
    print('📸 Image URL: ${widget.imageUrl}');

    // Create HTML img element with CORS support
    _imgElement = html.ImageElement()
      ..src = widget.imageUrl
      ..crossOrigin = 'anonymous'  // ✅ Fix CORS!
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = _getObjectFit(widget.fit)
      ..style.cursor = widget.onTap != null ? 'pointer' : 'default'
      ..style.pointerEvents = 'auto';  // ✅ Enable pointer events!

    // Add click handler if onTap is provided
    if (widget.onTap != null) {
      _imgElement.onClick.listen((_) {
        print('🖱️ CorsImage clicked: ${widget.imageUrl}');
        widget.onTap!();
      });
    }

    // Register view factory with error handling
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType!,
        (int viewId) {
          print('✅ View factory called for: $_viewType');
          return _imgElement;
        },
      );
      print('✅ Registered view factory: $_viewType');
    } catch (e) {
      print('❌ Failed to register view factory: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }

    // Handle load/error events
    _imgElement.onLoad.listen((_) {
      print('✅ Image loaded successfully: ${widget.imageUrl}');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    });

    _imgElement.onError.listen((event) {
      print('❌ Image load error: ${widget.imageUrl}');
      print('❌ Error event: $event');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    });
  }

  String _getObjectFit(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return 'contain';
      case BoxFit.cover:
        return 'cover';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'scale-down';
      case BoxFit.fitHeight:
        return 'scale-down';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'โหลดรูปไม่สำเร็จ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    if (_isLoading) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade100,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
    }

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: HtmlElementView(
        viewType: _viewType!,
      ),
    );
  }

  @override
  void dispose() {
    // Cleanup is handled by Flutter
    super.dispose();
  }
}
