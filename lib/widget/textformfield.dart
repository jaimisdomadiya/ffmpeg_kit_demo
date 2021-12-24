import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  final bool? autoFocus;
  final ValueChanged<String>? onChange;
  final TextStyle? style;
  final String? hintText;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final TextStyle? hintStyle;
  final bool? enabled;
  final bool? obscureText;
  final Widget? suffixIcon;
  final bool? suffixIconTap;
  final bool? readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsetsGeometry? margin;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLength;

  CustomTextFormField({
    this.autoFocus,
    this.onChange,
    this.controller,
    this.style,
    this.hintText,
    this.textInputType,
    this.textInputAction,
    this.enabled,
    this.hintStyle,
    this.onFieldSubmitted,
    this.focusNode,
    this.obscureText,
    this.validator,
    this.autofillHints,
    this.readOnly,
    this.contentPadding,
    this.suffixIcon,
    this.suffixIconTap,
    this.margin,
    this.inputFormatters,
    this.maxLength = 255,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.textInputType,
      validator: widget.validator,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChange,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      style: const TextStyle(color: Colors.black, fontSize: 17),
      maxLines: 1,
      decoration: InputDecoration(
          border: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          enabledBorder: outlineInputBorder,
          disabledBorder: outlineInputBorder,
          filled: true,
          hintStyle: widget.hintStyle ??
              TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 16),
          hintText: widget.hintText,
          fillColor: Colors.grey.withOpacity(0.1)),
    );
  }

  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide.none,
  );
}
