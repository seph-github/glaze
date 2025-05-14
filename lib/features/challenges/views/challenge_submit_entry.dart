import 'package:flutter/widgets.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/features/moments/widgets/upload_moments_card.dart';
import 'package:glaze/features/templates/loading_layout.dart';

class ChallengeSubmitEntry extends StatelessWidget {
  const ChallengeSubmitEntry({
    super.key,
    required this.challengeId,
  });

  final String challengeId;

  @override
  Widget build(BuildContext context) {
    return const LoadingLayout(
      appBar: AppBarWithBackButton(),
      child: SafeArea(
        child: UploadMomentsCard(
          showBackground: false,
        ),
      ),
    );
  }
}
