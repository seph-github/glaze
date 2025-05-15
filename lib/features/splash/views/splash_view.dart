import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/features/splash/providers/splash_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/assets.gen.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height * 0.75,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  Assets.images.png.glazeOnSplash.path,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.05,
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0),
                    blurRadius: 200,
                    spreadRadius: 200,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.1,
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0),
                    blurRadius: 200,
                    spreadRadius: 200,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Image.asset(
                  Assets.images.png.glazeIconLogo.path,
                  width: MediaQuery.of(context).size.width / 2,
                ),
                const Gap(15),
                const Text(
                  'Create, share, and shine! Capture epic\nmoments, join challenges, and go viral!🚀',
                ),
                const Gap(20),
                Consumer(
                  builder: (context, ref, _) {
                    return PrimaryButton(
                      label: 'Get Started',
                      onPressed: () async {
                        final router = GoRouter.of(context);
                        await ref
                            .read(splashProvider)
                            .setSplashComplete(true)
                            .then(
                              (_) => router
                                  .pushReplacement(const AuthRoute().location),
                            );
                      },
                    );
                  },
                ),
                const Gap(50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
