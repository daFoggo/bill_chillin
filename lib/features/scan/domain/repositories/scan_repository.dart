import 'dart:typed_data';
import 'package:bill_chillin/core/error/failures.dart';
import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:dartz/dartz.dart';

abstract class ScanRepository {
  Future<Either<Failure, List<ScannedTransaction>>> scanReceipt(
    Uint8List imageBytes,
  );
}
