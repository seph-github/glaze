import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/data/repository/file_picker/file_picker_provider.dart';

import '../../../core/styles/color_pallete.dart';

class RecruiterIdentificationCard extends ConsumerWidget {
  const RecruiterIdentificationCard({
    super.key,
    this.recruiterIdentificationImageUrl,
  });

  final String? recruiterIdentificationImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    File? pickedFile = ref.watch(filePickerNotifierProvider).value;

    return GestureDetector(
      onTap: () async {
        pickedFile =
            await ref.read(filePickerNotifierProvider.notifier).pickFile(
                  type: FileType.image,
                );
      },
      child: DottedBorder(
        color: ColorPallete.whiteSmoke,
        strokeWidth: 1.5,
        dashPattern: const [9, 3],
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
              pickedFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.file(
                          pickedFile,
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
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
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
              if (pickedFile != null || recruiterIdentificationImageUrl != null)
                ElevatedButton(
                  onPressed: () async =>
                      ref.refresh(filePickerNotifierProvider),
                  child: const Text('Clear'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
