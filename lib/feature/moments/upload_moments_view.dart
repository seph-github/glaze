import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UploadMomentsView extends StatelessWidget {
  const UploadMomentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        showModalBottomSheet(
          barrierColor: Colors.amber,
          context: context,
          backgroundColor: Colors.white,
          elevation: 2,
          builder: (context) {
            return SizedBox(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height * 0.8,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => router.backButtonDispatcher,
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    return const Scaffold();
  }
}
