import 'package:dartz/dartz.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/domain/repositories/mescat_repository.dart';

part 'mc_message_usecases.dart';
part 'mc_room_usecases.dart';
part 'mc_space_usecases.dart';
part 'mc_user_usecases.dart';
part 'mc_auth_usecases.dart';
part 'mc_notification_usecases.dart';
part 'mc_push_notification_usecases.dart';

/// Use case for setting user presence
class SetPresenceUseCase {
  final MCRepository repository;

  SetPresenceUseCase(this.repository);

  Future<Either<MCFailure, bool>> call(UserPresence presence) async {
    return await repository.setPresence(presence);
  }
}

/// Use case for sending typing indicators
class SendTypingIndicatorUseCase {
  final MCRepository repository;

  SendTypingIndicatorUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String roomId,
    required bool isTyping,
  }) async {
    return await repository.sendTypingIndicator(roomId, isTyping);
  }
}

