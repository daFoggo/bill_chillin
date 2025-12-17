import 'package:bill_chillin/core/error/failures.dart';
import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:bill_chillin/features/scan/domain/usecases/scan_receipt_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'scan_event.dart';
part 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanReceiptUseCase scanReceiptUseCase;

  ScanBloc({required this.scanReceiptUseCase}) : super(ScanInitial()) {
    on<ScanReceiptCaptured>(_onScanReceiptCaptured);
  }

  Future<void> _onScanReceiptCaptured(
    ScanReceiptCaptured event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    final result = await scanReceiptUseCase(
      ScanReceiptParams(imageBytes: event.imageBytes),
    );

    result.fold(
      (failure) => emit(ScanFailure(message: _mapFailureToMessage(failure))),
      (transactions) {
        if (transactions.isEmpty) {
          emit(
            const ScanFailure(
              message: 'No transactions detected from the image',
            ),
          );
        } else {
          emit(ScanSuccess(transactions: transactions));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Unexpected Error';
  }
}
