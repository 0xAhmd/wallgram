import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallgram/components/custom_text_field.dart';
import 'package:wallgram/components/loading_indicator.dart';
import 'package:wallgram/components/my_custom_button.dart';
import 'package:wallgram/components/square_tile.dart';
import 'package:wallgram/pages/home_page.dart';
import 'package:wallgram/pages/register_page.dart';
import 'package:wallgram/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String routeName = 'login_page';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() async {
    showLoadingIndicator(context);
    try {
      await _auth.loginService(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        hideLoadingIndicator(context);
        _emailController.clear();
        _passwordController.clear();
        Navigator.pushReplacementNamed(context, HomePage.routeName);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) hideLoadingIndicator(context);

      String errorMessage = 'An unexpected error occurred';

      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'The password you entered is incorrect.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        case 'invalid-credential':
          errorMessage = 'Incorrect email or password.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        // Add other cases as needed
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
    } catch (e) {
      if (mounted) hideLoadingIndicator(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An unexpected error occurred',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _signInWithGoogle(BuildContext context) async {
    showLoadingIndicator(context);
    try {
      final user = await _auth.handleGoogleSignIn();

      if (user != null) {
        if (mounted) {
          hideLoadingIndicator(context);
          Navigator.pushReplacementNamed(context, HomePage.routeName);
        }
      } else {
        if (mounted) {
          hideLoadingIndicator(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Google sign-in failed or canceled")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        hideLoadingIndicator(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Icon(
                          Icons.lock_open,
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Welcome Back, you\'ve been missed',
                          style: TextStyle(
                            fontSize: 19,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 25),
                        MyCustomButton(text: 'Login', onPressed: login),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  RegisterPage.routeName,
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[400],
                                thickness: 0.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Text(
                                'Or Sign in With',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[400],
                                thickness: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomSquareTile(
                          img: 'assets/google.png',
                          onTap: () => _signInWithGoogle(context),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
