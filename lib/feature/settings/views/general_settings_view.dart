import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';

class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return LoadingLayout(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            Assets.images.svg.backArrowIcon.path,
          ),
          style: IconButton.styleFrom(
            backgroundColor: ColorPallete.inputFilledColor,
            shape: const CircleBorder(),
          ),
          onPressed: () {
            router.pop();
          },
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('General Settings'),
                const Gap(10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) => {},
                          inactiveTrackColor: Colors.grey,
                          activeColor: Colors.grey,
                        ),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) => {},
                          inactiveTrackColor: Colors.grey,
                          activeColor: Colors.grey,
                        ),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) => {},
                          inactiveTrackColor: Colors.grey,
                          activeColor: Colors.grey,
                        ),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) => {},
                          inactiveTrackColor: Colors.grey,
                          activeColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
