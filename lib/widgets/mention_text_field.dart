/**
 * Mention TextField Widget
 * TextField with @mention autocomplete support
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';

class MentionTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final Function(String)? onChanged;
  final InputDecoration? decoration;
  final FocusNode? focusNode;

  const MentionTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.decoration,
    this.focusNode,
  });

  @override
  State<MentionTextField> createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends State<MentionTextField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isShowingSuggestions = false;
  String _currentMentionQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final cursorPosition = widget.controller.selection.baseOffset;

    if (cursorPosition < 0) return;

    // Find @ symbol before cursor
    int mentionStart = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        mentionStart = i;
        break;
      }
      if (text[i] == ' ' || text[i] == '\n') {
        break;
      }
    }

    if (mentionStart >= 0) {
      final query = text.substring(mentionStart + 1, cursorPosition);
      
      // Check if query is valid (no spaces)
      if (!query.contains(' ') && !query.contains('\n')) {
        _currentMentionQuery = query;
        _searchUsers(query);
        return;
      }
    }

    // Hide suggestions if no @ found or invalid query
    _hideSuggestions();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      _hideSuggestions();
      return;
    }

    // Debounce search
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/forum/users/search?q=$query&limit=5'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (mounted) {
            setState(() {
              _suggestions = List<Map<String, dynamic>>.from(data['users'] ?? []);
              if (_suggestions.isNotEmpty) {
                _showSuggestions();
              } else {
                _hideSuggestions();
              }
            });
          }
        }
      } catch (e) {
        print('Error searching users: $e');
      }
    });
  }

  void _showSuggestions() {
    if (_isShowingSuggestions) {
      _overlayEntry?.markNeedsBuild();
      return;
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isShowingSuggestions = true;
  }

  void _hideSuggestions() {
    _removeOverlay();
    setState(() {
      _suggestions = [];
      _isShowingSuggestions = false;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final user = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundImage: user['avatar_url'] != null
                          ? NetworkImage(user['avatar_url'])
                          : null,
                      child: user['avatar_url'] == null
                          ? Text(
                              (user['username'] ?? '?')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                    ),
                    title: Text(
                      '@${user['username']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: user['full_name'] != null
                        ? Text(
                            user['full_name'],
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                    onTap: () => _insertMention(user['username']),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _insertMention(String username) {
    final text = widget.controller.text;
    final cursorPosition = widget.controller.selection.baseOffset;

    // Find @ position
    int mentionStart = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        mentionStart = i;
        break;
      }
    }

    if (mentionStart >= 0) {
      // Replace from @ to cursor with @username
      final newText = text.substring(0, mentionStart) +
          '@$username ' +
          text.substring(cursorPosition);
      
      widget.controller.text = newText;
      widget.controller.selection = TextSelection.collapsed(
        offset: mentionStart + username.length + 2,
      );
    }

    _hideSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        decoration: widget.decoration ??
            InputDecoration(
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
