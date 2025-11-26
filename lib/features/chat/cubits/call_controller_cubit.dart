import 'package:flutter_bloc/flutter_bloc.dart';

final class CallControllerCubit extends Cubit<bool> {
  CallControllerCubit() : super(true);

  void toggleVisibility() => emit(!state);

  void show() => emit(true);
  void hide() => emit(false);
}