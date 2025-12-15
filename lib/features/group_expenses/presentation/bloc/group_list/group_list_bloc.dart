import 'package:bill_chillin/core/util/string_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/usecases/create_group_usecase.dart';
import '../../../domain/repositories/group_repository.dart';

part 'group_list_event.dart';
part 'group_list_state.dart';

class GroupListBloc extends Bloc<GroupListEvent, GroupListState> {
  final GroupRepository repository;
  final CreateGroupUseCase createGroupUseCase;

  List<GroupEntity> _allGroups = [];

  GroupListBloc({required this.repository, required this.createGroupUseCase})
    : super(GroupListInitial()) {
    on<LoadGroupsEvent>(_onLoadGroups);
    on<CreateNewGroupEvent>(_onCreateGroup);
    on<SearchGroupsEvent>(_onSearchGroups);
  }

  Future<void> _onLoadGroups(
    LoadGroupsEvent event,
    Emitter<GroupListState> emit,
  ) async {
    emit(GroupListLoading());
    final result = await repository.getGroups(event.userId);
    result.fold(
      (failure) => emit(GroupListError(message: failure.toString())),
      (groups) {
        _allGroups = groups;
        emit(GroupListLoaded(groups: groups));
      },
    );
  }

  Future<void> _onCreateGroup(
    CreateNewGroupEvent event,
    Emitter<GroupListState> emit,
  ) async {
    final result = await createGroupUseCase(
      CreateGroupParams(group: event.group),
    );
    result.fold(
      (failure) => emit(GroupListError(message: failure.toString())),
      (_) {
        add(LoadGroupsEvent(userId: event.group.members.first));
      },
    );
  }

  void _onSearchGroups(SearchGroupsEvent event, Emitter<GroupListState> emit) {
    if (state is! GroupListLoaded) return;
    final query = StringUtils.removeAccents(event.query.toLowerCase()).trim();
    if (query.isEmpty) {
      emit(GroupListLoaded(groups: _allGroups));
    } else {
      final queryWords = query.split(' ');
      final filtered = _allGroups.where((group) {
        if (group.searchKeywords.isEmpty) {
          return StringUtils.removeAccents(
            group.name.toLowerCase(),
          ).contains(query);
        }

        return queryWords.every((qWord) {
          if (qWord.isEmpty) return true;
          return group.searchKeywords.any((keyword) {
            return keyword.contains(qWord);
          });
        });
      }).toList();
      emit(GroupListLoaded(groups: filtered));
    }
  }
}
