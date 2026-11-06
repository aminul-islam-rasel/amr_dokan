import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final String? errorText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.errorText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            key: ValueKey<bool>(_obscureText),
            color: AppColors.textSecondaryLight,
            size: 20,
          ),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else {
      suffix = widget.suffixIcon;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          focusNode: widget.focusNode,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
