import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
// import 'package:glaze/features/challenges/providers/challenge_provider.dart';
import 'package:glaze/features/moments/widgets/upload_moments_card.dart';
import 'package:glaze/features/templates/loading_layout.dart';

import '../providers/challenge_provider.dart';

class ChallengeSubmitEntry extends ConsumerWidget {
  const ChallengeSubmitEntry({
    super.key,
    required this.challengeId,
  });

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadingLayout(
      appBar: const AppBarWithBackButton(),
      child: SafeArea(
        child: UploadMomentsCard(
          showBackground: false,
          onPressed: () async => await ref.read(challengeNotifierProvider.notifier).submitChallengeEntry(challengeId: challengeId),
        ),
      ),
    );
  }
}
