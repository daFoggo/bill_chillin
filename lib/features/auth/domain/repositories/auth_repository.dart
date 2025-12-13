import 'package:bill_chillin/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmailPassword(
    String email,
    String password,
  );

  Future<Either<Failure, UserEntity>> signUpWithEmailPassword(
    String email,
    String password,
  );

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getCurrentUser();
}
