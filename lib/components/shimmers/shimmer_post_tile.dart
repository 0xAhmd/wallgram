import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostTileShimmer extends StatelessWidget {
  const PostTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: theme.primary.withOpacity(0.2),
        highlightColor: theme.primary.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User row
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.white),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 14,
                  color: Colors.white,
                ),
                const Spacer(),
                Container(
                  width: 20,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Icon(Icons.more_horiz, color: theme.primary),
              ],
            ),
            const SizedBox(height: 16),

            // Message block
            Container(
              height: 14,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.white,
            ),
            Container(
              height: 14,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.white,
            ),
            Container(
              height: 14,
              width: 150,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.white,
            ),

            const SizedBox(height: 24),

            // Like and comment row
            Row(
              children: [
                Icon(Icons.favorite_border, color: theme.primary),
                const SizedBox(width: 8),
                Container(width: 20, height: 12, color: Colors.white),
                const SizedBox(width: 16),
                Icon(Icons.comment, color: theme.primary),
                const SizedBox(width: 8),
                Container(width: 20, height: 12, color: Colors.white),
                const Spacer(),
                Container(width: 50, height: 12, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
