import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glaze/core/styles/color_pallete.dart';

class InputField extends HookWidget {
  InputField.email({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.validator,
    this.onChanged,
    TextEditingController? controller,
    this.readOnly = false,
  })  : obscureText = false,
        controller = controller ?? TextEditingController(text: initialValue),
        keyboardType = TextInputType.emailAddress,
        _inputAction = TextInputAction.next,
        maxLines = 1;

  InputField.password({
    super.key,
    this.label,
    this.hintText,
    TextEditingController? controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.readOnly = false,
  })  : obscureText = true,
        controller = controller ?? TextEditingController(text: initialValue),
        keyboardType = TextInputType.text,
        _inputAction = TextInputAction.go,
        maxLines = 1;

  InputField.text({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    TextEditingController? controller,
  })  : controller = controller ?? TextEditingController(text: initialValue),
        _inputAction = TextInputAction.next,
        obscureText = false,
        maxLines = 1;

  final String? label;
  final String? hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextInputAction _inputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final isObscured = useState(obscureText);
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
          cursorColor: ColorPallete.whiteSmoke,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.white54,
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(
                color: ColorPallete.whiteSmoke,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(
                color: ColorPallete.whiteSmoke,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(
                width: 1 / 4,
                color: ColorPallete.persianFable,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(
                width: 1,
                color: ColorPallete.parlourRed,
              ),
            ),
            suffixIcon: obscureText
                ? GestureDetector(
                    onTap: () => isObscured.value = !isObscured.value,
                    child: isObscured.value
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                  )
                : null,
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
        ),
      ],
    );
  }
}
