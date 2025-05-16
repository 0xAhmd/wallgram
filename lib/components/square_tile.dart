import 'package:flutter/material.dart';

class CustomSquareTile extends StatelessWidget {
  const CustomSquareTile({super.key, required this.onTap, required this.img});
  final String img;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Image.asset(img, height: 45),
      ),
    );
  }
}
