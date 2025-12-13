import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.loginWithEmailPassword(
        email,
        password,
      );
      return Right(userModel);
    } on ServerException {
      return const Left(ServerFailure('Lỗi đăng nhập hoặc mật khẩu sai'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmailPassword(
        email,
        password,
      );
      return Right(userModel);
    } on ServerException {
      return const Left(ServerFailure('Không thể tạo tài khoản'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure('Lỗi đăng xuất'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        return Right(user);
      }
      return const Left(ServerFailure('Chưa đăng nhập'));
    } on ServerException {
      return const Left(ServerFailure('Lỗi server'));
    }
  }
}
