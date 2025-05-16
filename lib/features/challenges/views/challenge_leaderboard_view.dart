import 'package:flutter/material.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/features/challenges/models/challenge_entry/challenge_entry.dart';
import 'package:glaze/features/challenges/widgets/leaderboard_tile.dart';
import 'package:glaze/features/templates/loading_layout.dart';

class ChallengeLeaderBoardView extends StatelessWidget {
  const ChallengeLeaderBoardView({
    super.key,
    this.entries,
  });

  final List<ChallengeEntry>? entries;

  @override
  Widget build(BuildContext context) {
    return LoadingLayout(
      appBar: AppBarWithBackButton(
        title: Text(
          'Leaders',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: entries?.length ?? 0,
          itemBuilder: (context, index) {
            final rank = index + 1;
            return LeaderboardTile(
              useColor: Colors.amber,
              username: '@${entries?[index].profile.username}',
              rank: rank.toString(),
            );
          },
        ),
      ),
    );
  }
}
