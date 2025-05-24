import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/features/camera/provider/upload_moments_form_provider/upload_moments_form_provider.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:glaze/core/navigation/router.dart';

class CameraVideoPreviewView extends HookConsumerWidget {
  const CameraVideoPreviewView({super.key, required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMemoized(() => VideoPlayerController.file(File(filePath)));
    final initialized = useState(false);

    useEffect(() {
      Future<void> init() async {
        await controller.initialize();
        controller.setLooping(true);
        await controller.play();
        initialized.value = true;
      }

      init();

      return () {
        controller.dispose();
      };
    }, [
      controller
    ]);

    void clearForm() {
      return ref.read(uploadMomentFormProvider.notifier).clearForm();
    }

    return LoadingLayout(
      appBar: AppBarWithBackButton(
        onBackButtonPressed: () {
          clearForm();
          context.pop();
        },
      ),
      isLoading: !initialized.value,
      child: initialized.value
          ? Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenRatio = constraints.maxHeight / constraints.maxWidth;
                      final previewRatio = controller.value.size.width / controller.value.size.height;

                      return OverflowBox(
                        maxHeight: screenRatio > previewRatio ? constraints.maxHeight : constraints.maxWidth / previewRatio,
                        maxWidth: screenRatio > previewRatio ? constraints.maxHeight * previewRatio : constraints.maxWidth,
                        child: VideoPlayer(controller),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  height: 100.0,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextButton(
                        onPressed: () async {
                          await controller.dispose();
                          clearForm();
                          if (context.mounted) {
                            context.pop();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        child: const Text('Take Again'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await controller.pause();
                          ref.read(uploadMomentFormProvider.notifier).setFile(File(filePath));
                          ref.read(uploadMomentFormProvider.notifier).syncControllersToState();

                          if (context.mounted) {
                            context.push(
                              const CameraContentFormRoute().location,
                              extra: filePath,
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
