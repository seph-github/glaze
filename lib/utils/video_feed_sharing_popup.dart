import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../components/morphism_widget.dart';
import '../core/styles/color_pallete.dart';
import '../feature/home/widgets/share_option_button.dart';
import '../gen/assets.gen.dart';

Future<void> showShareOptions(
  BuildContext ctx,
) async {
  return await showDialog(
    context: ctx,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 430.0,
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0),
            image: DecorationImage(
              image: AssetImage(
                Assets.images.png.glazeCardBackgroundR32.path,
              ),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: MorphismWidget.circle(
                  onTap: () {
                    ctx.pop();
                  },
                  size: 28.0,
                  child: SvgPicture.asset(
                    Assets.images.svg.closeIcon.path,
                  ),
                ),
              ),
              MorphismWidget.circle(
                size: 64.0,
                child: SvgPicture.asset(Assets.images.svg.shareIcon.path),
              ),
              Text(
                'Upload Your Moment',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                'Share your talent with the community!',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: ColorPallete.hintTextColor,
                    ),
              ),
              const Gap(20),
              Divider(
                color: ColorPallete.whiteSmoke.withValues(alpha: 0.1),
                thickness: 0.5,
              ),
              const Gap(10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Share with others',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: ColorPallete.hintTextColor,
                      ),
                ),
              ),
              const Spacer(),
              Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 30.0,
                spacing: 60.0,
                children: [
                  ShareOptionButton(
                    child: SvgPicture.asset(Assets.images.svg.copyLinkIcon.path),
                  ),
                  ShareOptionButton(
                    child: SvgPicture.asset(Assets.images.svg.emailSocialMedia.path),
                  ),
                  ShareOptionButton(
                    child: SvgPicture.asset(Assets.images.svg.twitterSocialMedia.path),
                  ),
                  ShareOptionButton(
                    child: SvgPicture.asset(Assets.images.svg.whatsappSocialMedia.path),
                  ),
                  ShareOptionButton(
                    child: SvgPicture.asset(Assets.images.svg.snapchatSocialMedia.path),
                  ),
                  ShareOptionButton(
                    child: SvgPicture.asset(Assets.images.svg.tikTokSocialMedia.path),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    ),
  );
}
