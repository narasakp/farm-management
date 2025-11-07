import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'dart:convert';
import '../utils/app_theme.dart';

/// Custom Quill Editor Widget สำหรับ Webboard
/// รองรับ Thai language, Rich text formatting, และ HTML conversion
class QuillEditorWidget extends StatefulWidget {
  final quill.QuillController controller;
  final String? hint;
  final double height;
  final bool readOnly;
  final bool showToolbar;

  const QuillEditorWidget({
    super.key,
    required this.controller,
    this.hint,
    this.height = 300,
    this.readOnly = false,
    this.showToolbar = true,
  });

  @override
  State<QuillEditorWidget> createState() => _QuillEditorWidgetState();
}

class _QuillEditorWidgetState extends State<QuillEditorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Toolbar
          if (widget.showToolbar && !widget.readOnly)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: quill.QuillSimpleToolbar(
                controller: widget.controller,
                config: quill.QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                  showAlignmentButtons: false,
                  showDirection: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showCodeBlock: false,
                  showInlineCode: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: true,
                  showDividers: true,
                  showHeaderStyle: true,
                  showListBullets: true,
                  showListNumbers: true,
                  showListCheck: false,
                  showQuote: true,
                  showIndent: false,
                  showLink: true,
                  showUndo: true,
                  showRedo: true,
                ),
              ),
            ),
          // Editor
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: quill.QuillEditor.basic(
                controller: widget.controller,
                config: const quill.QuillEditorConfig(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class สำหรับแปลง Quill Document เป็น HTML
class QuillToHtmlConverter {
  /// แปลง QuillController เป็น HTML
  static String toHtml(quill.QuillController controller) {
    try {
      final delta = controller.document.toDelta();
      final deltaJson = delta.toJson();
      
      final converter = QuillDeltaToHtmlConverter(
        List.castFrom(deltaJson),
        ConverterOptions.forEmail(),
      );
      
      return converter.convert();
    } catch (e) {
      print('❌ Error converting Quill to HTML: $e');
      return controller.document.toPlainText();
    }
  }

  /// แปลง HTML เป็น Quill Delta (สำหรับ load existing content)
  static quill.QuillController fromHtml(String html) {
    try {
      // สำหรับ HTML → Delta conversion อาจต้องใช้ html_to_delta package
      // ตอนนี้ใช้ plain text ไปก่อน
      final controller = quill.QuillController.basic();
      if (html.isNotEmpty) {
        // Strip HTML tags for now
        final plainText = html.replaceAll(RegExp(r'<[^>]*>'), '');
        controller.document.insert(0, plainText);
      }
      return controller;
    } catch (e) {
      print('❌ Error converting HTML to Quill: $e');
      return quill.QuillController.basic();
    }
  }

  /// ตรวจสอบว่า content ว่างเปล่าหรือไม่
  static bool isEmpty(quill.QuillController controller) {
    final plainText = controller.document.toPlainText().trim();
    return plainText.isEmpty || plainText == '\n';
  }

  /// ดึง plain text
  static String toPlainText(quill.QuillController controller) {
    return controller.document.toPlainText().trim();
  }
}

/// Widget สำหรับแสดง HTML content (อ่านอย่างเดียว)
class QuillHtmlViewer extends StatelessWidget {
  final String htmlContent;

  const QuillHtmlViewer({
    super.key,
    required this.htmlContent,
  });

  @override
  Widget build(BuildContext context) {
    // ใช้ flutter_html แทน Quill viewer เพื่อประสิทธิภาพที่ดีกว่า
    return Container(
      padding: const EdgeInsets.all(12),
      child: SelectableText(
        htmlContent.replaceAll(RegExp(r'<[^>]*>'), ''),
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }
}
