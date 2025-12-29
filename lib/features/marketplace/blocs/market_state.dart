part of 'market_bloc.dart';

final class MarketState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final List<NFT> nfts;

  const MarketState({
    this.isLoading = false,
    this.hasError = false,
    this.nfts = const [],
  });

  MarketState copyWith({bool? isLoading, bool? hasError, List<NFT>? nfts}) {
    return MarketState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      nfts: nfts ?? this.nfts,
    );
  }

  @override
  List<Object?> get props => [isLoading, hasError, nfts];
}
