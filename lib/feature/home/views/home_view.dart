import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/morphism_widget.dart';
import 'package:glaze/core/result_handler/results.dart';
import 'package:glaze/core/routing/router.dart';
import 'package:glaze/feature/home/views/video_player_view.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/cached_video/cached_video.dart';
import '../../../data/repository/video_repository/video_repository.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final size = MediaQuery.sizeOf(context);
    final double height = size.height;
    final double width = size.width;

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
                              child: Container(
                                width: width,
                                height: height * 0.3,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.6),
                                      offset: const Offset(0, 0),
                                      blurRadius: 100,
                                      spreadRadius: 50,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        MorphismWidget.rounded(
                                          onTap: () {
                                            router.push(const ChallengesRoute()
                                                .location);
                                          },
                                          width: width / 2,
                                          height: 40,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              SvgPicture.asset(
                                                  'assets/images/svg/Trophy Icon.svg'),
                                              const Gap(10),
                                              const Text('Best Content'),
                                            ],
                                          ),
                                        ),
                                        const Gap(10),
                                        Text(
                                          cachedVideos?.model?[index].title ??
                                              '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final userId = cachedVideos
                                                ?.model?[index].userId;

                                            router.push(ViewUserProfileRoute(
                                                    id: userId ?? '')
                                                .location);
                                          },
                                          child: Text(
                                            'By @${cachedVideos?.model?[index].username}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          '# Trending',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        MorphismWidget.circle(
                                          onTap: () {},
                                          size: 45.0,
                                          child: SvgPicture.asset(
                                              'assets/images/svg/Glaze Donuts Icon.svg'),
                                        ),
                                        const Gap(10),
                                        MorphismWidget.circle(
                                          size: 45.0,
                                          child: SvgPicture.asset(
                                              'assets/images/svg/share_icon.svg'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
