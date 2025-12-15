part of 'group_list_bloc.dart';

abstract class GroupListEvent extends Equatable {
  const GroupListEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupsEvent extends GroupListEvent {
  final String userId;
  const LoadGroupsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class CreateNewGroupEvent extends GroupListEvent {
  final GroupEntity group;
  const CreateNewGroupEvent({required this.group});

  @override
  List<Object> get props => [group];
}

class SearchGroupsEvent extends GroupListEvent {
  final String query;
  const SearchGroupsEvent({required this.query});

  @override
  List<Object> get props => [query];
}
