/**
 * Mention Renderer Utility
 * แปลง @username เป็น clickable links และแสดงสีพิเศษ
 */

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';

class MentionRenderer {
  /// แปลง text ที่มี @mention เป็น RichText with clickable links
  static TextSpan renderMentions(String text, BuildContext context, {TextStyle? baseStyle}) {
    if (text.isEmpty) return TextSpan(text: text, style: baseStyle);

    final mentionPattern = RegExp(r'@([a-zA-Z0-9_]{3,20})');
    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in mentionPattern.allMatches(text)) {
      // Add text before mention
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      // Add mention as clickable link
      final username = match.group(1)!;
      spans.add(TextSpan(
        text: '@$username',
        style: baseStyle?.copyWith(
          color: Colors.blue[700],
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ) ?? TextStyle(
          color: Colors.blue[700],
          fontWeight: FontWeight.w600,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // Navigate to user profile
            context.push('/user/$username');
          },
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }

  /// แปลง HTML content ที่มี @mention
  static String renderMentionsInHtml(String html) {
    if (html.isEmpty) return html;

    final mentionPattern = RegExp(r'@([a-zA-Z0-9_]{3,20})');
    
    return html.replaceAllMapped(mentionPattern, (match) {
      final username = match.group(1)!;
      return '<span class="mention" style="color: #1976d2; font-weight: 600;">@$username</span>';
    });
  }

  /// Extract all mentions from text
  static List<String> extractMentions(String text) {
    if (text.isEmpty) return [];

    final mentionPattern = RegExp(r'@([a-zA-Z0-9_]{3,20})');
    final mentions = <String>[];

    for (final match in mentionPattern.allMatches(text)) {
      final username = match.group(1)!;
      if (!mentions.contains(username)) {
        mentions.add(username);
      }
    }

    return mentions;
  }

  /// Check if text contains mentions
  static bool hasMentions(String text) {
    return RegExp(r'@([a-zA-Z0-9_]{3,20})').hasMatch(text);
  }
}
