import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/styles/color_pallete.dart';

class CustomDropDownMenu extends HookWidget {
  const CustomDropDownMenu({
    super.key,
    required this.menus,
    this.hintText,
    required this.onSelected,
    double? borderRadius,
    this.validator,
  }) : borderRadius = borderRadius ?? 32.0;

  final List<String> menus;
  final String? hintText;
  final ValueChanged<String?> onSelected;
  final double borderRadius;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final selectedValue = useState<String?>(null);
    final focusNode = useFocusNode();

    return TextFormField(
      readOnly: true,
      focusNode: focusNode,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: ColorPallete.whiteSmoke,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: ColorPallete.whiteSmoke,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            width: 1 / 4,
            color: ColorPallete.persianFable,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            width: 1,
            color: ColorPallete.parlourRed,
          ),
        ),
        suffixIcon: DropdownButton<String>(
          value: selectedValue.value,
          hint: Text(
            hintText ?? '',
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),
          isExpanded: true,
          icon: SvgPicture.asset('assets/images/svg/Drop Down Icon.svg'),
          menuWidth: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          underline: Container(),
          onTap: () {
            focusNode.requestFocus();
          },
          onChanged: (String? newValue) {
            selectedValue.value = newValue;
            onSelected(newValue);
          },
          items: menus.map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            },
          ).toList(),
        ),
      ),
      onTapOutside: (event) => focusNode.unfocus(),
    );
  }
}
