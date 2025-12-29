import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

final class MetaLoginPage extends StatefulWidget {
  const MetaLoginPage({super.key});

  @override
  State<MetaLoginPage> createState() => _MetaLoginPageState();
}

final class _MetaLoginPageState extends State<MetaLoginPage>
    with WidgetsBindingObserver {
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    final Web3AuthResponse response = await Web3AuthFlutter.login(
      LoginParams(
        loginProvider: Provider.email_passwordless,
        extraLoginOptions: ExtraLoginOptions(login_hint: _emailController.text),
      ),
    );

    if (response.error != null) {
      context.pushReplacementNamed(MescatRoutes.wallet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privy Login')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Enter your email to login:'),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
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
        ],
      ),
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
