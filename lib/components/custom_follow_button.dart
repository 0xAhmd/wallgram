import 'package:flutter/material.dart';

class CustomFollowButton extends StatelessWidget {
  const CustomFollowButton({
    super.key,
    required this.isFollowing,
    required this.onPressed,
  });
  final void Function()? onPressed;
  final bool isFollowing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          color:
              isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 32),
          onPressed: onPressed,
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
