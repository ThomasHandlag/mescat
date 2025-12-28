import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/wallet/data/wallet_store.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3dart/web3dart.dart';

class WalletCubit extends Cubit<String> {
  WalletCubit(super.initialState, this._store);

  final WalletStore _store;

  void updateWalletAddress(String address) {
    emit(address);
  }

  void init() async {
    final privKey = await tryGetkey();

    if (privKey != null) {
      log(
        'WalletCubit: Retrieved private key with address ${privKey.address.hex}',
      );
      emit(privKey.address.hex);
    } else {
      log('WalletCubit: No private key found.');
    }
  }

  Future<EthPrivateKey?> tryGetkey() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final pKey = await _getPrivKey();
      if (pKey == null) return null;
      return EthPrivateKey.fromHex(pKey);
    } else {
      final password = await _store.getPassword();
      if (password == null) return null;

      final privateKey = await _store.retrieveKey(password);
      return privateKey;
    }
  }

  Future<String?> _getPrivKey() async {
    final pKey = await Web3AuthFlutter.getPrivKey();
    log('Retrieved private key from Web3Auth: $pKey');
    if (pKey.isEmpty) return null;
    return pKey;
  }
}
