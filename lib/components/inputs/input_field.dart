import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InputField extends HookWidget {
  InputField({
    super.key,
    this.label,
    this.inputIcon,
    this.hintText,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.borderRadius,
    this.helper,
    this.filled = false,
    this.onTap,
    this.lightModeColor,
    TextEditingController? controller,
  })  : controller = controller ?? TextEditingController(text: initialValue),
        _inputAction = TextInputAction.next,
        obscureText = false,
        maxLines = 1;

  InputField.email({
    super.key,
    this.label,
    this.inputIcon,
    this.hintText,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.borderRadius,
    this.helper,
    this.filled = false,
    this.onTap,
    TextEditingController? controller,
    this.readOnly = false,
    this.lightModeColor,
  })  : obscureText = false,
        controller = controller ?? TextEditingController(text: initialValue),
        keyboardType = TextInputType.emailAddress,
        _inputAction = TextInputAction.next,
        maxLines = 1;

  InputField.phone({
    super.key,
    this.label,
    this.inputIcon,
    this.hintText,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.borderRadius,
    this.helper,
    this.filled = false,
    this.onTap,
    TextEditingController? controller,
    this.readOnly = false,
    this.lightModeColor,
  })  : obscureText = false,
        controller = controller ?? TextEditingController(text: initialValue),
        keyboardType = TextInputType.phone,
        _inputAction = TextInputAction.next,
        maxLines = 1;

  InputField.password({
    super.key,
    this.label,
    this.inputIcon,
    this.hintText,
    TextEditingController? controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.borderRadius,
    this.helper,
    this.filled = false,
    this.onTap,
    this.lightModeColor,
  })  : obscureText = true,
        controller = controller ?? TextEditingController(text: initialValue),
        keyboardType = TextInputType.text,
        _inputAction = TextInputAction.go,
        maxLines = 1;

  InputField.text({
    super.key,
    this.label,
    this.inputIcon,
    this.hintText,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.borderRadius,
    this.helper,
    this.filled = false,
    this.onTap,
    TextEditingController? controller,
    this.lightModeColor,
  })  : controller = controller ?? TextEditingController(text: initialValue),
        _inputAction = TextInputAction.next,
        obscureText = false,
        maxLines = 1;

  InputField.paragraph({
    super.key,
    this.label,
    this.inputIcon,
    this.hintText,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.borderRadius,
    this.helper,
    int? maxLines,
    this.filled = false,
    this.onTap,
    this.lightModeColor,
    TextEditingController? controller,
  })  : controller = controller ?? TextEditingController(text: initialValue),
        _inputAction = TextInputAction.next,
        obscureText = false,
        maxLines = maxLines ?? 5;

  final String? label;
  final String? hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextInputAction _inputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final int? maxLines;
  final bool readOnly;
  final double? borderRadius;
  final Widget? helper;
  final Widget? inputIcon;
  final bool filled;
  final Color? lightModeColor;

  @override
  Widget build(BuildContext context) {
    final isObscured = useState(obscureText);

    return Consumer(builder: (context, ref, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label ?? '',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            readOnly: readOnly,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: ColorPallete.hintTextColor,
              ),
              fillColor: ColorPallete.inputFilledColor,
              filled: filled,
              prefixIcon: inputIcon != null
                  ? Transform.scale(
                      scale: 0.5,
                      child: inputIcon,
                    )
                  : null,
              semanticCounterText: 'counter',
              helper: helper,
            ),
            controller: controller,
            obscureText: isObscured.value,
            keyboardType: keyboardType,
            textInputAction: _inputAction,
            maxLines: maxLines,
            validator: (value) {
              return validator?.call(value);
            },
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onChanged: onChanged,
            onTap: onTap,
          ),
        ],
      );
    });
  }
}
