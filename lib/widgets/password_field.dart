import 'package:flutter/material.dart';
import '../utils/password_validator.dart';

/// Senior-friendly password input field with strength indicator
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool showStrengthIndicator;
  final bool showSuggestions;
  final bool autocorrect;
  final bool enableSuggestions;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const PasswordField({
    Key? key,
    required this.controller,
    this.label = 'รหัสผ่าน',
    this.hintText,
    this.showStrengthIndicator = false,
    this.showSuggestions = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;
  String _passwordStrength = 'weak';

  void _updateStrength(String value) {
    setState(() {
      _passwordStrength = PasswordValidator.getStrength(value);
    });
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case 'strong':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'weak':
        return Colors.red;
      case 'invalid':
        return Colors.red.shade700;
      default:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password Input Field
        TextFormField(
          controller: widget.controller,
          obscureText: _obscurePassword,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          autofillHints: widget.enableSuggestions 
              ? const [AutofillHints.password]
              : null,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText ?? 'ต้องมีทั้งตัวอักษรและตัวเลข เช่น suwan123',
            labelStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Colors.green.shade600,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              tooltip: _obscurePassword ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: widget.validator ?? PasswordValidator.validate,
          onChanged: (value) {
            if (widget.showStrengthIndicator) {
              _updateStrength(value);
            }
            widget.onChanged?.call(value);
          },
        ),

        // Password Strength Indicator
        if (widget.showStrengthIndicator && widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _passwordStrength == 'strong'
                    ? Icons.check_circle
                    : _passwordStrength == 'medium'
                        ? Icons.warning
                        : _passwordStrength == 'invalid'
                            ? Icons.cancel
                            : Icons.error,
                color: _getStrengthColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _passwordStrength == 'invalid'
                    ? '${PasswordValidator.getStrengthText(_passwordStrength)}'
                    : 'ความแข็งแรง: ${PasswordValidator.getStrengthText(_passwordStrength)}',
                style: TextStyle(
                  fontSize: 14,
                  color: _getStrengthColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Strength Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passwordStrength == 'strong'
                  ? 1.0
                  : _passwordStrength == 'medium'
                      ? 0.6
                      : _passwordStrength == 'weak'
                          ? 0.3
                          : 0.1, // invalid = very low
              backgroundColor: Colors.grey.shade200,
              color: _getStrengthColor(),
              minHeight: 6,
            ),
          ),
        ],

        // Suggestions
        if (widget.showSuggestions) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'คำแนะนำ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...PasswordValidator.getSuggestions().map((suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
