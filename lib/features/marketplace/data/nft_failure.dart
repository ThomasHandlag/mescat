import 'package:mescat/core/errors/failures.dart';

class NftFailure extends Failure {
  const NftFailure(super.message);

  @override
  String toString() => 'NftException: $message';
}
