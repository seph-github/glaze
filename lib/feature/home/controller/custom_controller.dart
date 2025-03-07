// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_cached_video_player_plus/flutter_cached_video_player_plus.dart';

// class CustomControls extends StatefulWidget {
//   final CachedVideoPlayerController videoPlayerController;

//   const CustomControls({super.key, required this.videoPlayerController});

//   @override
//   State<CustomControls> createState() => _CustomControlsState();
// }

// class _CustomControlsState extends State<CustomControls> {
//   bool _showIcon = false;
//   Timer? _hideTimer;

//   void _startHideTimer() {
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(seconds: 1), () {
//       setState(() {
//         _showIcon = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _hideTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _showIcon = true;
//           if (widget.videoPlayerController.value.isPlaying) {
//             widget.videoPlayerController.pause();
//           } else {
//             widget.videoPlayerController.play();
//           }
//           _startHideTimer();
//         });
//       },
//       child: Container(
//         color: Colors.transparent,
//         child: Center(
//           child: _showIcon
//               ? Icon(
//                   widget.videoPlayerController.value.isPlaying
//                       ? Icons.pause
//                       : Icons.play_arrow,
//                   color: Colors.white,
//                   size: 50.0,
//                 )
//               : Container(),
//         ),
//       ),
//     );
//   }
// }
