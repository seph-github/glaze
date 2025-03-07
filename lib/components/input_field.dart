import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glaze/styles/color_pallete.dart';

class InputField extends HookWidget {
  InputField.email({
    super.key,
    required this.label,
    this.hintText,
    this.initialValue,
    this.validator,
    this.onChanged,
    TextEditingController? controller,
  })  : obscureText = false,
        controller = controller ?? TextEditingController(text: initialValue),
        keyboardType = TextInputType.emailAddress,
        _inputAction = TextInputAction.next;

  InputField.password({
    super.key,
    required this.label,
    this.hintText,
    TextEditingController? controller,
    this.initialValue,
    this.validator,
    this.onChanged,
  })  : obscureText = true,
        controller = controller ?? TextEditingController(text: initialValue),
        keyboardType = TextInputType.text,
        _inputAction = TextInputAction.go;

  final String label;
  final String? hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextInputAction _inputAction;
  final String Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final isObscured = useState(obscureText);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
          cursorColor: ColorPallete.whiteSmoke,
          decoration: InputDecoration(
            hintText: hintText,
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
            suffixIcon: obscureText
                ? GestureDetector(
                    onTap: () => isObscured.value = !isObscured.value,
                    child: isObscured.value
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                  )
                : null,
          ),
          obscureText: isObscured.value,
          keyboardType: keyboardType,
          textInputAction: _inputAction,
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
