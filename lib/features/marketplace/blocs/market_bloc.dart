import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/marketplace/data/market_realm.dart';
import 'package:mescat/features/marketplace/data/nft.dart';

part 'market_event.dart';
part 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final MarketRealm _marketRealm;

  MarketBloc(this._marketRealm) : super(const MarketState()) {
    on<MarketEvent>((event, emit) {});
    on<LoadMarketEvent>(_onLoadMarket);
    on<BuyNftEvent>(_onBuyNft);
  }

  Future<void> _onLoadMarket(
    LoadMarketEvent event,
    Emitter<MarketState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _marketRealm.getItems();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, hasError: true));
      },
      (nfts) {
        emit(state.copyWith(isLoading: false, hasError: false, nfts: nfts));
      },
    );
  }

  Future<void> _onBuyNft(
    BuyNftEvent event,
    Emitter<MarketState> emit,
  ) async {
    // Implement NFT purchase logic here
  }
}
