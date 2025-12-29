import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, this.onSwitchToLogin});

  final void Function()? onSwitchToLogin;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // bool _obscurePassword = true;
  // bool _obscureConfirmPassword = true;

  bool isLoading = false;

  Future<void> launchSSO() async {
    try {
      final redirectUrl = Platform.isAndroid || Platform.isIOS
          ? 'mescat://login'
          : 'http://localhost:3001';

      final client = getIt<Client>();

      final url = (client.homeserver ?? Uri.parse('https://matrix.org'))
          .replace(
            path: '/_matrix/client/v3/login/sso/redirect',
            queryParameters: {'redirectUrl': redirectUrl},
          );

      final urlScheme = Platform.isAndroid || Platform.isIOS
          ? 'mescat'
          : 'http://localhost:3001';

      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: urlScheme,
        options: FlutterWebAuth2Options(
          useWebview: Platform.isWindows || Platform.isLinux ? false : true,
        ),
      );
      final token = Uri.parse(result).queryParameters['loginToken'];
      if (token?.isEmpty ?? false) return;

      setState(() {
        isLoading = true;
      });

      _loginWithToken(token!);
    } catch (e) {
      log('error during oauth login: $e');
      _snackBar('Cancel authentication');
    }
  }

  void _loginWithToken(String token) {
    context.read<MescatBloc>().add(SSOLoginRequested(loginToken: token));
  }

  void _snackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MescatBloc, MescatStatus>(
      builder: (context, state) {
        final isLoading = state is Loading;

        return SizedBox(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // if (state is AuthError) ...[
                  //   Text(
                  //     state.message,
                  //     style: const TextStyle(color: Colors.red),
                  //   ),
                  //   const SizedBox(height: 16),
                  // ],
                  // // Username field
                  // TextFormField(
                  //   controller: _usernameController,
                  //   enabled: !isLoading,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Username',
                  //     hintText: 'Choose a unique username',
                  //     border: OutlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.black),
                  //       borderRadius: BorderRadius.all(Radius.circular(12)),
                  //     ),
                  //     labelStyle: TextStyle(color: Color(0xFF707E75)),
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.trim().isEmpty) {
                  //       return 'Please enter a username';
                  //     }
                  //     if (value.trim().length < 3) {
                  //       return 'Username must be at least 3 characters';
                  //     }
                  //     return null;
                  //   },
                  // ),

                  // const SizedBox(height: 16),

                  // // Email field (optional)
                  // TextFormField(
                  //   controller: _emailController,
                  //   enabled: !isLoading,
                  //   keyboardType: TextInputType.emailAddress,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Email (optional)',
                  //     hintText: 'your.email@example.com',
                  //     border: OutlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.black),
                  //       borderRadius: BorderRadius.all(Radius.circular(12)),
                  //     ),
                  //     labelStyle: TextStyle(color: Color(0xFF707E75)),
                  //   ),
                  //   validator: (value) {
                  //     if (value != null && value.isNotEmpty) {
                  //       final emailRegex = RegExp(
                  //         r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  //       );
                  //       if (!emailRegex.hasMatch(value)) {
                  //         return 'Please enter a valid email address';
                  //       }
                  //     }
                  //     return null;
                  //   },
                  // ),

                  // const SizedBox(height: 16),

                  // // Password field
                  // TextFormField(
                  //   controller: _passwordController,
                  //   enabled: !isLoading,
                  //   obscureText: _obscurePassword,
                  //   decoration: InputDecoration(
                  //     labelText: 'Password',
                  //     border: const OutlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.black),
                  //       borderRadius: BorderRadius.all(Radius.circular(12)),
                  //     ),
                  //     labelStyle: const TextStyle(color: Color(0xFF707E75)),
                  //     suffixIcon: IconButton(
                  //       onPressed: () {
                  //         setState(() {
                  //           _obscurePassword = !_obscurePassword;
                  //         });
                  //       },
                  //       icon: Icon(
                  //         _obscurePassword
                  //             ? Icons.visibility
                  //             : Icons.visibility_off,
                  //       ),
                  //     ),
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter a password';
                  //     }
                  //     if (value.length < 8) {
                  //       return 'Password must be at least 8 characters';
                  //     }
                  //     return null;
                  //   },
                  // ),

                  // const SizedBox(height: 16),

                  // // Confirm password field
                  // TextFormField(
                  //   controller: _confirmPasswordController,
                  //   enabled: !isLoading,
                  //   obscureText: _obscureConfirmPassword,
                  //   decoration: InputDecoration(
                  //     labelText: 'Confirm Password',
                  //     border: const OutlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.black),
                  //       borderRadius: BorderRadius.all(Radius.circular(12)),
                  //     ),
                  //     labelStyle: const TextStyle(color: Color(0xFF707E75)),
                  //     suffixIcon: IconButton(
                  //       onPressed: () {
                  //         setState(() {
                  //           _obscureConfirmPassword = !_obscureConfirmPassword;
                  //         });
                  //       },
                  //       icon: Icon(
                  //         _obscureConfirmPassword
                  //             ? Icons.visibility
                  //             : Icons.visibility_off,
                  //       ),
                  //     ),
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please confirm your password';
                  //     }
                  //     if (value != _passwordController.text) {
                  //       return 'Passwords do not match';
                  //     }
                  //     return null;
                  //   },
                  // ),

                  // const SizedBox(height: 24),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : launchSSO,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Register'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: isLoading ? null : widget.onSwitchToLogin,
                        child: const Text('Login'),
                      ),
                    ],
                  ),

                  // Terms and conditions
                  Text(
                    'By registering, you agree to our Terms of Service and Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(0x99),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
