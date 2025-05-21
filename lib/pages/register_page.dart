import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallgram/components/loading_indicator.dart';
import 'package:wallgram/components/my_custom_button.dart';
import 'package:wallgram/pages/login_page.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/database_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const String routeName = 'register_page';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  final _auth = AuthService();
  final _db = DatabaseService();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _emailController,
      _passwordController,
      _confirmPasswordController,
      _usernameController,
    ]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';

    // Trim leading and trailing spaces
    final trimmed = value.trim();

    // Disallow multiple consecutive spaces
    if (RegExp(r'\s{2,}').hasMatch(trimmed))
      return 'Multiple spaces are not allowed';

    // Disallow leading or trailing spaces
    if (value != trimmed) return 'Username cannot start or end with a space';

    // Disallow emojis
    final emojiRegex = RegExp(
      r'[\u203C-\u3299\uD83C\uD000-\uDFFF\uD83D\uD000-\uDFFF\uD83E\uD000-\uDFFF]',
    );
    if (emojiRegex.hasMatch(trimmed)) return 'Emojis are not allowed';

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
      return 'Invalid email format';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Needs 1 uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Needs 1 lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Needs 1 number';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value))
      return 'Needs 1 special character';
    final emailLocal = _emailController.text.split('@').first;
    if (emailLocal.length > 2 && value.contains(emailLocal))
      return 'Cannot contain email parts';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm password';
    if (value != _passwordController.text) return 'Passwords don\'t match';
    return null;
  }

  bool get _isFormValid => _formKey.currentState?.validate() ?? false;

  void _register() async {
    if (!_isFormValid) return;
    showLoadingIndicator(context);
    try {
      await _auth.registerService(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await _db.saveUserInfoInFirebase(
        name: _usernameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      hideLoadingIndicator(context);
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } catch (e) {
      if (!mounted) return;
      hideLoadingIndicator(context);
      final errorMessage =
          e is FirebaseAuthException
              ? e.message ?? 'Authentication error'
              : 'Registration failed: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required FormFieldValidator<String> validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 90, color: primaryColor),
                  const SizedBox(height: 20),
                  Text(
                    'Let\'s Make Your Account',
                    style: TextStyle(
                      fontSize: 19,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Enter your name',
                    prefixIcon: Icons.person,
                    validator: _validateUsername,
                  ),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email,
                    validator: _validateEmail,
                  ),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock,
                    validator: _validatePassword,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                  ),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm password',
                    prefixIcon: Icons.key,
                    validator: _validateConfirmPassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  MyCustomButton(
                    text: 'Register',
                    onPressed: _isFormValid ? _register : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(fontSize: 16, color: primaryColor),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(
                              context,
                              LoginPage.routeName,
                            ),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
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
