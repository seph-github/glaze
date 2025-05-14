import 'package:flutter/material.dart';
import 'package:glaze/features/video/widget/interaction_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InteractionButtons extends StatelessWidget {
  const InteractionButtons({
    super.key,
    required this.isLiked,
    required this.isBookmarked,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
  });

  final bool isLiked;
  final bool isBookmarked;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 20,
        children: [
          InteractionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            count: likeCount,
            color: isLiked ? Colors.red : Colors.white,
          ),
          InteractionButton(icon: LucideIcons.messageCircle, count: commentCount),
          InteractionButton(icon: LucideIcons.send, count: shareCount),
          Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white, size: 36),
        ],
      ),
    );
  }
}
