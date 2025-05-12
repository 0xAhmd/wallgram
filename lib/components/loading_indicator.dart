import 'package:flutter/material.dart';

void showLoadingIndicator(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        elevation: 0,
        content: const Center(child: LinearProgressIndicator()),
        backgroundColor: Colors.transparent,
      );
    },
  );
}

void hideLoadingIndicator(BuildContext context) {
  Navigator.pop(context);
}
