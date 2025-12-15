part of 'group_detail_bloc.dart';

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupDetailEvent extends GroupDetailEvent {
  final String groupId;

  const LoadGroupDetailEvent({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class AddGroupTransactionEvent extends GroupDetailEvent {
  final TransactionEntity transaction;

  const AddGroupTransactionEvent({required this.transaction});
}

class ShareGroupLinkEvent extends GroupDetailEvent {
  final String groupId;

  const ShareGroupLinkEvent({required this.groupId});
}

class UpdateGroupTransactionEvent extends GroupDetailEvent {
  final TransactionEntity transaction;

  const UpdateGroupTransactionEvent({required this.transaction});
}

class DeleteGroupTransactionEvent extends GroupDetailEvent {
  final String transactionId;
  final String groupId;

  const DeleteGroupTransactionEvent({
    required this.transactionId,
    required this.groupId,
  });
}

class UpdateGroupEvent extends GroupDetailEvent {
  final GroupEntity group;

  const UpdateGroupEvent({required this.group});
}

class DeleteGroupEvent extends GroupDetailEvent {
  final String groupId;

  const DeleteGroupEvent({required this.groupId});
}

class ResetGroupLinkEvent extends GroupDetailEvent {}
