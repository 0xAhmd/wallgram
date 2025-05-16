import 'package:flutter/material.dart';

class CustomFollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomFollowButton({
    super.key,
    required this.isFollowing,
    required this.onPressed,
    this.isLoading = false,
  });

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
          onPressed: isLoading ? null : onPressed, // disable tap during loading
          child:
              isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(
                    isFollowing ? 'Unfollow' : 'Follow',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}
