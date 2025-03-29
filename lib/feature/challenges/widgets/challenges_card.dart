import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/components/morphism_widget.dart';

class ChallengesCard extends StatelessWidget {
  const ChallengesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                Icons.privacy_tip_outlined,
                size: 24.0,
              ),
              Gap(8),
              Text('Skateboarding Tricks'),
              Spacer(),
              MorphismWidget.circle(
                size: 30.0,
              ),
            ],
          ),
          const Gap(12),
          const Text(
            'Join the Dance Challenge! Show off your moves in a live competition and battle it out for the top spot!',
          ),
          const Gap(12),
          const Row(
            children: <Widget>[
              Icon(
                Icons.timer,
                size: 18.0,
              ),
              Gap(8),
              Text('351d:13h:34m'),
              Spacer(),
              SizedBox(
                width: 100, // To constrain the width of the CircleStackPage
                height: 30, // Match circle height
                child: CircleStackPage(),
              ),
            ],
          ),
          const Gap(12),
          Container(
            height: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.yellow,
            ),
            padding: const EdgeInsets.all(16.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Beast Studio Buds'),
                Text('\$150'),
              ],
            ),
          ),
          const Gap(12),
          PrimaryButton(
            onPressed: () {},
            label: 'Join the Challenge',
            borderRadius: 16.0,
            backgroundColor: Colors.yellow,
          ),
        ],
      ),
    );
  }
}

class CircleStackPage extends StatelessWidget {
  const CircleStackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30, // Restrict height to avoid overflow
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: List.generate(4, (index) {
          return Positioned(
            left: index * 22.5, // 3/4 overlap of 30 is 22.5
            child: const CircleWidget(),
          );
        }),
      ),
    );
  }
}

class CircleWidget extends StatelessWidget {
  const CircleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
