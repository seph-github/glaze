import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/custom_tab_bar.dart';
import 'package:glaze/feature/moments/providers/moments_provider.dart';
import 'package:glaze/feature/moments/views/moments_upcoming_tabview.dart';
import 'package:glaze/feature/moments/views/moments_videos_tabview.dart';
import 'package:glaze/feature/moments/widgets/search_field.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/inputs/input_field.dart';
import '../../../components/modals/glaze_modals.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/fonts.gen.dart';
import '../../category/provider/category_provider.dart';
import '../../settings/providers/settings_theme_provider.dart';
import 'moments_live_tabview.dart';

class MomentsView extends HookConsumerWidget {
  const MomentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(momentsNotifierProvider);
    final categoryState = ref.watch(categoryNotifierProvider);
    final isLightTheme = ref.watch(settingsThemeProviderProvider) == ThemeData.light();
    final keywordsController = useTextEditingController();
    final categoryController = useTextEditingController();
    final resultLimit = useState<int>(10);
    final currentIndex = useState<int>(0);

    final videos = ref.watch(momentsNotifierProvider).videos;

    final List<String> tabs = [
      'Explore',
      'Live',
      'Upcoming'
    ];

    final tabController = useTabController(
      initialLength: tabs.length,
    );

    useEffect(
      () {
        Future.microtask(() async {
          await ref.read(momentsNotifierProvider.notifier).search(keywords: '');
          await ref.read(categoryNotifierProvider.notifier).fetchCategories();
          await ref.read(momentsNotifierProvider.notifier).getChallenges();
        });

        return;
      },
      [],
    );

    final List<Widget> tabViews = [
      MomentsVideosTabview(
        videos: videos,
      ),
      const MomentsLiveTabview(),
      const MomentsUpcomingTabview(),
    ];

    return LoadingLayout(
      isLoading: state.isLoading,
      appBar: AppBarWithBackButton(
        showBackButton: false,
        centerTitle: false,
        title: const Text('Moments'),
        titleTextStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFamily: FontFamily.hitAndRun,
            ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              if (currentIndex.value == 0)
                SearchField(
                  controller: keywordsController,
                  onTap: () async {
                    await ref.read(momentsNotifierProvider.notifier).search(
                          keywords: keywordsController.text.trim(),
                        );
                  },
                  onFilterTap: () async {
                    await _buildFilterModal(
                      context,
                      categoryController,
                      isLightTheme,
                      categoryState,
                      resultLimit,
                    );
                  },
                ),
              const Gap(10),
              Expanded(
                child: CustomTabBar(
                  length: tabs.length,
                  controller: tabController,
                  tabs: tabs,
                  tabViews: tabViews,
                  onTap: (value) {
                    currentIndex.value = value;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _buildFilterModal(
    BuildContext context,
    TextEditingController categoryController,
    bool isLightTheme,
    CategoryState categoryState,
    ValueNotifier<int> resultLimit, {
    String? keywords,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ColorPallete.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Gap(16.0),
                    const Text('Filter By:'),
                    InputField(
                      hintText: 'Category',
                      controller: categoryController,
                      lightModeColor: isLightTheme ? Colors.white : null,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please add a category';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () async {
                        await GlazeModal.showCategoryModalPopup(
                          context,
                          categoryState,
                          categoryController,
                        );
                      },
                    ),
                    const Gap(
                      16.0,
                    ),
                    const Gap(
                      8.0,
                    ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: <Widget>[
                    //     const Text('Limit:'),
                    //     const Gap(32.0),
                    //     IconButton(
                    //       onPressed: () {
                    //         if (resultLimit.value > 1) {
                    //           setState(
                    //             () {
                    //               resultLimit.value -= 1;
                    //             },
                    //           );
                    //         }
                    //       },
                    //       icon: const Icon(Icons.keyboard_arrow_left_rounded),
                    //     ),
                    //     Container(
                    //       alignment: Alignment.center,
                    //       height: 40.0,
                    //       width: 60.0,
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(8.0),
                    //         border: Border.all(
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //       child: Text(
                    //         resultLimit.value.toString(),
                    //       ),
                    //     ),
                    //     IconButton(
                    //       onPressed: () {
                    //         setState(() => resultLimit.value += 1);
                    //       },
                    //       icon: const Icon(
                    //         Icons.keyboard_arrow_right_rounded,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const Gap(16.0),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(
                                () {
                                  categoryController.clear();
                                  resultLimit.value = 10;
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPallete.borderColor,
                              foregroundColor: ColorPallete.blackPearl,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                        const Gap(16.0),
                        Consumer(builder: (context, ref, _) {
                          return Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await ref.read(momentsNotifierProvider.notifier).search(
                                      keywords: keywords,
                                      filterBy: categoryController.text.trim(),
                                      pageLimit: resultLimit.value,
                                    );

                                categoryController.clear();
                                resultLimit.value = 10;

                                if (context.mounted) {
                                  context.pop();
                                }
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorPallete.primaryColor,
                                foregroundColor: ColorPallete.whiteSmoke,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Apply'),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
