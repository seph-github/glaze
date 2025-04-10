import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/morphism_widget.dart';
import 'package:glaze/core/result_handler/results.dart';
import 'package:glaze/feature/home/views/video_player_view.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/gen/assets.gen.dart';
import 'package:go_router/go_router.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../data/models/cached_video/cached_video.dart';
import '../../../data/repository/video_repository/video_repository.dart';
import '../widgets/home_interactive_card.dart';
import '../widgets/share_option_button.dart';

class HomeView extends HookWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = usePageController();
    final size = MediaQuery.sizeOf(context);
    final double height = size.height;
    final double width = size.width;
    final showMoreDonutOptions = useState<bool>(false);
    final showShareButton = useState<bool>(false);
    final focusNode = useFocusNode();
    final currentIndex = useState<int>(0);

    void toggleDonutOptions(bool value) {
      showMoreDonutOptions.value = value;
    }

    void toggleShareButton(bool value) {
      showShareButton.value = value;
    }

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   focusNode.requestFocus();
    // });

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(cacheVideoNotifierProvider);

        return state.when(
          data: (data) {
            final CachedVideo? cachedVideos;

            if (data is Success<CachedVideo, Exception>) {
              cachedVideos = data.value;

              return LoadingLayout(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(videoRepositoryProvider).fetchVideos(),
                  color: Colors.white12,
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    child: PageView.builder(
                      allowImplicitScrolling: true,
                      controller: controller,
                      onPageChanged: (index) {
                        currentIndex.value = index;

                        cachedVideos?.controllers?[0].play();
                        for (int i = 0;
                            i < (cachedVideos?.controllers?.length ?? 0);
                            i++) {
                          if (i != index) {
                            cachedVideos?.controllers?[i].pause();
                          } else {
                            cachedVideos?.controllers?[i].play();
                          }
                        }
                      },
                      itemCount: cachedVideos.controllers?.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Focus(
                          focusNode: focusNode,
                          autofocus: focusNode.hasFocus,
                          canRequestFocus: true,
                          onFocusChange: (value) {
                            if (value) {
                              cachedVideos?.controllers?[currentIndex.value]
                                  .play();
                            } else {
                              cachedVideos?.controllers?[currentIndex.value]
                                  .pause();
                            }
                          },
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              VideoPlayerView(
                                controller: cachedVideos?.controllers?[index],
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: HomeInteractiveCard(
                                  key: PageStorageKey(
                                      'HomeInteractiveCard_$index'),
                                  onGlazeLongPress: () =>
                                      toggleDonutOptions(true),
                                  onShareTap: () async =>
                                      await showShareOptions(context),
                                  width: width,
                                  height: height,
                                  cachedVideos: cachedVideos,
                                  index: index,
                                ),
                              ),
                              if (showMoreDonutOptions.value ||
                                  showShareButton.value)
                                GestureDetector(
                                  onTap: () {
                                    toggleDonutOptions(false);
                                    toggleShareButton(false);
                                  },
                                  child: Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    color: Colors.black.withValues(alpha: 0.7),
                                  ),
                                ),
                              if (showMoreDonutOptions.value)
                                buildDonutOptions(context, width: width),
                              // if (showShareButton.value)
                              //   buildShareOptions(context, width: width),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            } else {
              return const _ErrorView(
                error: 'Something went wrong',
              );
            }
          },
          error: (error, stackTrace) => _ErrorView(
            error: error.toString(),
          ),
          loading: () => const _LoadingView(),
        );
      },
    );
  }

  Widget buildDonutOptions(BuildContext ctx, {double? width}) {
    return Positioned(
      right: 16.0,
      bottom: 140.0,
      child: MorphismWidget.rounded(
        width: width! / 2.25,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/svg/Glaze Donuts Icon.svg'),
              SvgPicture.asset('assets/images/svg/Glaze Donuts Icon.svg'),
              SvgPicture.asset('assets/images/svg/Glaze Donuts Icon.svg'),
              SvgPicture.asset('assets/images/svg/Plus icon.svg'),
            ],
          ),
        ),
      ),
    );
  }

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
                      child:
                          SvgPicture.asset(Assets.images.svg.copyLinkIcon.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(
                          Assets.images.svg.emailSocialMedia.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(
                          Assets.images.svg.twitterSocialMedia.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(
                          Assets.images.svg.whatsappSocialMedia.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(
                          Assets.images.svg.snapchatSocialMedia.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(
                          Assets.images.svg.tikTokSocialMedia.path),
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
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.amber,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(error),
      ),
    );
  }
}
