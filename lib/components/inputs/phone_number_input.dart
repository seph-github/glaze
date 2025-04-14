import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:glaze/gen/assets.gen.dart';

import '../../feature/auth/models/country_code.dart';

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
  });

  final TextEditingController? dialCodeController;
  final TextEditingController? phoneController;

  @override
  Widget build(BuildContext context) {
    final countryCodes = useState<List<CountryCode>>([]);
    final phonePickerFocusNode = FocusNode();

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
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      focusNode: phonePickerFocusNode,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter your phone number',
        border: const OutlineInputBorder(),
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
              FocusScope.of(context).requestFocus(phonePickerFocusNode);

              return showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return Container(
                    color: Colors.white,
                    height: MediaQuery.sizeOf(context).height * 0.3,
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
                  );
                },
              );
            },
          ),
        ),
      ),
      maxLength: 15,
      maxLines: 1,
      readOnly: false,
    );
  }
}
