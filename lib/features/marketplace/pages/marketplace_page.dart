import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/features/marketplace/blocs/market_bloc.dart';
import 'package:mescat/features/marketplace/widgets/market_list.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<MarketBloc>().add(const LoadMarketEvent());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstraints.mDefaultPadding),
        child: BlocBuilder<MarketBloc, MarketState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const LinearProgressIndicator();
            }
            return MarketList(items: state.nfts);
          },
        ),
      ),
    );
  }
}
