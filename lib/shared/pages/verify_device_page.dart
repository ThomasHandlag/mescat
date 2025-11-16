import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/dependency_injection.dart';

class VerifyDevicePage extends StatefulWidget {
  const VerifyDevicePage({super.key});

  @override
  State<VerifyDevicePage> createState() => _VerifyDevicePageState();
}

class _VerifyDevicePageState extends State<VerifyDevicePage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _sssStorageKeyController =
      TextEditingController();

  late Bootstrap bootstrap;

  String? _error;

  @override
  void initState() {
    super.initState();
    _createBootstrap();
  }

  void _createBootstrap() async {
    final client = getIt<Client>();
    bootstrap = client.encryption!.bootstrap(onUpdate: (_) => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool _isVerifying = false;
  final bool _wipe = false;

  void _startVerification() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      final key = _codeController.text.trim();
      if (key.isEmpty) return;
      if (bootstrap.newSsssKey == null) return;
      await bootstrap.newSsssKey!.unlock(keyOrPassphrase: key);
      await bootstrap.openExistingSsss();
      Logs().d('SSSS unlocked');
      if (bootstrap.encryption.crossSigning.enabled) {
        Logs().v('Cross signing is already enabled. Try to self-sign');
        try {
          await bootstrap.client.encryption!.crossSigning.selfSign(
            recoveryKey: key,
          );
          Logs().d('Successful selfsigned');
        } catch (e, s) {
          Logs().e(
            'Unable to self sign with recovery key after successfully open existing SSSS',
            e,
            s,
          );
        }
      }
    } on InvalidPassphraseException catch (_) {
      setState(() => _error = 'Invalid recovery key');
    } on FormatException catch (_) {
      setState(() => _error = 'The recovery key format is invalid.');
    } catch (e, s) {
      Logs().e('Error during device verification', e, s);
      setState(() {
        _error = 'Cannot verify device';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  String? titleText;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];
    Widget body = const LinearProgressIndicator();

    if (bootstrap.newSsssKey?.recoveryKey != null) {
      final key = bootstrap.newSsssKey!.recoveryKey;
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(context).pop,
          ),
          title: const Text('Verify Device'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  trailing: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.info_outlined),
                  ),
                  subtitle: Text(
                    'Please save this recovery key in a safe place. '
                    'You will need it to recover your encrypted messages if you lose access to this device.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                const Divider(height: 32, thickness: 1),
                TextField(
                  minLines: 2,
                  maxLines: 4,
                  readOnly: true,
                  controller: TextEditingController(text: key),
                  style: const TextStyle(fontFamily: 'RobotoMono'),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: const Icon(Icons.key_outlined),
                    border: const OutlineInputBorder(),
                    suffix: IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: key ?? ''));
                      },
                      icon: const Icon(Icons.copy),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _sssStorageKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Storage Key',
                    hintText: 'Enter a storage key',
                    suffixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      switch (bootstrap.state) {
        case BootstrapState.loading:
          break;
        case BootstrapState.askWipeSsss:
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => bootstrap.wipeSsss(_wipe),
          );
          break;
        case BootstrapState.askBadSsss:
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => bootstrap.ignoreBadSecrets(true),
          );
          break;
        case BootstrapState.askUseExistingSsss:
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => bootstrap.useExistingSsss(!_wipe),
          );
          break;
        case BootstrapState.askUnlockSsss:
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => bootstrap.unlockedSsss(),
          );
          break;
        case BootstrapState.askNewSsss:
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => bootstrap.newSsss(),
          );
          break;
        case BootstrapState.openExistingSsss:
          return Scaffold(
            appBar: AppBar(title: const Text('Verify Device')),
            body: Center(
              child: SizedBox(
                width: Platform.isAndroid || Platform.isIOS
                    ? double.infinity
                    : 400,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'To ensure the security of your conversations, please verify this device. '
                      'Verifying your device helps protect against unauthorized access and ensures that your messages remain private.',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Verification Code',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _startVerification();
                      },
                      label: const Text('Start Verification'),
                      icon: _isVerifying
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.verified),
                    ),
                    if (_isVerifying) const LinearProgressIndicator(),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          );
        case BootstrapState.askWipeCrossSigning:
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => bootstrap.wipeCrossSigning(_wipe),
          );
          break;
        case BootstrapState.askSetupCrossSigning:
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => bootstrap.askSetupCrossSigning(
              setupMasterKey: true,
              setupSelfSigningKey: true,
              setupUserSigningKey: true,
            ),
          );
          break;
        case BootstrapState.askWipeOnlineKeyBackup:
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => bootstrap.wipeOnlineKeyBackup(_wipe),
          );

          break;
        case BootstrapState.askSetupOnlineKeyBackup:
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => bootstrap.askSetupOnlineKeyBackup(true),
          );
          break;
        case BootstrapState.error:
          titleText = 'Something went wrong';
          body = const Icon(Icons.error_outline, color: Colors.red, size: 80);
          buttons.add(
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: false).pop<bool>(false),
              child: const Text('Close'),
            ),
          );
          break;
        case BootstrapState.done:
          titleText = 'Everything is ready';
          body = const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 120, color: Colors.green),
              SizedBox(height: 16),
              Text(
                'Your chat backup has been set up',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 16),
            ],
          );
          buttons.add(
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: false).pop<bool>(false),
              child: const Text('Close'),
            ),
          );
          break;
      }
    }
    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: CloseButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: false).pop<bool>(true),
          ),
        ),
        title: Text(titleText ?? 'Loading, please wait'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [body, const SizedBox(height: 8), ...buttons],
          ),
        ),
      ),
    );
  }
}
