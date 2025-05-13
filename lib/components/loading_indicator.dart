import 'package:flutter/material.dart';

void showLoadingIndicator(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const AlertDialog(
        elevation: 0,
        content: Center(child: LinearProgressIndicator()),
        backgroundColor: Colors.transparent,
      );
    },
  );
}

void hideLoadingIndicator(BuildContext context) {
  Navigator.pop(context);
}
