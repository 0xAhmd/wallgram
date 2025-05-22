import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BlockedUserShimmer extends StatelessWidget {
  const BlockedUserShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Container(
                height: 12,
                width: 100,
                color: Colors.white,
              ),
              subtitle: Container(
                height: 10,
                width: 60,
                margin: const EdgeInsets.only(top: 5),
                color: Colors.white,
              ),
              trailing: const Icon(Icons.block, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
