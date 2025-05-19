import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/pages/home_page.dart';
import 'package:wallgram/pages/login_page.dart';
import 'package:wallgram/services/database/database_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          // Initialize notifications after first frame render
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final provider = Provider.of<DatabaseProvider>(
              context,
              listen: false,
            );
            provider.initNotificationsListener();
          });
          
          return const HomePage();
        }

        // User not logged in
        return const LoginPage();
      },
    );
  }
}