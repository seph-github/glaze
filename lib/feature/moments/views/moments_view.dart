import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/feature/moments/views/moments_live_challenges_tabview.dart';
import 'package:glaze/feature/moments/views/moments_videos_tabview.dart';
import 'package:glaze/feature/moments/widgets/search_field.dart';
import 'package:glaze/feature/templates/loading_layout.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/fonts.gen.dart';

class MomentsView extends ConsumerWidget {
  const MomentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> tabs = [
      'Videos',
      'Trendings',
      'Live Challenges',
      'Upcoming Challenges'
    ];

    final List<Widget> tabViews = [
      const MomentsVideosTabview(),
      const UnderConstruction(),
      const MomentsLiveChallengesTabview(),
      const UnderConstruction(),
    ];

    return LoadingLayout(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Moments'),
        titleTextStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFamily: FontFamily.hitAndRun,
            ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SearchField(),
            const Gap(10),
            Expanded(
              child: DefaultTabController(
                initialIndex: 0,
                length: tabs.length,
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: TabBar(
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.01),
                              Colors.white.withValues(alpha: 0.03),
                              Colors.white.withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                        textScaler: TextScaler.noScaling,
                        tabAlignment: TabAlignment.start,
                        tabs: tabs.map(
                          (tab) {
                            return Tab(
                              child: Text(
                                tab,
                                style: Theme.of(context).textTheme.labelLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: tabViews.map(
                          (tab) {
                            return tab;
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnderConstruction extends StatelessWidget {
  const UnderConstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Coming soon...'),
          SvgPicture.asset(Assets.images.svg.glazeDonutsIcon.path),
        ],
      ),
    );
  }
}
