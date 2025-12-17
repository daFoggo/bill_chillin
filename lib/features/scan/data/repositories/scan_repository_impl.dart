import 'package:bill_chillin/core/error/exceptions.dart';
import 'package:bill_chillin/core/error/failures.dart';
import 'package:bill_chillin/features/scan/data/datasources/scan_remote_data_source.dart';
import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:bill_chillin/features/scan/domain/repositories/scan_repository.dart';
import 'package:dartz/dartz.dart';
import 'dart:typed_data';

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource remoteDataSource;

  ScanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ScannedTransaction>>> scanReceipt(
    Uint8List imageBytes,
  ) async {
    try {
      final result = await remoteDataSource.scanReceipt(imageBytes);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
