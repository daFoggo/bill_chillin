import 'package:equatable/equatable.dart';

class DebtEntity extends Equatable {
  final String fromUser;
  final String toUser;
  final double amount;

  const DebtEntity({
    required this.fromUser,
    required this.toUser,
    required this.amount,
  });

  @override
  List<Object?> get props => [fromUser, toUser, amount];
}
