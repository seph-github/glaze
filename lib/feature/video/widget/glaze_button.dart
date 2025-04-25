import 'package:flutter/material.dart';

class GlazeButton extends StatelessWidget {
  const GlazeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(8)),
      child: const Text(
        'follow',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
