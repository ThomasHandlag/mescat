import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mescat/contracts/abi/market.g.dart';
import 'package:mescat/contracts/abi/mescat.g.dart';
import 'package:mescat/contracts/abi/musicat.g.dart';
import 'package:mescat/contracts/contracts.dart';
import 'package:mescat/features/marketplace/data/nft.dart';
import 'package:mescat/features/marketplace/data/nft_failure.dart';
import 'package:web3dart/web3dart.dart';

class MarketRealm {
  final Market market;
  final Mescat mescat;
  final Musicat musicat;
  final Web3Client web3Client;

  MarketRealm({required this.web3Client})
    : market = Market(
        address: EthereumAddress.fromHex(MescatContracts.market),
        client: web3Client,
      ),
      musicat = Musicat(
        address: EthereumAddress.fromHex(MescatContracts.musicat),
        client: web3Client,
      ),
      mescat = Mescat(
        address: EthereumAddress.fromHex(MescatContracts.mescat),
        client: web3Client,
      );

  Future<Either<NftFailure, List<NFT>>> getItems() async {
    try {
      final items = <NFT>[];

      final rawItems = await market.getAllAssets((
        tokenAddress: EthereumAddress.fromHex(MescatContracts.musicat),
      ));

      rawItems.ids.asMap().forEach((index, id) {
        if (rawItems.isForSales[index]) {
          items.add(
            NFT(
              id: id,
              owner: rawItems.owners[index].hex,
              tokenId: rawItems.tokenIds[index].toInt().toString(),
              bigPrice: rawItems.prices[index],
            ),
          );
        }
      });

      return Right(items);
    } catch (e) {
      return Left(NftFailure('Failed to fetch items: $e'));
    }
  }

  Future<Either<NftFailure, String>> buyNft(NFT nft, String key) async {
    try {
      final accountEth = await web3Client.getBalance(
        EthPrivateKey.fromHex(key).address,
      );
      final nftPrice = EtherAmount.fromBigInt(EtherUnit.wei, nft.bigPrice);
      log(
        'value compare ${accountEth.getValueInUnit(EtherUnit.ether)} < ${nftPrice.getValueInUnit(EtherUnit.ether)}',
      );

      log(key);

      final result = await market.buyAsset(
        (id: nft.id),
        credentials: EthPrivateKey.fromHex(key),
        transaction: Transaction(
          from: EthPrivateKey.fromHex(key).address,
          value: EtherAmount.fromBigInt(EtherUnit.wei, nft.bigPrice),
        ),
      );

      return Right(result);
    } catch (e) {
      return Left(NftFailure('Failed to buy NFT: $e'));
    }
  }

  Future<Either<NftFailure, List<NFT>>> ownedNFT(String key) async {
    try {
      final rs = await musicat.getAssetOwnedBySender(
        (sender: EthPrivateKey.fromHex(key).address),
        // (sender: EthereumAddress.fromHex(marketAddress)),
      );

      final tokens = <NFT>[];

      await Future.forEach(rs, (id) async {
        final musicTokenURI = await musicat.tokenURI((tokenId: id));

        tokens.add(NFT(
          id: id,
          owner: EthPrivateKey.fromHex(key).address.hex,
          tokenId: musicTokenURI,
          bigPrice: EtherAmount.zero().getInWei,
        ));
      });

      return Right(tokens);
    } catch (e) {
      return Left(NftFailure('Failed to list NFT: $e'));
    }
  }

  Future<Either<NftFailure, bool>> burn(BigInt id, String key) async {
    try {
      await musicat.burnAsset((
        tokenId: id,
      ), credentials: EthPrivateKey.fromHex(key));
      return right(true);
    } catch (e) {
      return left(const NftFailure('Failed to burn asset'));
    }
  }
}
