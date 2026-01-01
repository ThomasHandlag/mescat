import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingCubit extends HydratedCubit<SettingState> {
  SettingCubit() : super(const SettingState());

  void setThemeMode(MescatThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  void setLanguageCode(String code) {
    emit(state.copyWith(languageCode: code));
  }

  void setNotificationSound(String sound) {
    emit(state.copyWith(notificationSound: sound));
  }

  @override
  SettingState fromJson(Map<String, dynamic> json) {
    return SettingState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SettingState state) {
    return state.toMap();
  }
}

enum MescatThemeMode { system, light, dark }

class SettingState extends Equatable {
  final MescatThemeMode themeMode;
  final String languageCode;
  final String notificationSound;

  const SettingState({
    this.themeMode = MescatThemeMode.system,
    this.languageCode = 'en',
    this.notificationSound = '',
  });

  @override
  List<Object?> get props => [themeMode, languageCode];

  SettingState copyWith({
    MescatThemeMode? themeMode,
    String? languageCode,
    String? notificationSound,
  }) {
    return SettingState(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'languageCode': languageCode,
      'notificationSound': notificationSound,
    };
  }

  factory SettingState.fromMap(Map<String, dynamic> map) {
    return SettingState(
      themeMode: MescatThemeMode.values[map['themeMode'] ?? 0],
      languageCode: map['languageCode'] ?? 'en',
      notificationSound: map['notificationSound'] ?? '',
    );
  }
}
