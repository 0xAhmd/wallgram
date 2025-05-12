import 'package:flutter/material.dart';

class MyBioBox extends StatelessWidget {
  const MyBioBox({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontSize: 17,
        ),
      ),
    );
  }
}
