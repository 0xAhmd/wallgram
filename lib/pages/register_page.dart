import 'package:flutter/material.dart';
import 'package:wallgram/components/custom_text_field.dart';
import 'package:wallgram/components/loading_indicator.dart';
import 'package:wallgram/components/my_custom_button.dart';
import 'package:wallgram/pages/login_page.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/database_service.dart';

class RegistierPage extends StatefulWidget {
  const RegistierPage({super.key});

  static const String routeName = 'register_page';
  @override
  State<RegistierPage> createState() => _RegistierPageState();
}

class _RegistierPageState extends State<RegistierPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final _auth = AuthService();
  final _db = DatabaseService();

  void register() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      showLoadingIndicator(context);
      try {
        // 1. Register user with Firebase Auth
        await _auth.registerService(
          _emailController.text,
          _passwordController.text,
        );

        // 2. Save user data to Firestore FIRST
        await _db.saveUserInfoInFirebase(
          name:
              _usernameController.text, // Use controller values BEFORE clearing
          email: _emailController.text,
        );

        // 3. Post-registration cleanup
        if (mounted) {
          hideLoadingIndicator(context);
          // Clear controllers AFTER saving data
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _usernameController.clear();
          // Navigate to login page
          Navigator.pushReplacementNamed(context, LoginPage.routeName);
        }
      } catch (e) {
        if (mounted) hideLoadingIndicator(context);

        String errorMessage = 'An unexpected error occurred';
        if (e.toString().contains('Invalid email')) {
          errorMessage = 'The email address is invalid.';
        } else if (e.toString().contains('Weak password')) {
          errorMessage = 'The password is too weak.';
        } else if (e.toString().contains('Email already in use')) {
          errorMessage = 'This email is already registered.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.create,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Let\'s Make Your Account',
                    style: TextStyle(
                      fontSize: 19,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _usernameController,
                    hintText: 'Enter your name',
                    icon: Icons.person,
                    obscureText: false,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Enter your Email',
                    icon: Icons.email,
                    obscureText: false,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Enter your Password',
                    icon: Icons.password,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm your Password',
                    icon: Icons.key,
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  MyCustomButton(text: 'Register', onPressed: register),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, LoginPage.routeName);
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
