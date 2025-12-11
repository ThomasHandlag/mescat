import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/shared/widgets/mc_button.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({super.key});

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _createWallet() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (mounted) {
        context.go(MescatRoutes.wallet);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create wallet: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 32),
            const Text(
              'Create your Mescat Wallet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Securely store your assets and manage your transactions within Mescat. Your wallet is encrypted and secure.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            McButton(
              onPressed: _isLoading ? null : _createWallet,
              padding: const EdgeInsets.symmetric(vertical: 16),
              selected: true,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Create Wallet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
