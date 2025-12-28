import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/features/marketplace/data/nft.dart';
import 'package:mescat/features/marketplace/widgets/market_item.dart';

class MarketList extends StatelessWidget {
  const MarketList({super.key, required this.items});

  final List<NFT> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemBuilder: (context, index) {
        final nft = items[index];
        return MarketItem(nft: nft);
      },
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Platform.isAndroid || Platform.isIOS ? 1 : 4,
        mainAxisSpacing: UIConstraints.mDefaultPadding,
        crossAxisSpacing: UIConstraints.mDefaultPadding,
      ),
    );
  }
}
