import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/core/routes/routes.dart';

class MarketLayout extends StatelessWidget {
  const MarketLayout({super.key, required this.child});

  final Widget child;

  Widget _buildNavbar() {
    final navItems = const <Widget>[
      MarketNavItem(
        title: 'Marketplace',
        route: MescatRoutes.marketplace,
        iconData: Icons.store,
      ),
      MarketNavItem(
        title: 'Library',
        route: MescatRoutes.library,
        iconData: Icons.local_library,
      ),
      MarketNavItem(
        title: 'Wallet',
        route: MescatRoutes.wallet,
        iconData: Icons.person,
      ),
      MarketNavItem(
        title: 'Home',
        route: MescatRoutes.home,
        iconData: Icons.home,
      ),
    ];

    if (Platform.isAndroid || Platform.isIOS) {
      return BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems,
        ),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) => navItems[index],
      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
      itemCount: navItems.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isAndroid || Platform.isIOS
          ? child
          : _buildDesktop(context: context),
      bottomNavigationBar: Platform.isAndroid || Platform.isIOS
          ? _buildNavbar()
          : null,
    );
  }

  Widget _buildDesktop({required BuildContext context}) {
    return Row(
      children: [
        Container(
          width: 65,
          padding: const EdgeInsets.all(UIConstraints.mDefaultPadding),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: _buildNavbar(),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                ),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                bottomLeft: Radius.circular(12.0),
              ),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class MarketNavItem extends StatelessWidget {
  const MarketNavItem({
    super.key,
    required this.title,
    required this.route,
    required this.iconData,
  });

  final String title;
  final String route;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final active = GoRouterState.of(context).matchedLocation == route;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          width: 45,
          height: 45,
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            border: active
                ? Border.all(color: Theme.of(context).colorScheme.primary)
                : null,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            iconData,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
