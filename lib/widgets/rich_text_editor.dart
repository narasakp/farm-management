import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../config/api_config.dart';

class RichTextEditor extends StatefulWidget {
  final HtmlEditorController controller;
  final String? hint;
  final double height;
  final bool enableImageUpload;

  const RichTextEditor({
    super.key,
    required this.controller,
    this.hint,
    this.height = 300,
    this.enableImageUpload = true,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  Future<String> _uploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return '';
      }

      final file = result.files.first;
      final bytes = file.bytes;
      
      if (bytes == null) {
        return '';
      }

      // Upload to backend
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/upload/image'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: file.name,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['url'] ?? '';
      }

      return '';
    } catch (e) {
      print('Image upload error: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: HtmlEditor(
        controller: widget.controller,
        htmlEditorOptions: HtmlEditorOptions(
          hint: widget.hint ?? 'เขียนเนื้อหากระทู้ของคุณ...',
          shouldEnsureVisible: false,
          initialText: '',
          autoAdjustHeight: false,
          adjustHeightForKeyboard: false,
        ),
        htmlToolbarOptions: HtmlToolbarOptions(
          toolbarPosition: ToolbarPosition.aboveEditor,
          toolbarType: ToolbarType.nativeScrollable,
          defaultToolbarButtons: [
            const StyleButtons(style: false),
            const FontSettingButtons(
              fontSizeUnit: false,
            ),
            const FontButtons(
              subscript: false,
              superscript: false,
              clearAll: false,
            ),
            const ColorButtons(),
            const ListButtons(listStyles: false),
            const ParagraphButtons(
              textDirection: false,
              lineHeight: false,
              caseConverter: false,
              decreaseIndent: false,
              increaseIndent: false,
            ),
            const InsertButtons(
              table: false,
              hr: false,
              video: false,
              audio: false,
              otherFile: false,
            ),
            const OtherButtons(
              copy: false,
              paste: false,
            ),
          ],
          toolbarItemHeight: 40,
          buttonColor: AppTheme.primaryColor,
          buttonSelectedColor: AppTheme.primaryColor.withOpacity(0.2),
          buttonFocusColor: AppTheme.primaryColor.withOpacity(0.1),
          buttonBorderColor: Colors.grey[300],
          buttonFillColor: Colors.white,
          dropdownBackgroundColor: Colors.white,
          dropdownItemHeight: 40,
          dropdownBoxDecoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        otherOptions: OtherOptions(
          height: widget.height,
        ),
        callbacks: Callbacks(
          onInit: () {
            print('✅ HTML Editor initialized');
          },
          onFocus: () {
            // Editor focused
          },
          onBlur: () {
            // Editor blurred
          },
          onChangeContent: (String? changed) {
            // Content changed
          },
          onImageUploadError: (FileUpload? file, String? base64Str, UploadError error) {
            print('❌ Image upload error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('เกิดข้อผิดพลาดในการอัพโหลดรูปภาพ: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }
}

class RichTextViewer extends StatelessWidget {
  final String htmlContent;

  const RichTextViewer({
    super.key,
    required this.htmlContent,
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      data: htmlContent,
      style: {
        "body": Style(
          fontSize: FontSize(16),
          lineHeight: const LineHeight(1.6),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        "p": Style(
          margin: Margins.only(bottom: 8),
        ),
        "ul": Style(
          margin: Margins.only(left: 16, bottom: 8),
        ),
        "ol": Style(
          margin: Margins.only(left: 16, bottom: 8),
        ),
        "li": Style(
          margin: Margins.only(bottom: 4),
        ),
        "h1": Style(
          fontSize: FontSize(24),
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 12),
        ),
        "h2": Style(
          fontSize: FontSize(20),
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 10),
        ),
        "h3": Style(
          fontSize: FontSize(18),
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 8),
        ),
        "strong": Style(
          fontWeight: FontWeight.bold,
        ),
        "em": Style(
          fontStyle: FontStyle.italic,
        ),
        "img": Style(
          width: Width(100, Unit.percent),
        ),
      },
    );
  }
}
