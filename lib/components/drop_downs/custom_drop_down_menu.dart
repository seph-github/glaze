import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/styles/color_pallete.dart';

class CustomDropDownMenu extends HookWidget {
  CustomDropDownMenu({
    super.key,
    required this.menus,
    TextEditingController? controller,
    this.initialValue,
    this.hintText,
    required this.onSelected,
    double? borderRadius,
    this.validator,
    this.filled = false,
  })  : controller = controller ?? TextEditingController(text: initialValue),
        borderRadius = borderRadius ?? 32.0;

  final List<String> menus;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String?> onSelected;
  final double borderRadius;
  final String? Function(String?)? validator;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final selectedValue = useState<String?>(null);
    final focusNode = useFocusNode();

    useEffect(() {
      void listener() {
        if (controller?.text.isEmpty ?? true) {
          selectedValue.value = null; // Reset the selected value
        } else {
          selectedValue.value = controller?.text; // Sync with controller text
        }
      }

      // Add a listener to the controller to observe changes in its text
      controller?.addListener(listener);

      return () {
        controller?.removeListener(listener); // Remove the listener on cleanup
      };
    }, [
      controller
    ]); // Observe changes in the controller

    return TextFormField(
      readOnly: true,
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      // validator: (value) {
      //   if (value?.isEmpty ?? true) {
      //     return null; // Disable validation when the controller is cleared
      //   }
      //   return validator?.call(value); // Call the provided validator otherwise
      // },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        fillColor: ColorPallete.inputFilledColor,
        filled: filled,
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
            controller?.text = newValue ?? '';
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
      // onFieldSubmitted: (value) {Node.unfocus(),
      //   selectedValue.value = '';
      // },
      onTapOutside: (event) => focusNode.unfocus(),
    );
  }
}
