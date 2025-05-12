import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/styles/color_pallete.dart';
import '../../data/providers/json_parser/json_parser.dart';
import '../../feature/auth/models/country_code.dart';
import '../../feature/settings/providers/settings_theme_provider.dart';

class PhoneNumberInput extends HookConsumerWidget {
  const PhoneNumberInput({
    super.key,
    this.dialCodeController,
    this.phoneController,
    this.validator,
    this.focusNode,
    this.borderRadius,
    this.lightModeColor,
    this.filled = false,
  });

  final TextEditingController? dialCodeController;
  final TextEditingController? phoneController;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final double? borderRadius;
  final Color? lightModeColor;
  final bool filled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // const double defaultBorderRadius = 16;

    return Consumer(
      builder: (context, ref, _) {
        // final isLightTheme = ref.watch(settingsThemeProvider) == ThemeData.light();
        final countryCodes = ref.watch(countryCodesProvider).value;
        return Column(
          children: [
            const Gap(6),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              focusNode: focusNode,
              decoration: InputDecoration(
                isDense: true,
                fillColor: ColorPallete.inputFilledColor,
                filled: filled,
                hintText: 'Phone Number',
                border: const OutlineInputBorder(),
                // focusedErrorBorder: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
                //   borderSide: const BorderSide(
                //     color: ColorPallete.whiteSmoke,
                //   ),
                // ),
                // focusedBorder: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
                //   borderSide: BorderSide(
                //     color: isLightTheme ? lightModeColor ?? ColorPallete.backgroundColor : ColorPallete.whiteSmoke,
                //   ),
                // ),
                // enabledBorder: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
                //   borderSide: BorderSide(
                //     width: 1 / 4,
                //     color: isLightTheme ? lightModeColor ?? ColorPallete.backgroundColor : ColorPallete.persianFable,
                //   ),
                // ),
                // errorBorder: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
                //   borderSide: const BorderSide(
                //     width: 1,
                //     color: ColorPallete.parlourRed,
                //   ),
                // ),
                prefixIcon: Container(
                  alignment: Alignment.center,
                  width: 60,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: TextField(
                    controller: dialCodeController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      hintText: countryCodes?[countryCodes.indexWhere(
                        (code) {
                          if (dialCodeController!.text.isNotEmpty) {
                            return code.dialCode == dialCodeController!.text;
                          }
                          return code.code == "US";
                        },
                      )]
                          .dialCode,
                    ),
                    onTap: () async {
                      await _showDialCodeModal(
                        context,
                        countryCodes: countryCodes ?? [],
                      );
                    },
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                ),
              ),
              maxLength: 15,
              maxLines: 1,
              readOnly: false,
              validator: validator,
              onTapOutside: (_) => focusNode?.unfocus(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDialCodeModal(
    BuildContext context, {
    required List<CountryCode> countryCodes,
  }) async {
    return await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Consumer(builder: (context, ref, _) {
          final isLightTheme = ref.watch(settingsThemeProvider) == ThemeData.light();
          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: isLightTheme ? Colors.white : ColorPallete.lightBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: isLightTheme ? Colors.white : ColorPallete.lightBackgroundColor,
                        foregroundColor: isLightTheme ? Colors.blue : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ),
                Flexible(
                  child: SafeArea(
                    top: false,
                    child: CupertinoPicker.builder(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        dialCodeController?.text = countryCodes[index].dialCode;
                      },
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              countryCodes[index].name,
                              style: TextStyle(
                                fontSize: 20,
                                color: isLightTheme ? Colors.black : Colors.white,
                              ),
                            ),
                            const Gap(16.0),
                            Text(
                              countryCodes[index].dialCode,
                              style: TextStyle(
                                fontSize: 20,
                                color: isLightTheme ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: countryCodes.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
