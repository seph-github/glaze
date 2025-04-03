import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glaze/components/morphism_widget.dart';
import 'package:glaze/core/result_handler/results.dart';
import 'package:glaze/feature/home/views/video_player_view.dart';

import '../../../data/models/cached_video/cached_video.dart';
import '../../../data/repository/video_repository/video_repository.dart';
import '../widgets/home_interactive_card.dart';

class HomeView extends HookWidget {
  HomeView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double height = size.height;
    final double width = size.width;
    final showMoreDonutOptions = useState<bool>(false);
    final showShareButton = useState<bool>(false);

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(cacheVideoNotifierProvider);

        return state.when(
          data: (data) {
            final CachedVideo? cachedVideos;

            if (data is Success<CachedVideo, Exception>) {
              cachedVideos = data.value;

              return Scaffold(
                body: RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(videoRepositoryProvider).fetchVideos(),
                  color: Colors.white12,
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    child: PageView.builder(
                      itemCount: cachedVideos.controllers?.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayerView(
                              controller: cachedVideos?.controllers?[index],
                            ),
                            Positioned(
                              bottom: -100,
                              left: 0,
                              right: 0,
                              child: HomeInteractiveCard(
                                onGlazeLongPress: () {
                                  showMoreDonutOptions.value = true;
                                },
                                onGlazeTap: () {},
                                onShareLongPress: () {
                                  showShareButton.value = true;
                                },
                                key: _scaffoldKey,
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
                                  showMoreDonutOptions.value = false;
                                  showShareButton.value = false;
                                },
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                              ),
                            if (showMoreDonutOptions.value)
                              Positioned(
                                right: 16.0,
                                bottom: 175.0,
                                child: MorphismWidget.rounded(
                                  width: width / 2.25,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      spacing: 10.0,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                            'assets/images/svg/Glaze Donuts Icon.svg'),
                                        SvgPicture.asset(
                                            'assets/images/svg/Glaze Donuts Icon.svg'),
                                        SvgPicture.asset(
                                            'assets/images/svg/Glaze Donuts Icon.svg'),
                                        SvgPicture.asset(
                                            'assets/images/svg/Plus icon.svg'),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                          ],
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
