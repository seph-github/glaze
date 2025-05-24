// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/features/camera/provider/upload_moments_form_provider/upload_moments_form_provider.dart';
import 'package:glaze/features/dashboard/providers/dashboard_tab_controller_provider.dart';
import 'package:glaze/gen/assets.gen.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../../components/dialogs/dialogs.dart';
import '../../../utils/check_video_duration.dart';
import '../provider/content_picker_provider/content_picker_provider.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  late AudioPlayer _audioPlayer;
  XFile? videoFile;
  bool isRecording = false;
  bool isFlashOn = false;
  bool isRearCamera = true;
  int countdown = 15;
  Timer? _recordingTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setAsset(Assets.audios.on);
    _audioPlayer.setVolume(10);
    _initCamerasAndStart(CameraLensDirection.back);
  }

  Future<void> _initCamerasAndStart(CameraLensDirection lens) async {
    try {
      _cameras = await availableCameras();

      await _initializeCamera(lens);
    } catch (e) {
      _showCameraException(CameraException('init_error', e.toString()));
    }
  }

  Future<void> _initializeCamera(CameraLensDirection lens) async {
    try {
      // Dispose previous controller if it exists
      if (_controller.value.isInitialized) {
        await _controller.dispose();
      }
    } catch (_) {}

    final selectedCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == lens && (lens == CameraLensDirection.front || camera.name.contains('0')),
      orElse: () => _cameras.first,
    );

    final newController = CameraController(
      selectedCamera,
      ResolutionPreset.veryHigh,
      enableAudio: true,
      fps: 60,
    );

    _initializeControllerFuture = newController.initialize();
    await _initializeControllerFuture;
    await newController.lockCaptureOrientation(DeviceOrientation.portraitUp);

    if (!mounted) return;

    setState(() {
      _controller = newController;
      isRearCamera = lens == CameraLensDirection.back;
      isFlashOn = false;
    });
  }

  Future<void> onFlashToggle() async {
    if (!_controller.value.isInitialized) return;

    try {
      // Check if the current camera supports flash
      final hasFlash = _controller.description.lensDirection == CameraLensDirection.back;

      if (!hasFlash) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Flash not supported on this camera')),
          );
        }
        return;
      }

      // iOS fix: delay slightly to ensure torch toggle doesn't race with init
      await Future.delayed(const Duration(milliseconds: 100));

      final newMode = isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller.setFlashMode(newMode);
      if (mounted) {
        setState(() => isFlashOn = !isFlashOn);
      }
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle flash: ${e.description}')),
        );
      }
      _showCameraException(e);
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Flash error: ${e.message}')),
        );
      }
    }
  }

  Future<void> _startVideoRecording() async {
    if (!_controller.value.isInitialized || _controller.value.isRecordingVideo) {
      return;
    }

    try {
      _audioPlayer.play().whenComplete(() async {
        await HapticFeedback.lightImpact();
        await _controller.startVideoRecording();
      });

      setState(() {
        isRecording = true;
        countdown = 15;
      });

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown <= 1) {
          _onStopButtonPressed();
          return;
        }
        setState(() {
          countdown--;
        });
      });

      _recordingTimer = Timer(const Duration(seconds: 15), () {
        _onStopButtonPressed();
      });
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController cameraController = _controller;

    if (!cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _onVideoRecordButtonPressed() {
    _startVideoRecording().then((_) {
      if (mounted) {
        isRecording = true;
        setState(() {});
      }
    });
  }

  void _onStopButtonPressed() async {
    try {
      final XFile file = await _controller.stopVideoRecording();
      _recordingTimer?.cancel();
      _countdownTimer?.cancel();

      setState(() {
        isRecording = false;
        countdown = 15;
      });

      await CameraVideoPreviewRoute(file.path).push<void>(context);
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  @override
  void dispose() {
    _controller.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Consumer(builder: (context, ref, _) {
        return Scaffold(
          appBar: AppBarWithBackButton(
            onBackButtonPressed: () {
              ref.read(uploadMomentFormProvider.notifier).clearForm();
              ref.read(dashboardTabControllerProvider.notifier).goBackToLastTab();
              context.pop();
            },
            backgroundColor: Colors.black.withValues(alpha: 0.75),
            actions: [
              Text(
                '15s',
                style: TextTheme.of(context).titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const Gap(12.0),
              if (isRearCamera)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async => await onFlashToggle(),
                      child: Icon(
                        isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    const Gap(12.0),
                  ],
                ),
            ],
          ),
          body: FutureBuilder(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _CameraPreviewWidget(
                  countdown: countdown,
                  controller: _controller,
                  onRecordingPressed: _controller.value.isInitialized && !_controller.value.isRecordingVideo ? _onVideoRecordButtonPressed : _onStopButtonPressed,
                  onRotateCameraPressed: _controller.value.isInitialized && !_controller.value.isRecordingVideo
                      ? () async {
                          final newLens = isRearCamera ? CameraLensDirection.front : CameraLensDirection.back;
                          await _initializeCamera(newLens);
                        }
                      : null,
                  isRecording: isRecording,
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Camera error: ${snapshot.error}'),
                );
              } else {
                return const Center(
                  child: SizedBox.shrink(),
                );
              }
            },
          ),
        );
      }),
    );
  }
}

class _CameraPreviewWidget extends ConsumerWidget {
  const _CameraPreviewWidget({
    required CameraController controller,
    VoidCallback? onRecordingPressed,
    this.isRecording = false,
    this.countdown = 15,
    VoidCallback? onRotateCameraPressed,
  })  : _controller = controller,
        _onRecordingPressed = onRecordingPressed,
        _onRotateCameraPressed = onRotateCameraPressed;

  final CameraController _controller;
  final VoidCallback? _onRecordingPressed;
  final VoidCallback? _onRotateCameraPressed;
  final bool isRecording;
  final int countdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size(
      :width,
      :height
    ) = MediaQuery.sizeOf(context);

    ref.listen(
      contentPickerNotifierProvider,
      (prev, next) async {
        if (next.video != null && prev?.video != next.video) {
          final duration = await getVideoDuration(File(next.video?.path ?? ''));

          if (duration.inSeconds > 15 && context.mounted) {
            await Dialogs.createContentDialog(
              context,
              title: 'Error',
              content: 'Your video exceeds the maximum allowed duration. Please subscribe or purchase a plan to upload longer videos.',
              onPressed: () => context.pop(),
            );
            throw Exception('Video too long! Max 15 seconds allowed.');
          } else {
            await CameraVideoPreviewRoute(next.video!.path).push<void>(context);
          }
        }
      },
    );

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.previewSize!.height / _controller.value.previewSize!.width,
            child: CameraPreview(_controller),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              width: width,
              color: Colors.black.withValues(alpha: 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await ref.read(contentPickerNotifierProvider.notifier).pickVideos();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SvgPicture.asset(
                        Assets.images.svg.gallery.path,
                        height: 36.0,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      _onRecordingPressed?.call();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 8.0,
                      ),
                      height: 65.0,
                      width: 65.0,
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRecording ? Colors.red : Colors.white,
                        ),
                        child: isRecording
                            ? Text(
                                '$countdown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _onRotateCameraPressed?.call();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SvgPicture.asset(
                        Assets.images.svg.cameraRotate.path,
                        height: 36.0,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
