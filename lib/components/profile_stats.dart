import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
  });
  final int postCount;
  final int followerCount;
  final int followingCount;
  @override
  Widget build(BuildContext context) {
    var textStyleForText = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );
    var textStyleForCount = TextStyle(
      color: Theme.of(context).colorScheme.inversePrimary,
      fontSize: 20,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text('Posts', style: textStyleForText),
              Text(postCount.toString(), style: textStyleForCount),
            ],
          ),
        ),
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text('Followers', style: textStyleForText),
              Text(followerCount.toString(), style: textStyleForCount),
            ],
          ),
        ),
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text('Following', style: textStyleForText),
              Text(followingCount.toString(), style: textStyleForCount),
            ],
          ),
        ),
      ],
    );
  }
}
