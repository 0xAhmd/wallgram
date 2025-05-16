import 'package:flutter/material.dart';
import 'package:wallgram/pages/home_page.dart';

void goHomePage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const HomePage()),
    (route) => route.isFirst,
  );
}
