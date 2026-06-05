import 'package:flutter/material.dart';

class GymmyInput extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? errorText;

  const GymmyInput({
    super.key,
    required this.label,
    this.hintText,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.errorText,
  });

  @override
  State<GymmyInput> createState() => _GymmyInputState();
}

class _GymmyInputState extends State<GymmyInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? theme.colorScheme.outline
        : theme.colorScheme.onSurface.withValues(alpha: 0.1);
    final hintColor = isDark
        ? const Color(0xFF737B88)
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final labelColor = isDark
        ? const Color(0xFFA5ACB8)
        : theme.colorScheme.onSurface.withValues(alpha: 0.8);

    Widget? buildSuffixIcon() {
      if (widget.isPassword) {
        return IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: isDark
                ? const Color(0xFFA5ACB8)
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        );
      }
      return widget.suffixIcon;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(color: labelColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(color: hintColor),
            errorText: widget.errorText,
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1E2228)
                : theme.colorScheme.surface,
            prefixIcon: widget.prefixIcon,
            suffixIcon: buildSuffixIcon(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: isDark ? 1.5 : 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: isDark ? 1.5 : 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
