import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wallgram/models/post.dart';
import 'firebase_options.dart';
import 'locator.dart';
import 'pages/account_settings_page.dart';
import 'pages/home_page.dart';
import 'pages/block_list_page.dart';
import 'pages/login_page.dart';
import 'pages/notification_page.dart';
import 'pages/register_page.dart';
import 'pages/search_page.dart';
import 'services/auth/auth_gate.dart';
import 'services/provider/app_provider.dart';
import 'services/provider/internet_provider.dart';
import 'themes/dark_mode.dart';
import 'themes/light_mode.dart';
import 'themes/theme_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PostAdapter());
  await Hive.openBox<Post>('cachedPosts');
  await Hive.openBox(
    'cacheMeta',
  ); // <--- for storing timestamps and other metadata
  final supabaseUrl = dotenv.env['url'];
  final supabaseAnonKey = dotenv.env['anonKey'];
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Supabase URL or Anon Key is missing in .env file');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(create: (_) => InternetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        notificationsPage.routeName: (context) => const notificationsPage(),
        SearchPage.routeName: (context) => const SearchPage(),
        AccountSettingsPage.routeName: (context) => const AccountSettingsPage(),
        BlockListPage.routeName: (context) => const BlockListPage(),
        HomePage.routeName: (context) => const HomePage(),
        LoginPage.routeName: (context) => const LoginPage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
      },
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
