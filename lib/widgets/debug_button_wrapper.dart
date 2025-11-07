import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Debug wrapper สำหรับตรวจสอบว่าปุ่มรับ pointer events หรือไม่
class DebugButtonWrapper extends StatelessWidget {
  final Widget child;
  final String buttonName;

  const DebugButtonWrapper({
    super.key,
    required this.child,
    required this.buttonName,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        developer.log('🟢 Mouse ENTER: $buttonName', name: 'DebugButton');
        print('🟢 Mouse ENTER: $buttonName at ${event.position}');
      },
      onExit: (event) {
        developer.log('🔴 Mouse EXIT: $buttonName', name: 'DebugButton');
        print('🔴 Mouse EXIT: $buttonName');
      },
      onHover: (event) {
        developer.log('🟡 Mouse HOVER: $buttonName', name: 'DebugButton');
      },
      child: Listener(
        onPointerDown: (event) {
          developer.log('👆 Pointer DOWN: $buttonName', name: 'DebugButton');
          print('👆 Pointer DOWN: $buttonName at ${event.position}');
        },
        onPointerUp: (event) {
          developer.log('👆 Pointer UP: $buttonName', name: 'DebugButton');
          print('👆 Pointer UP: $buttonName');
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Debug overlay สำหรับแสดงข้อมูล pointer position
class DebugPointerOverlay extends StatefulWidget {
  final Widget child;

  const DebugPointerOverlay({
    super.key,
    required this.child,
  });

  @override
  State<DebugPointerOverlay> createState() => _DebugPointerOverlayState();
}

class _DebugPointerOverlayState extends State<DebugPointerOverlay> {
  Offset _pointerPosition = Offset.zero;
  bool _isPointerDown = false;
  String _lastHitWidget = 'None';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerMove: (event) {
            setState(() {
              _pointerPosition = event.position;
            });
          },
          onPointerDown: (event) {
            setState(() {
              _isPointerDown = true;
              _pointerPosition = event.position;
            });
            print('🔴 POINTER DOWN at ${event.position}');
          },
          onPointerUp: (event) {
            setState(() {
              _isPointerDown = false;
            });
            print('🟢 POINTER UP at ${event.position}');
          },
          behavior: HitTestBehavior.translucent,
          child: widget.child,
        ),
        // Debug info overlay
        Positioned(
          top: 100,
          right: 10,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🐛 DEBUG INFO',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position: ${_pointerPosition.dx.toInt()}, ${_pointerPosition.dy.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Down: ${_isPointerDown ? "YES 🔴" : "NO 🟢"}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Last Hit: $_lastHitWidget',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
