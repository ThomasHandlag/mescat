import 'dart:async';

import 'package:flutter/widgets.dart';

final class StreamRouting extends ChangeNotifier {
  late final List<StreamSubscription> subscriptions;

  StreamRouting(List<Stream> streams) {
    subscriptions = [];
    for (var e in streams) {
      var s = e.asBroadcastStream().listen(_tt);
      subscriptions.add(s);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _tt(event) => notifyListeners();
}
