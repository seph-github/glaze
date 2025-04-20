import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/core/styles/color_pallete.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/fonts.gen.dart';
import '../../templates/loading_layout.dart';

class ShopView extends StatelessWidget {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingLayout(
      appBar: AppBarWithBackButton(
        showBackButton: false,
        centerTitle: false,
        title: const Text('Shop'),
        titleTextStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFamily: FontFamily.hitAndRun,
            ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.0),
                    color: Colors.amberAccent.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.amber,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Featured',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            Assets.images.svg.timerIcon.path,
                            height: 24.0,
                          ),
                          const Gap(4),
                          Text(
                            '23:59:59 Ends in',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Gap(5),
                      Row(
                        children: <Widget>[
                          SvgPicture.asset(Assets.images.svg.glazeDonutsIcon.path),
                          const Gap(10),
                          Text(
                            'Golden Donuts',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '\$2.99',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.amber),
                          ),
                        ],
                      ),
                      const Gap(5),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.75,
                            child: Text(
                              'Unlock exclusive perks, premium features & special rewards!',
                              maxLines: 3,
                              overflow: TextOverflow.fade,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: ColorPallete.hintTextColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(5),
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SvgPicture.asset(
                                Assets.images.svg.starIcon.path,
                                height: 18.0,
                                colorFilter: const ColorFilter.mode(
                                  Colors.amber,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const Gap(10),
                              Text(
                                'Unlock special perks and bonuses.',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.amber),
                              ),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: <Widget>[
                              SvgPicture.asset(
                                Assets.images.svg.starIcon.path,
                                height: 18.0,
                                colorFilter: const ColorFilter.mode(
                                  Colors.amber,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const Gap(10),
                              Text(
                                'Access advanced tools and content.',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.amber),
                              ),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: <Widget>[
                              SvgPicture.asset(
                                Assets.images.svg.starIcon.path,
                                height: 18.0,
                                colorFilter: const ColorFilter.mode(
                                  Colors.amber,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const Gap(10),
                              Text(
                                'Stand out with a Golden Donut badge.',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.amber),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Gap(10),
                      PrimaryButton(
                        label: 'Buy Premium',
                        foregroundColor: ColorPallete.backgroundColor,
                        backgroundColor: Colors.amber,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DarkCircleWidget extends StatelessWidget {
  final double size;
  final double opacity;

  const DarkCircleWidget({super.key, this.size = 56.0, this.opacity = 0.8});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter, // Align circles to bottom-center
      children: [
        // Outer Solid White Circle with Increased Glow
        Container(
          width: size + 16, // Increase size to emphasize the outer circle
          height: size + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.5), // Stronger white glow
          ),
        ),
        // Dark Circle with Gradient and Blur
        Container(
          width: 1,
          height: 1,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFF2C2C2C), // Dark center
                Color(0xFF1A1A1A), // Dark edges
              ],
              center: Alignment(0.0, 0.0),
              radius: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8), // Inner shadow with opacity
                blurRadius: 70, // Stronger blur effect
                spreadRadius: 70,
                offset: const Offset(2, 2), // Slight shadow offset
              ),
            ],
          ),
        ),
      ],
    );
  }
}
