import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ipfsdart/ipfsdart.dart';
import 'package:lottie/lottie.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/marketplace/data/market_realm.dart';
import 'package:mescat/features/marketplace/data/nft.dart';
import 'package:mescat/features/settings/cubits/nft_usage_cubit.dart';
import 'package:mescat/features/wallet/cubits/wallet_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  MarketRealm get realm => getIt();

  Future<String?> _tryGetKey(BuildContext context) async {
    if (!context.mounted) return null;

    EthPrivateKey? key;

    if (Platform.isAndroid || Platform.isIOS) {
      final priv = await Web3AuthFlutter.getPrivKey();
      if (priv.isEmpty) return null;
      key = EthPrivateKey.fromHex(priv);
    } else {
      key = await context.read<WalletCubit>().tryGetkey();
    }
    return bytesToHex(key!.privateKey, include0x: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: FutureBuilder(
        future: _tryGetKey(context),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }

          if (!snap.hasData || snap.data == null) {
            return const Center(
              child: Text('No wallet found. Please create or import a wallet.'),
            );
          }

          return BlocProvider(
            create: (context) =>
                LibraryBloc(const LibraryState(), realm: realm)
                  ..load(snap.data!),
            child: const Padding(
              padding: EdgeInsets.all(UIConstraints.mDefaultPadding),
              child: LibraryList(),
            ),
          );
        },
      ),
    );
  }
}

class LibraryList extends StatelessWidget with WidgetsBindingObserver {
  const LibraryList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        return GridView.builder(
          itemBuilder: (context, index) {
            final nft = state.nfts[index];
            return LibraryItem(nft: nft);
          },
          itemCount: state.nfts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Platform.isAndroid || Platform.isIOS ? 1 : 4,
            mainAxisSpacing: UIConstraints.mDefaultPadding,
            crossAxisSpacing: UIConstraints.mDefaultPadding,
          ),
        );
      },
    );
  }
}

class LibraryItem extends StatelessWidget {
  const LibraryItem({super.key, required this.nft});

  final NFT nft;

  IpfsClient get ipfs => getIt<IpfsClient>();
  MarketRealm get realm => getIt<MarketRealm>();

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider(
      create: (context) =>
          ItemBloc(const ItemState(applyType: ApplyType.none), ipfs, realm)
            ..add(LoadItem(nft.id)),
      child: const NftItem(),
    );

    return Container(
      padding: const EdgeInsets.all(UIConstraints.mDefaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: content,
    );
  }
}

enum ApplyType { chatlist, roomlist, userbox, chatinput, none }

final class LibraryState extends Equatable {
  final List<NFT> nfts;

  const LibraryState({this.nfts = const <NFT>[]});

  LibraryState copyWith(List<NFT> nfts) {
    return LibraryState(nfts: nfts);
  }

  @override
  List<Object?> get props => [nfts];
}

final class LibraryBloc extends Cubit<LibraryState> {
  LibraryBloc(super.initialState, {required this.realm});
  final MarketRealm realm;

  Future<void> load(String key) async {
    final rs = await realm.ownedNFT(key);

    rs.fold((e) {}, (v) {
      emit(state.copyWith(v));
    });
  }
}

