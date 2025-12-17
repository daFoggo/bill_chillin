import 'dart:typed_data';
import 'package:bill_chillin/core/error/failures.dart';
import 'package:bill_chillin/core/usecases/usecase.dart';
import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:bill_chillin/features/scan/domain/repositories/scan_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ScanReceiptUseCase
    implements UseCase<List<ScannedTransaction>, ScanReceiptParams> {
  final ScanRepository repository;

  ScanReceiptUseCase(this.repository);

  @override
  Future<Either<Failure, List<ScannedTransaction>>> call(
    ScanReceiptParams params,
  ) async {
    return await repository.scanReceipt(params.imageBytes);
  }
}

class ScanReceiptParams extends Equatable {
  final Uint8List imageBytes;

  const ScanReceiptParams({required this.imageBytes});

  @override
  List<Object?> get props => [imageBytes];
}
