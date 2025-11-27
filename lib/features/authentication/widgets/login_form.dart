import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, this.onSwitchToRegister});

  final void Function()? onSwitchToRegister;

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
  Widget build(BuildContext context) {
    return BlocBuilder<MescatBloc, MescatStatus>(
      builder: (context, state) {
        final isLoading = state is Loading;
        return Form(
          key: _formKey,
          child: Column(
            spacing: 10,
            children: [
              TextFormField(
                controller: _usernameController,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
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
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white10),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
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
              ),
              // Login button
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all<Size>(
                    const Size(double.infinity, 48),
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
              const Text('Or login with'),
              ElevatedButton.icon(
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all<Size>(
                    const Size(double.infinity, 48),
                  ),
                ),
                onPressed: () {
                  launchSSO();
                },
                label: const Text('Matrix SSO'),
                icon: const Icon(FontAwesomeIcons.elementor),
              ),
              // ElevatedButton.icon(
              //   style: ButtonStyle(
              //     minimumSize: WidgetStateProperty.all<Size>(
              //       const Size(double.infinity, 48),
              //     ),
              //   ),
              //   onPressed: () {
              //     context.push(MescatRoutes.walletAuth);
              //   },
              //   label: const Text('Wallet Key'),
              //   icon: const Icon(FontAwesomeIcons.wallet),
              // ),
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha(0x99),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
