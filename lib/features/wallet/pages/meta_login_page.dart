import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/wallet/cubits/wallet_cubit.dart';
import 'package:mescat/features/wallet/data/wallet_store.dart';
import 'package:mescat/shared/widgets/input_field.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

final class MetaLoginPage extends StatefulWidget {
  const MetaLoginPage({super.key});

  @override
  State<MetaLoginPage> createState() => _MetaLoginPageState();
}

final class _MetaLoginPageState extends State<MetaLoginPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _isLoading = false;

  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  late final AnimationController _controller;
  late final Animation<double> _animation;

  WalletStore get walletStore => getIt();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Web3AuthFlutter.setCustomTabsClosed();
    }
  }

  Future<void> _loginWithMail() async {
    await Web3AuthFlutter.login(
      LoginParams(
        loginProvider: Provider.email_passwordless,
        extraLoginOptions: ExtraLoginOptions(login_hint: _keyController.text),
      ),
    );
    if (mounted) {
      context.pushReplacement(MescatRoutes.wallet);
    }
  }

  Future<void> _createWallet(String key, String password) async {
    await walletStore.storeKey(key, password);
  }

  List<Widget> _buildMobile() {
    return [
      const Text('Enter your email to login:'),
      const SizedBox(height: 16),
      TextField(
        controller: _keyController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Email',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
        ],
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await _loginWithMail();
                setState(() {
                  _isLoading = false;
                });
              },
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Send Verification Code'),
      ),
    ];
  }

  List<Widget> _buildDesktop() {
    return [
      Text(
        'Create a new wallet',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      InputField(
        controller: _keyController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Private Key (hex)',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9]')),
        ],
        keyboardType: TextInputType.visiblePassword,
      ),
      InputField(
        controller: _codeController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Password',
        ),
        obscureText: true,
      ),
      ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await _createWallet(_keyController.text, _codeController.text);
                setState(() {
                  _isLoading = false;
                });
                if (mounted) {
                  context.read<WalletCubit>().updateWalletAddress(
                    _keyController.text,
                  );
                  context.go(MescatRoutes.wallet);
                }
              },
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Create Wallet'),
      ),
    ];
  }

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final content = ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      padding: const EdgeInsets.all(16),
      itemCount: (_isMobile ? _buildMobile() : _buildDesktop()).length,
      itemBuilder: (context, index) {
        final children = _isMobile ? _buildMobile() : _buildDesktop();
        return children[index];
      },
    );

    if (!_isMobile) {
      return Scaffold(
        appBar: AppBar(),
        body: Row(
          children: [
            Expanded(
              child: LottieBuilder.asset(
                '${Assets.riveAsset}/loader_cat.json',
                controller: _animation,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(50),
                    width: 1,
                  ),
                ),
              ),
              width: 400,
              child: Center(child: content),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Login')),
      body: content,
    );
  }
}

class VerifyCodeInput extends StatefulWidget {
  const VerifyCodeInput({super.key, required this.onSubmit, this.length = 6});

  final void Function(String code) onSubmit;
  final int length;

  @override
  State<VerifyCodeInput> createState() => _VerifyCodeInputState();
}

class _VerifyCodeInputState extends State<VerifyCodeInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            final text = _controller.text;
            final char = index < text.length ? text[index] : '';
            final isFocused = _focusNode.hasFocus && index == text.length;

            return Expanded(
              child: AspectRatio(
                aspectRatio: 0.85,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.deepPurple, width: 2),
                    boxShadow: [
                      if (isFocused)
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withAlpha(51),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    char,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        // Invisible TextField to capture input
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              onChanged: (value) {
                setState(() {});
                if (value.length == widget.length) {
                  widget.onSubmit(value);
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              showCursor: false,
              enableInteractiveSelection: false, // Keep enabled for paste
            ),
          ),
        ),
      ],
    );
  }
}
