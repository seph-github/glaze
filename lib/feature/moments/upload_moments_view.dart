import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/upload_moments_card.dart';

class UploadMomentsView extends StatelessWidget {
  const UploadMomentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    router.state.matchedLocation.contains('/upload-moments');

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (!context.canPop()) {
          await showModalBottomSheet(
            context: context,
            elevation: 2,
            showDragHandle: true,
            isScrollControlled: true,
            isDismissible: false,
            builder: (context) {
              return const UploadMomentsCard();
              // return SizedBox(
              //   width: double.infinity,
              //   height: MediaQuery.sizeOf(context).height * 0.8,
              //   child: Column(
              //     children: [
              //       GestureDetector(
              //         onTap: () => router.backButtonDispatcher,
              //         child: const Text('Close'),
              //       ),
              //     ],
              //   ),
              // );
            },
          );
        }
      },
    );
    return const Scaffold(
        // body: UploadMomentsCard(),
        );
  }
}
