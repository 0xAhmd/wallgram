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
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Image.asset(img, height: 45),
      ),
    );
  }
}
