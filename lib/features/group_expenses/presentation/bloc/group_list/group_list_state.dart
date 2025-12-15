part of 'group_list_bloc.dart';

abstract class GroupListState extends Equatable {
  const GroupListState();

  @override
  List<Object> get props => [];
}

class GroupListInitial extends GroupListState {}

class GroupListLoading extends GroupListState {}

class GroupListLoaded extends GroupListState {
  final List<GroupEntity> groups;
  const GroupListLoaded({required this.groups});

  @override
  List<Object> get props => [groups];
}

class GroupListError extends GroupListState {
  final String message;
  const GroupListError({required this.message});

  @override
  List<Object> get props => [message];
}
