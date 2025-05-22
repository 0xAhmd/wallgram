import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommentShimmer extends StatelessWidget {
  const CommentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: theme.colorScheme.primary.withOpacity(0.3),
          highlightColor: theme.colorScheme.primary.withOpacity(0.1),
          child: ListTile(
            leading: const CircleAvatar(radius: 20),
            title: Container(
              height: 12,
              width: double.infinity,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 6),
            ),
            subtitle: Container(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
