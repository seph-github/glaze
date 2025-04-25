import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/feature/splash/providers/splash_provider.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              Container(
                height: size.height * 0.75,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/png/glaze_on_splash.png',
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
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Image.asset(
                    'assets/images/png/glaze_icon_logo.png',
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
                          await ref.read(splashProvider).setSplashComplete(true).then(
                                (_) => router.pushReplacement(const AuthRoute().location),
                              );
                        },
                      );
                    },
                  ),
                  const Gap(50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
