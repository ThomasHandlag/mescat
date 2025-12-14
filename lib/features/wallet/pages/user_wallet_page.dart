import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/contracts/contracts.dart';
import 'package:http/http.dart' as http;
import 'package:mescat/core/routes/routes.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3dart/web3dart.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserWalletPage extends StatefulWidget {
  const UserWalletPage({super.key});

  @override
  State<UserWalletPage> createState() => _UserWalletPageState();
}

class _UserWalletPageState extends State<UserWalletPage>
    with WidgetsBindingObserver {
  bool _isLoading = true;

  late final EthereumAddress address;

  late final TorusUserInfo _userInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  void _init() async {
    try {
      // Initialize and check for existing session
      await Web3AuthFlutter.initialize();
      final privateKey = await Web3AuthFlutter.getPrivKey();
      final user = await Web3AuthFlutter.getUserInfo();

      if (privateKey.isEmpty) {
        context.pushReplacement(MescatRoutes.walletAuth);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      address = EthPrivateKey.fromHex(privateKey).address;
      _userInfo = user;
    } catch (e) {
      context.pushReplacement(MescatRoutes.walletAuth);
    }
  }

  Future<void> _logout() async {}

  void _showReceiveDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: QrImageView(
              data: address.hex,
              version: QrVersions.auto,
              embeddedImage: const AssetImage('assets/images/mescat_log.png'),
              gapless: false,
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(40, 40),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(body: LinearProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('My Wallet'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildActionButtons(theme),
              const SizedBox(height: 32),
              _buildBalanceCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          child: Row(
            children: [
              const CircleAvatar(radius: 20, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      _userInfo.name ?? 'asdawerq_user',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      address.hex,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings_outlined),
              onSelected: (value) async {
                switch (value) {
                  case 'copy_address':
                    final address = '';
                    if (address.isNotEmpty) {
                      await Clipboard.setData(ClipboardData(text: address));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address copied to clipboard'),
                          ),
                        );
                      }
                    }
                    break;
                  case 'logout':
                    _logout();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'copy_address',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 20),
                      SizedBox(width: 12),
                      Text('Copy Address'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 12),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
    final httpClient = http.Client();
    final web3Client = Web3Client(MescatContracts.url, httpClient);

    return FutureBuilder(
      future: web3Client.getBalance(address),
      builder: (context, snapshot) {
        final balance = snapshot.data ?? '...';
        return Center(
          child: Column(
            children: [
              Text(
                'Total balance',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(2)} MSC',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 12,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+1.8%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    final actions = [
      {'icon': Icons.arrow_outward, 'label': 'Send'},
      {
        'icon': Icons.arrow_downward,
        'label': 'Receive',
        'onPressed': _showReceiveDialog,
      },
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Deposit'},
      {'icon': Icons.qr_code_scanner, 'label': 'Scan'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blueGrey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(action['icon'] as IconData),
                onPressed: action['onPressed'] as void Function()?,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action['label'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

extension on Object {
  Object getValueInUnit(EtherUnit ether) {
    if (this is EtherAmount) {
      return (this as EtherAmount).getValueInUnit(ether);
    }
    return this;
  }

  String toStringAsFixed(int i) {
    if (this is double) {
      return (this as double).toStringAsFixed(i);
    }
    return toString();
  }
}
