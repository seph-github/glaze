import 'dart:io';

import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../core/styles/color_pallete.dart';

class RecruiterIdentificationCard extends ConsumerWidget {
  const RecruiterIdentificationCard({
    super.key,
    this.recruiterIdentificationImageUrl,
    this.imageFile,
    this.onTap,
    this.onClear,
  });

  final String? recruiterIdentificationImageUrl;
  final File? imageFile;
  final void Function()? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verify your Identity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const Gap(16),
            GestureDetector(
              onTap: () {
                onTap?.call();
              },
              child: DottedBorder(
                color: ColorPallete.whiteSmoke,
                strokeWidth: 1.5,
                dashPattern: const [
                  9,
                  3
                ],
                borderType: BorderType.RRect,
                radius: const Radius.circular(24.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: ColorPallete.inputFilledColor,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // if (recruiterIdentificationImageUrl != null)
                      //   ClipRRect(
                      //     borderRadius: BorderRadius.circular(8.0),
                      //     child: AspectRatio(
                      //       aspectRatio: 16 / 9,
                      //       child: CachedNetworkImage(
                      //           imageUrl: recruiterIdentificationImageUrl!),
                      //     ),
                      //   ),
                      imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.file(
                                  imageFile!,
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/svg/Upload Icon.svg',
                                  height: 24.0,
                                ),
                                const Gap(10),
                                Text(
                                  'Upload Identification',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                      const Gap(10),
                      Text(
                        'Upload your best moments with a\nunique title for identification.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ColorPallete.hintTextColor,
                            ),
                      ),
                      const Gap(10),
                      if (imageFile != null)
                        ElevatedButton(
                          onPressed: () {
                            onClear?.call();
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const Gap(16),
        Text(
          '* Please upload a government-issued ID or business card',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPallete.hintTextColor,
              ),
        ),
        const Gap(16),
      ],
    );
  }
}
