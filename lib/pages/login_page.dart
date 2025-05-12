import 'package:flutter/material.dart';
import 'package:wallgram/components/custom_text_field.dart';
import 'package:wallgram/components/loading_indicator.dart';
import 'package:wallgram/components/my_custom_button.dart';
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

 void login() async {
  showLoadingIndicator(context);
  try {
    await _auth.loginService(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      hideLoadingIndicator(context);

      // Clear login fields (optional)
      _emailController.clear();
      _passwordController.clear();

      // Navigate to home page
      Navigator.pushReplacementNamed(context, HomePage.routeName); // Adjust route as needed
    }
  } catch (e) {
    if (mounted) hideLoadingIndicator(context);

    String errorMessage = 'An unexpected error occurred';
    if (e.toString().contains('Invalid password')) {
      errorMessage = 'The password you entered is incorrect.';
    } else if (e.toString().contains('User not found')) {
      errorMessage = 'No account found with this email.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forget Password?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
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
                        Navigator.pushNamed(context, RegistierPage.routeName);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
