import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/gen/assets.gen.dart';

import '../../core/styles/color_pallete.dart';
import '../../feature/auth/models/country_code.dart';
import '../../feature/settings/providers/settings_theme_provider.dart';

class JsonParser {
  static Future<List<CountryCode>> parseCountryCodes() async {
    final String response = await rootBundle.loadString(Assets.others.countryCode);
    final List<dynamic> data = json.decode(response);
    return data.map((json) => CountryCode.fromJson(json)).toList();
  }
}

class PhoneNumberInput extends HookWidget {
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
  Widget build(BuildContext context) {
    final countryCodes = useState<List<CountryCode>>([]);
    const double defaultBorderRadius = 16;

    useEffect(
      () {
        Future.microtask(
          () async {
            final codes = await JsonParser.parseCountryCodes();
            countryCodes.value = codes;
            dialCodeController?.text = codes[codes.indexWhere(
              (code) {
                return code.code == "US";
              },
            )]
                .dialCode;
          },
        );

        return;
      },
      [],
    );
    return Consumer(builder: (context, ref, _) {
      final isLightTheme = ref.watch(settingsThemeProviderProvider) == ThemeData.light();
      return Column(
        children: [
          const Gap(6),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            focusNode: focusNode,
            decoration: InputDecoration(
              // labelText: 'Phone Number',
              isDense: true,
              fillColor: ColorPallete.inputFilledColor,
              filled: filled,
              hintText: 'Phone Number',
              border: const OutlineInputBorder(),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
                borderSide: const BorderSide(
                  color: ColorPallete.whiteSmoke,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
                borderSide: BorderSide(
                  color: isLightTheme ? lightModeColor ?? ColorPallete.backgroundColor : ColorPallete.whiteSmoke,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
                borderSide: BorderSide(
                  width: 1 / 4,
                  color: isLightTheme ? lightModeColor ?? ColorPallete.backgroundColor : ColorPallete.persianFable,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
                borderSide: const BorderSide(
                  width: 1,
                  color: ColorPallete.parlourRed,
                ),
              ),
              prefixIcon: SizedBox(
                width: 60,
                child: TextFormField(
                  controller: dialCodeController,
                  readOnly: true,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    hintText: countryCodes
                        .value[countryCodes.value.indexWhere(
                      (code) {
                        return code.code == "US";
                      },
                    )]
                        .dialCode,
                    border: InputBorder.none,
                  ),
                  onTap: () async {
                    await showDialCodeModal(
                      context,
                      countryCodes: countryCodes,
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
    });
  }

  Future<void> showDialCodeModal(BuildContext context, {required ValueNotifier<List<CountryCode>> countryCodes}) async {
    return await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker.builder(
                  itemExtent: 50,
                  onSelectedItemChanged: (index) {
                    dialCodeController?.text = countryCodes.value[index].dialCode;
                  },
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          countryCodes.value[index].name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        const Gap(16.0),
                        Text(
                          countryCodes.value[index].dialCode,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: countryCodes.value.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
