import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../core/styles/color_pallete.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              fillColor: Colors.white10,
              filled: true,
              hintText: 'Search for \'Basketball 🏀\'',
              prefixIcon: SvgPicture.asset(
                'assets/images/svg/search_icon.svg',
                fit: BoxFit.scaleDown,
              ),
              hintStyle: const TextStyle(
                color: ColorPallete.hintTextColor,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
                borderSide: const BorderSide(
                  color: ColorPallete.whiteSmoke,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
                borderSide: const BorderSide(
                  color: ColorPallete.whiteSmoke,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
                borderSide: const BorderSide(
                  width: 1 / 4,
                  color: ColorPallete.persianFable,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
                borderSide: const BorderSide(
                  width: 1,
                  color: ColorPallete.parlourRed,
                ),
              ),
            ),
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
          ),
        ),
        const Gap(10.0),
        Container(
          width: 56.0,
          height: 56.0,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white10,
          ),
          child: SvgPicture.asset('assets/images/svg/Filter Icon.svg'),
        ),
      ],
    );
  }
}
