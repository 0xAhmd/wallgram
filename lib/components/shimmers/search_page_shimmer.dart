import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserSearchShimmer extends StatelessWidget {
  const UserSearchShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
            ),
            title: Container(
              height: 14,
              width: 150,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 5),
            ),
            subtitle: Container(
              height: 12,
              width: 100,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
