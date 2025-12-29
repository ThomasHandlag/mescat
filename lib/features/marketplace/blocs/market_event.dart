part of 'market_bloc.dart';

abstract class MarketEvent {
  const MarketEvent();
}

final class LoadMarketEvent extends MarketEvent {
  const LoadMarketEvent();
}

final class BuyNftEvent extends MarketEvent {
  final NFT nft;

  const BuyNftEvent(this.nft);
}
