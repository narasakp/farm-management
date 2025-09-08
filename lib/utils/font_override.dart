import 'package:flutter/material.dart';

class FontOverride {
  static TextStyle? getOverrideStyle(BuildContext context, TextStyle? originalStyle) {
    if (originalStyle == null) return null;
    
    // Get the original font size or use a default
    double originalSize = originalStyle.fontSize ?? 14.0;
    
    // Scale up the font size by 1.5x for elderly users
    double newSize = originalSize * 1.5;
    
    // Ensure minimum font size of 16
    if (newSize < 16.0) {
      newSize = 16.0;
    }
    
    return originalStyle.copyWith(fontSize: newSize);
  }
  
  static Widget buildText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    required BuildContext context,
  }) {
    return Text(
      text,
      style: getOverrideStyle(context, style),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
