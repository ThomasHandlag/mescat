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
import 'package:mescat/features/marketplace/pages/library_page.dart';
import 'package:mescat/features/wallet/cubits/wallet_cubit.dart';
import 'package:mescat/shared/util/extensions.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class MarketItem extends StatelessWidget with WidgetsBindingObserver {
  final NFT nft;

  const MarketItem({super.key, required this.nft});

  IpfsClient get ipfs => getIt<IpfsClient>();
  MarketRealm get realm => getIt<MarketRealm>();

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider(
      create: (context) =>
          ItemBloc(const ItemState(applyType: ApplyType.none), ipfs, realm)
            ..add(LoadItem(nft.id)),
      child: NftItem(nft: nft),
    );

    return Container(
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
    final applyType = jsonData['applyType'] != null
        ? ApplyType.values.firstWhere(
            (e) => e.name == jsonData['applyType'],
            orElse: () => ApplyType.none,
          )
        : ApplyType.none;

    if (jsonData['name'] == 'lottie') {
      final file = File("${path?.path}/MescatTemp/$uri.json");
      if (!file.existsSync()) {
        await file.create(recursive: true);
        await file.writeAsString(content);
      }

      emit(
        state.copyWith(
          loading: false,
          itemType: ItemType.lottie,
          path: file.path,
          applyType: applyType,
        ),
      );
    } else {
      final file = File("${path?.path}/MescatTemp/$uri");
      if (!file.existsSync()) {
        await file.create(recursive: true);
        final bytes = jsonData['bytes'];
        await file.writeAsString(bytes.toString());
      }
      emit(
        state.copyWith(
          loading: false,
          itemType: ItemType.meta,
          path: file.path,
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
    String? path,
    ApplyType? applyType,
  }) {
    return ItemState(
      itemType: itemType ?? this.itemType,
      loading: loading ?? this.loading,
      path: path ?? this.path,
      applyType: applyType ?? this.applyType,
    );
  }

  @override
  List<Object?> get props => [itemType, path, loading, applyType];
}

enum ItemType { meta, lottie }

class NftItem extends StatefulWidget {
  const NftItem({super.key, required this.nft});

  final NFT nft;

  @override
  State createState() => _NftItem();
}

class _NftItem extends State<NftItem> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _animation;

  MarketRealm get realm => getIt<MarketRealm>();

  NFT get nft => widget.nft;

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
    return Container(
      padding: const EdgeInsets.all(UIConstraints.mDefaultPadding),
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<ItemBloc, ItemState>(
              builder: (context, state) {
                if (state.applyType != ApplyType.none) {
                  log('Apply type: ${state.toString()}');
                }
                if (state.loading) {
                  return const LinearProgressIndicator();
                }

                if (state.itemType == null) {
                  return const Text('Item cannot be loaded');
                }

                return Stack(
                  children: [
                    switch (state.itemType) {
                      null => const Text('Item cannot be loaded'),
                      ItemType.lottie => _builLottie(state.path!),
                      ItemType.meta => Image.memory(
                        _getBytesFromString(
                          File(state.path!).readAsStringSync(),
                        ),
                        fit: BoxFit.contain,
                      ),
                    },
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen),
                        onPressed: () {
                          _fullScreen(switch (state.itemType) {
                            null => const Text('Item cannot be loaded'),
                            ItemType.lottie => _builLottie(state.path!),
                            ItemType.meta => Image.memory(
                              _getBytesFromString(
                                File(state.path!).readAsStringSync(),
                              ),
                              fit: BoxFit.contain,
                            ),
                          }, context);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          BlocBuilder<ItemBloc, ItemState>(
            builder: (context, state) => Align(
              alignment: Alignment.centerLeft,
              child: switch (state.applyType) {
                ApplyType.none => Chip(
                  avatar: CircleAvatar(
                    backgroundColor: state.applyType.name.generateFromString(),
                    child: Text(state.applyType.name[0]),
                  ),
                  label: Text(state.applyType.name.toUpperCase()),
                  elevation: 1,
                ),
                _ => Chip(
                  avatar: CircleAvatar(
                    backgroundColor: state.applyType.name.generateFromString(),
                    child: Text(state.applyType.name[0]),
                  ),
                  label: Text(state.applyType.name.toUpperCase()),
                  elevation: 1,
                ),
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  textAlign: TextAlign.start,
                  '${nft.price} GO',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  EthPrivateKey? pKey;
                  if (Platform.isAndroid || Platform.isIOS) {
                    final strKey = await Web3AuthFlutter.getPrivKey();
                    if (strKey.isEmpty) return;
                    pKey = EthPrivateKey.fromHex(strKey);
                  } else {
                    pKey = await context.read<WalletCubit>().tryGetkey();
                  }

                  if (pKey == null) {
                    return;
                  }

                  log('Buying asset with id: ${nft.id}');

                  realm.buyNft(nft, bytesToHex(pKey.privateKey));
                },
                child: const Text('Buy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _fullScreen(Widget content, BuildContext context) {
    showFullscreenDialog(
      context,
      Scaffold(
        appBar: AppBar(title: const Text('NFT Item')),
        body: Center(child: content),
      ),
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
