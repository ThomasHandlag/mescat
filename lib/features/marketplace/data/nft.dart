import 'package:equatable/equatable.dart';
import 'package:web3dart/web3dart.dart';

class NFT extends Equatable {
  final BigInt id;
  final String owner;
  final String tokenId;
  final BigInt _bigPrice;

  double get price => EtherAmount.fromBigInt(
    EtherUnit.wei,
    _bigPrice,
  ).getValueInUnit(EtherUnit.ether);

  BigInt get bigPrice => _bigPrice;

  const NFT({
    required this.id,
    required this.owner,
    required this.tokenId,
    required BigInt bigPrice,
  }) : _bigPrice = bigPrice;

  @override
  List<Object?> get props => [id, owner, tokenId, _bigPrice];
}
