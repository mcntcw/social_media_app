import 'package:flutter/material.dart';

class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final String? errorMessage;
  final String? Function(String?)? onChanged;
  final VoidCallback? onTap;
  const FormTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.keyboardType,
      this.suffixIcon,
      this.prefixIcon,
      this.validator,
      this.focusNode,
      this.errorMessage,
      this.onChanged,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 14),
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: false,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4)),
        errorText: errorMessage,
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(18),
        //   borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary),
        // ),
      ),
    );
  }
}
