import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: Key(label.toLowerCase().replaceAll(' ', '_')),
          controller: controller,
          obscureText: obscureText,
          keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
          validator: validator,
          maxLines: maxLines,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,
          autofillHints: obscureText
              ? [AutofillHints.password]
              : keyboardType == TextInputType.emailAddress
              ? [AutofillHints.email]
              : null,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}
