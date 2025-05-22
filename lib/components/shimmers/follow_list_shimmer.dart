import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FollowListShimmer extends StatelessWidget {
  const FollowListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: theme.colorScheme.primary.withOpacity(0.3),
          highlightColor: theme.colorScheme.primary.withOpacity(0.1),
          child: ListTile(
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
            ),
            title: Container(
              height: 12,
              width: 100,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            subtitle: Container(
              height: 10,
              width: 150,
              color: Colors.white,
              margin: const EdgeInsets.only(top: 4),
            ),
          ),
        );
      },
    );
  }
}
