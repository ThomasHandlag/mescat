import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:mescat/shared/widgets/mc_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MescatBloc>().add(
        LoginRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          serverUrl: _serverController.text.trim().isEmpty
              ? 'https://matrix.org'
              : _serverController.text.trim(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> launchOAuth() async {
    final result = await FlutterWebAuth2.authenticate(
      url: "https://account.matrix.org",
      callbackUrlScheme: "my-custom-app",
    );

    final client = getIt<Client>();

    final redirectUrl = 'matrix://';

    final url = client.homeserver!.replace(
      path: '/_matrix/client/v3/login/sso/redirect',
      queryParameters: {'redirectUrl': redirectUrl},
    );

    // Extract token from resulting url
    // final token = Uri.parse(result).queryParameters['token'];
    log("OAuth Result: ${result.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MescatBloc, MescatStatus>(
      builder: (context, state) {
        final isLoading = state is Loading;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              TextFormField(
                controller: _usernameController,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Color(0xFF707E75)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _passwordController,
                enabled: !isLoading,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: McButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF707E75)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              // Login button
              Row(
                children: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Forgot password feature coming soon',
                                ),
                              ),
                            );
                          },
                    child: const Text('Forgot Password?'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: isLoading ? null : _login,
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
                        : const Text('Login'),
                  ),
                ],
              ),
              const Text('Or login with'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  McButton(
                    onPressed: () {
                      launchOAuth();
                    },
                    child: const Icon(FontAwesomeIcons.google),
                  ),
                  McButton(
                    onPressed: () {},
                    child: const Icon(FontAwesomeIcons.facebook),
                  ),
                  McButton(
                    onPressed: () {},
                    child: const Icon(FontAwesomeIcons.github),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 4.0),
                      ),
                    ),
                    onPressed: isLoading ? null : () {},
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
