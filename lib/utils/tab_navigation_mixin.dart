import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mixin สำหรับจัดการ Smart Back Navigation ใน Screens ที่มี TabController
/// 
/// วิธีใช้งาน:
/// 1. ใน State class ให้ใช้ `with TabNavigationMixin`
/// 2. เรียก `initTabNavigation(tabController, initialTab)` ใน initState
/// 3. เรียก `disposeTabNavigation()` ใน dispose
/// 4. ใช้ `navigateToTab(index)` แทน `tabController.animateTo(index)`
/// 5. ใช้ `handleSmartBackPress()` สำหรับปุ่ม back
mixin TabNavigationMixin<T extends StatefulWidget> on State<T> {
  // Tab History Stack
  final List<int> _tabHistory = [];
  bool _isNavigatingBack = false;
  bool _isTabTrackingPaused = false; // Flag to temporarily pause tracking
  bool shouldSkipTracking = false; // Public flag that State can set
  TabController? _tabController;
  String? _fallbackRoute;

  /// เริ่มต้น Tab Navigation
  /// 
  /// [controller] - TabController ที่จะใช้งาน
  /// [initialTab] - Tab เริ่มต้น (default: 0)
  /// [fallbackRoute] - Route ที่จะไปเมื่อไม่มี history (default: '/dashboard')
  void initTabNavigation(
    TabController controller, {
    int initialTab = 0,
    String fallbackRoute = '/dashboard',
  }) {
    _tabController = controller;
    _fallbackRoute = fallbackRoute;
    _tabHistory.clear();
    _tabHistory.add(initialTab);
    
    // Listen to tab changes
    _tabController!.addListener(_onTabChanged);
    
    print('🎯 Tab Navigation initialized with tab $initialTab');
  }

  /// ปิด Tab Navigation
  void disposeTabNavigation() {
    _tabController?.removeListener(_onTabChanged);
    _tabHistory.clear();
  }

  /// Pause tab tracking (for non-tab state updates)
  void pauseTabTracking() {
    _isTabTrackingPaused = true;
  }
  
  /// Resume tab tracking
  void resumeTabTracking() {
    _isTabTrackingPaused = false;
  }

  /// Callback เมื่อ tab เปลี่ยน (เพิ่ม history อัตโนมัติ)
  void _onTabChanged() {
    if (_tabController == null) return;
    
    // Skip if State set flag (e.g., during filter updates)
    if (shouldSkipTracking) {
      return;
    }
    
    // Skip if tracking is paused
    if (_isTabTrackingPaused) {
      return;
    }
    
    // Skip if currently animating or navigating back
    if (_tabController!.indexIsChanging || _isNavigatingBack) {
      return;
    }
    
    // Skip if animation is not completed/idle
    if (_tabController!.animation?.status != AnimationStatus.completed &&
        _tabController!.animation?.status != AnimationStatus.dismissed) {
      return;
    }
    
    final newTab = _tabController!.index;
    
    // Validate tab index is within range
    if (newTab < 0 || newTab >= _tabController!.length) {
      print('⚠️ Invalid tab index: $newTab (max: ${_tabController!.length - 1})');
      return;
    }
    
    // Only add if different from last entry
    if (_tabHistory.isEmpty || _tabHistory.last != newTab) {
      setState(() {
        _tabHistory.add(newTab);
        print('📚 Tab History: $_tabHistory');
      });
    }
  }

  /// Navigate ไป tab ที่ระบุ และเพิ่มเข้า history
  /// 
  /// [tabIndex] - Tab index ที่จะไป
  /// [callback] - Callback ที่จะเรียกก่อน navigate (สำหรับ setState)
  void navigateToTab(int tabIndex, {VoidCallback? callback}) {
    if (_tabController == null) return;
    
    setState(() {
      callback?.call();
      
      // เพิ่ม tab เข้า history (ถ้ายังไม่มี)
      if (_tabHistory.isEmpty || _tabHistory.last != tabIndex) {
        _tabHistory.add(tabIndex);
        print('➡️ Navigate to Tab $tabIndex, History: $_tabHistory');
      }
    });
    
    _tabController!.animateTo(tabIndex);
  }

  /// จัดการปุ่ม Back อย่างชาญฉลาด
  /// 
  /// - ถ้ามี tab history → กลับ tab ก่อนหน้า
  /// - ถ้าไม่มี history → กลับหน้าจริงๆ หรือไป fallback route
  /// 
  /// [onBackToFirstTab] - Callback เมื่อกลับไป tab แรก (สำหรับ clear state)
  void handleSmartBackPress({VoidCallback? onBackToFirstTab}) {
    if (_tabController == null) return;
    
    // ถ้ามี tab history มากกว่า 1 (มีหน้าก่อนหน้า)
    if (_tabHistory.length > 1) {
      setState(() {
        _isNavigatingBack = true;
        
        // ลบ tab ปัจจุบันออก
        _tabHistory.removeLast();
        
        // กลับไป tab ก่อนหน้า
        final previousTab = _tabHistory.last;
        
        print('⬅️ Back to Tab $previousTab, History: $_tabHistory');
        
        // เรียก callback ถ้ากลับไป tab แรก
        if (previousTab == _tabHistory.first) {
          onBackToFirstTab?.call();
        }
        
        _tabController!.animateTo(previousTab);
        
        // Reset flag หลังจาก animation เสร็จ
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _isNavigatingBack = false);
          }
        });
      });
    } else {
      // ถ้าไม่มี history แล้ว ให้กลับหน้าจริงๆ
      // ✅ FIX: ใช้ context.go() แทน Navigator.pop() เพราะใช้ go_router
      if (_fallbackRoute != null) {
        print('📤 No tab history, going to $_fallbackRoute');
        context.go(_fallbackRoute!);
      } else {
        print('📤 No tab history, going to /');
        context.go('/'); // ไปหน้าแรก (จะ redirect ตาม auth state)
      }
    }
  }

  /// ดึงจำนวน tab history ปัจจุบัน
  int get tabHistoryLength => _tabHistory.length;

  /// ดึง tab ปัจจุบันจาก history
  int? get currentTabFromHistory => _tabHistory.isNotEmpty ? _tabHistory.last : null;

  /// เช็คว่ามี tab history หรือไม่
  bool get hasTabHistory => _tabHistory.length > 1;

  /// ดึง tooltip สำหรับปุ่ม back
  String get backButtonTooltip {
    if (_tabHistory.length > 1) {
      return 'กลับ Tab ก่อนหน้า';
    } else {
      return 'กลับหน้าก่อนหน้า';
    }
  }

  /// Clear tab history (รีเซ็ตกลับไป tab เริ่มต้น)
  void clearTabHistory(int initialTab) {
    setState(() {
      _tabHistory.clear();
      _tabHistory.add(initialTab);
      print('🔄 Tab History cleared, reset to tab $initialTab');
    });
  }
}
