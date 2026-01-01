import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mescat/features/marketplace/pages/library_page.dart';

final class NftUsageItem {
  final ItemType itemType;
  final String path;

  const NftUsageItem({required this.itemType, required this.path});
}

class NftUsageCubit extends HydratedCubit<Map<ApplyType, NftUsageItem>> {
  NftUsageCubit(super.state);

  @override
  fromJson(Map<String, dynamic> json) {
    return json.map((key, value) {
      final applyType = ApplyType.values.firstWhere(
        (e) => e.toString() == key,
        orElse: () => ApplyType.none,
      );
      final itemType = ItemType.values.firstWhere(
        (e) => e.toString() == value['itemType'],
        orElse: () => ItemType.meta,
      );
      final path = value['path'] as String;
      return MapEntry(applyType, NftUsageItem(itemType: itemType, path: path));
    });
  }

  @override
  Map<String, dynamic>? toJson(state) {
    return state.map((key, value) {
      return MapEntry(key.toString(), {
        'itemType': value.itemType.toString(),
        'path': value.path,
      });
    });
  }

  void setNftUsage(ApplyType applyType, NftUsageItem item) {
    final newState = Map<ApplyType, NftUsageItem>.from(state);
    newState[applyType] = item;
    emit(newState);
  }

  void clearNftUsage(ApplyType applyType) {
    final newState = Map<ApplyType, NftUsageItem>.from(state);
    newState.remove(applyType);
    emit(newState);
  }
}
