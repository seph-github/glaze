import 'package:flutter/material.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/features/challenges/widgets/leaderboard_tile.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeLeaderBoardView extends StatelessWidget {
  const ChallengeLeaderBoardView({super.key});

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
      child: FutureBuilder(
        future: Future.microtask(() async {
          print('Fetching leaderboard data...');
          final supabase = Supabase.instance.client;
          return await supabase.from('profiles').select();
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: data?.length ?? 0,
              itemBuilder: (context, index) {
                final rank = index + 1;
                return LeaderboardTile(
                  useColor: Colors.amber,
                  username: data?[index]['username'],
                  rank: rank.toString(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
