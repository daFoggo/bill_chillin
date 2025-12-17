part of 'scan_bloc.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final List<ScannedTransaction> transactions;

  const ScanSuccess({required this.transactions});

  @override
  List<Object> get props => [transactions];
}

class ScanFailure extends ScanState {
  final String message;

  const ScanFailure({required this.message});

  @override
  List<Object> get props => [message];
}
