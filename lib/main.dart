import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/pages/home_page.dart';
import 'package:wallgram/themes/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData, // ..,
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
