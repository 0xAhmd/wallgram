import 'package:flutter/material.dart';
import 'package:wallgram/components/custom_text_field.dart';
import 'package:wallgram/components/my_custom_button.dart';
import 'package:wallgram/pages/login_page.dart';

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
                  obscureText: true,
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
                MyCustomButton(
                  text: 'Register',
                  onPressed: () {
                    // Handle login logic
                  },
                ),
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
    );
  }
}
