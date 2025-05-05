import 'package:flutter/material.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/feature/templates/loading_layout.dart';

class PersonalDetailsView extends StatelessWidget {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingLayout(
      appBar: AppBarWithBackButton(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      child: const SafeArea(
        child: Column(
          children: [
            Text('Personal Details')
          ],
        ),
      ),
    );
  }
}
