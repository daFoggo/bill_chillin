part of 'scan_bloc.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object> get props => [];
}

class ScanReceiptCaptured extends ScanEvent {
  final Uint8List imageBytes;

  const ScanReceiptCaptured(this.imageBytes);

  @override
  List<Object> get props => [imageBytes];
}
