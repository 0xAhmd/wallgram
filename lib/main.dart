import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/firebase_options.dart';
import 'package:wallgram/pages/home_page.dart';
import 'package:wallgram/pages/login_page.dart';
import 'package:wallgram/pages/register_page.dart';
import 'package:wallgram/services/auth/auth_gate.dart';
import 'package:wallgram/themes/theme_provider.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.grey.shade300,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        LoginPage.routeName: (context) => const LoginPage(),
        RegistierPage.routeName: (context) => const RegistierPage(),
      },
      theme: Provider.of<ThemeProvider>(context).themeData, //
      home: AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
