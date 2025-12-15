import 'package:bill_chillin/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInWithEmailPassword(
    String email,
    String password,
  );

  Future<Either<Failure, UserEntity>> signUpWithEmailPassword(
    String email,
    String password,
  );

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, List<UserEntity>>> getUsersByIds(List<String> userIds);
}
