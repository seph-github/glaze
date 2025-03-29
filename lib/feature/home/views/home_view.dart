import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/morphism_widget.dart';
import 'package:glaze/core/routing/router.dart';
import 'package:glaze/feature/home/views/video_player_view.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repository/video_repository/video_repository.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final size = MediaQuery.sizeOf(context);
    final double height = size.height;
    final double width = size.width;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24.0),
        bottomRight: Radius.circular(24.0),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(cacheVideoNotifierProvider);

          return state.when(
            data: (data) {
              return Scaffold(
                body: RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(videoRepositoryProvider).fetchVideos(),
                  color: Colors.white12,
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    child: PageView.builder(
                      itemCount: data.controllers?.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayerView(
                              controller: data.controllers?[index],
                            ),
                            ClipRRect(
                              child: Container(
                                width: width,
                                height: height * 0.22,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(-1, -1),
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      spreadRadius: 100,
                                      blurRadius: 100,
                                      blurStyle: BlurStyle.normal,
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
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.thumb_up_alt_outlined,
                                                size: 24,
                                              ),
                                              Gap(10),
                                              Text('Best Content'),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          data.model?[index].caption ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final userId =
                                                data.model?[index].userId;

                                            router.push(ViewUserProfileRoute(
                                                    id: userId ?? '')
                                                .location);
                                          },
                                          child: Text(
                                            'By @${data.model?[index].username}',
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
                                          size: 50,
                                          child: const Icon(
                                            Icons.favorite,
                                            size: 24,
                                          ),
                                        ),
                                        const Gap(10),
                                        const MorphismWidget.circle(
                                          size: 50,
                                          child: Icon(Icons.share, size: 24),
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
            },
            error: (error, stackTrace) => _ErrorView(
              error: error.toString(),
            ),
            loading: () => const _LoadingView(),
          );
        },
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
