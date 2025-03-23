import 'package:flutter/material.dart';

class AuthSSOWidget extends StatelessWidget {
  AuthSSOWidget({
    super.key,
  });

  final List<Color> colors = [
    Colors.white10,
    Colors.white12,
    Colors.white24,
    Colors.white30,
    Colors.white38,
    Colors.white54,
    Colors.white60,
    Colors.white70,
  ];

  final List<double> stops = [
    0.3,
    0.4,
    0.45,
    0.5,
    0.6,
    0.7,
    0.75,
    0.9,
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: size.width * 0.25,
          height: 2.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: stops,
            ),
          ),
        ),
        Text(
          'OR CONTINUE WITH',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 12.0,
              ),
        ),
        Container(
          width: size.width * 0.25,
          height: 2.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors.reversed.toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: stops,
            ),
          ),
        ),
      ],
    );
  }
}
