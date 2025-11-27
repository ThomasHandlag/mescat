import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<int> {
  AuthCubit() : super(0);

  void switchToLogin() => emit(0);

  void switchToRegister() => emit(1);
}