final class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final IpfsClient _ipfs;
  final MarketRealm _realm;

  ItemBloc(super.initialState, this._ipfs, this._realm) {
    on<LoadItem>(_onLoadItem);
  }

  Future<void> _onLoadItem(LoadItem event, Emitter<ItemState> emit) async {
    emit(state.copyWith(loading: true));
    final tokenUri = await _realm.musicat.tokenURI((tokenId: event.id));

    log('Loaded tokenURI: $tokenUri');

    final uri = tokenUri.substring(tokenUri.indexOf('/') + 1);

    final rs = await _ipfs.getFile('/ipfs/$uri');

    final content = rs.substring(rs.indexOf('{'), rs.lastIndexOf('}') + 1);

    final path = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    final jsonData = await jsonDecode(content);

    final applyType = switch (jsonData['applyType']) {
      'chatlist' => ApplyType.chatlist,
      'chatinput' => ApplyType.chatinput,
      'roomlist' => ApplyType.roomlist,
      'userbox' => ApplyType.userbox,
      _ => ApplyType.none,
    };

    if (jsonData['name'] == 'lottie') {
      final tempFile = File("${path?.path}/MescatTemp/lib/$uri.json");
      if (!await tempFile.exists()) {
        await tempFile.create(recursive: true);
        await tempFile.writeAsString(content);
      }
      emit(
        state.copyWith(
          loading: false,
          itemType: ItemType.lottie,
          bytes: tempFile.path,
          applyType: applyType,
        ),
      );
    } else {
      final tempFile = File("${path?.path}/MescatTemp/lib/$uri");
      if (!await tempFile.exists()) {
        await tempFile.create(recursive: true);
        await tempFile.writeAsString(content);
      }
      final bytes = jsonData['bytes'];
      await tempFile.writeAsString(bytes.toString());
      emit(
        state.copyWith(
          loading: false,
          itemType: ItemType.meta,
          bytes: tempFile.path,
          applyType: applyType,
        ),
      );
    }
  }
}

abstract class ItemEvent {
  const ItemEvent();
}

final class LoadItem extends ItemEvent {
  final BigInt id;
  const LoadItem(this.id);
}

final class ItemState extends Equatable {
  final ItemType? itemType;
  final String? path;
  final bool loading;
  final ApplyType applyType;

  const ItemState({
    this.itemType,
    this.loading = false,
    this.path,
    required this.applyType,
  });

  ItemState copyWith({
    ItemType? itemType,
    bool? loading,
    String? bytes,
    ApplyType? applyType,
  }) {
    return ItemState(
      itemType: itemType ?? this.itemType,
      loading: loading ?? this.loading,
      path: bytes ?? this.path,
      applyType: applyType ?? this.applyType,
    );
  }

  @override
  List<Object?> get props => [itemType, path, loading, applyType];
}

enum ItemType { meta, lottie }

class NftItem extends StatefulWidget {
  const NftItem({super.key});

  @override
  State createState() => _NftItem();
}

class _NftItem extends State<NftItem> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Uint8List _getBytesFromString(String stringBytes) {
    final intList = jsonDecode(stringBytes).map<int>((e) => e as int).toList();

    final Uint8List bytes = Uint8List.fromList(intList);

    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        if (state.loading) {
          return const CircularProgressIndicator(
            constraints: BoxConstraints(maxWidth: 40),
          );
        }

        if (state.itemType == null) {
          return const Text('Item cannot be loaded');
        }

        return Column(
          children: [
            Expanded(
              child: switch (state.itemType) {
                null => const Text('Item cannot be loaded'),
                ItemType.lottie => _builLottie(state.path!),
                ItemType.meta => Image.memory(
                  _getBytesFromString(File(state.path!).readAsStringSync()),
                  fit: BoxFit.contain,
                ),
              },
            ),
            if (state.applyType != ApplyType.none)
              ElevatedButton(
                onPressed: () {
                  _apply(
                    context,
                    state.path!,
                    state.applyType,
                    state.itemType!,
                  );
                },
                child: const Text('Apply'),
              ),
          ],
        );
      },
    );
  }

  void _apply(
    BuildContext context,
    String path,
    ApplyType? applyType,
    ItemType itemType,
  ) async {
    final nftCubit = context.read<NftUsageCubit>();

    nftCubit.setNftUsage(
      applyType ?? ApplyType.none,
      NftUsageItem(itemType: itemType, path: path),
    );
  }

  Widget _builLottie(String path) {
    return GestureDetector(
      onTap: () {
        _animationController
          ..value = 0
          ..forward();
      },
      child: MouseRegion(
        onHover: (event) {
          if (_animationController.isCompleted) {
            _animationController
              ..value = 0
              ..forward();
          }
        },
        child: Lottie.file(File(path), controller: _animation, animate: true),
      ),
    );
  }
}
