import 'package:flutter/material.dart';

class MyInputDialogBox extends StatelessWidget {
  const MyInputDialogBox({
    super.key,
    required this.hintText,
    this.onPressed,
    required this.onPressedText,
    required this.controller,
  });
  final TextEditingController controller;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            controller.clear();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            // Call onPressed first to process the input before clearing
            onPressed!();
            Navigator.pop(context);
            controller.clear();
          },
          child: Text(onPressedText),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Theme.of(context).colorScheme.surface,

      content: TextField(
        controller: controller,

        decoration: InputDecoration(
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        maxLines: 3,
        maxLength: 140,
      ),
    );
  }
}
