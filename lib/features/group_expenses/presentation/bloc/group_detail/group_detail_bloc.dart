import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../personal_expenses/domain/entities/transaction_entity.dart';
import '../../../domain/entities/debt_entity.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../domain/usecases/add_group_transaction_usecase.dart';
import '../../../domain/usecases/calculate_group_debts.dart';
import '../../../domain/usecases/delete_group_transaction_usecase.dart';
import '../../../domain/usecases/delete_group_usecase.dart';
import '../../../domain/usecases/generate_invite_link_usecase.dart';
import '../../../domain/usecases/update_group_transaction_usecase.dart';
import '../../../domain/usecases/update_group_usecase.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../domain/usecases/get_group_member_details_usecase.dart';

part 'group_detail_event.dart';
part 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GroupRepository repository;
  final CalculateGroupDebtsUseCase calculateGroupDebtsUseCase;
  final GenerateInviteLinkUseCase generateInviteLinkUseCase;

  final AddGroupTransactionUseCase addGroupTransactionUseCase;
  final UpdateGroupUseCase updateGroupUseCase;
  final DeleteGroupUseCase deleteGroupUseCase;
  final UpdateGroupTransactionUseCase updateGroupTransactionUseCase;
  final DeleteGroupTransactionUseCase deleteGroupTransactionUseCase;
  final GetGroupMemberDetailsUseCase getGroupMemberDetailsUseCase;

  GroupDetailBloc({
    required this.repository,
    required this.calculateGroupDebtsUseCase,
    required this.generateInviteLinkUseCase,
    required this.addGroupTransactionUseCase,
    required this.updateGroupUseCase,
    required this.deleteGroupUseCase,
    required this.updateGroupTransactionUseCase,
    required this.deleteGroupTransactionUseCase,
    required this.getGroupMemberDetailsUseCase,
  }) : super(GroupDetailInitial()) {
    on<LoadGroupDetailEvent>(_onLoadGroupDetail);
    on<ShareGroupLinkEvent>(_onShareGroupLink);
    on<AddGroupTransactionEvent>(_onAddGroupTransaction);
    on<UpdateGroupTransactionEvent>(_onUpdateGroupTransaction);
    on<DeleteGroupTransactionEvent>(_onDeleteGroupTransaction);
    on<UpdateGroupEvent>(_onUpdateGroup);
    on<DeleteGroupEvent>(_onDeleteGroup);
    on<ResetGroupLinkEvent>(_onResetGroupLink);
  }

  void _onResetGroupLink(
    ResetGroupLinkEvent event,
    Emitter<GroupDetailState> emit,
  ) {
    if (state is GroupDetailLoaded) {
      final currentState = state as GroupDetailLoaded;
      emit(currentState.copyWith(clearShareLink: true));
    }
  }

  Future<void> _onUpdateGroupTransaction(
    UpdateGroupTransactionEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    if (state is GroupDetailLoaded) {
      final currentState = state as GroupDetailLoaded;
      final result = await updateGroupTransactionUseCase(
        UpdateGroupTransactionParams(
          groupId: currentState.group.id,
          transaction: event.transaction,
        ),
      );

      result.fold(
        (failure) => emit(GroupDetailError(message: failure.toString())),
        (_) => add(LoadGroupDetailEvent(groupId: currentState.group.id)),
      );
    }
  }

  Future<void> _onDeleteGroupTransaction(
    DeleteGroupTransactionEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    final result = await deleteGroupTransactionUseCase(
      DeleteGroupTransactionParams(
        groupId: event.groupId,
        transactionId: event.transactionId,
      ),
    );

    result.fold(
      (failure) => emit(GroupDetailError(message: failure.toString())),
      (_) => add(LoadGroupDetailEvent(groupId: event.groupId)),
    );
  }

  Future<void> _onUpdateGroup(
    UpdateGroupEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    final result = await updateGroupUseCase(event.group);
    result.fold(
      (failure) => emit(GroupDetailError(message: failure.toString())),
      (_) => add(LoadGroupDetailEvent(groupId: event.group.id)),
    );
  }

  Future<void> _onDeleteGroup(
    DeleteGroupEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    final result = await deleteGroupUseCase(event.groupId);
    result.fold(
      (failure) => emit(GroupDetailError(message: failure.toString())),
      (_) {
        emit(GroupDetailInitial());
      },
    );
  }

  Future<void> _onAddGroupTransaction(
    AddGroupTransactionEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    if (state is GroupDetailLoaded) {
      final currentState = state as GroupDetailLoaded;
      final result = await addGroupTransactionUseCase(
        AddGroupTransactionParams(
          groupId: currentState.group.id,
          transaction: event.transaction,
        ),
      );

      result.fold(
        (failure) => emit(GroupDetailError(message: failure.toString())),
        (_) {
          add(LoadGroupDetailEvent(groupId: currentState.group.id));
        },
      );
    }
  }

  Future<void> _onLoadGroupDetail(
    LoadGroupDetailEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    emit(GroupDetailLoading());

    // 1. Fetch Group Details
    final groupResult = await repository.getGroupDetails(event.groupId);

    // 2. Fetch Group Transactions
    final transactionsResult = await repository.getGroupTransactions(
      event.groupId,
    );

    // Combine results
    await groupResult.fold(
      (failure) async => emit(GroupDetailError(message: failure.toString())),
      (group) async {
        await transactionsResult.fold(
          (failure) async =>
              emit(GroupDetailError(message: failure.toString())),
          (transactions) async {
            // 3. Fetch Member Details
            final membersResult = await getGroupMemberDetailsUseCase(
              group.members,
            );
            Map<String, UserEntity> memberDetails = {};

            membersResult.fold(
              (failure) {
                emit(GroupDetailError(message: failure.toString()));
              },
              (users) {
                memberDetails = {for (var u in users) u.id: u};
              },
            );

            // 4. Calculate Debts
            final debts = calculateGroupDebtsUseCase(transactions);

            // 5. Calculate Total Expense (Naive sum of all transaction amounts, excluding settlements)
            final totalExpense = transactions
                .where((tx) => tx.type != 'settlement')
                .fold(0.0, (sum, tx) => sum + tx.amount);

            emit(
              GroupDetailLoaded(
                group: group,
                transactions: transactions,
                debts: debts,
                totalExpense: totalExpense,
                memberDetails: memberDetails,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onShareGroupLink(
    ShareGroupLinkEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    final result = await generateInviteLinkUseCase(event.groupId);
    result.fold((failure) => null, (link) {
      if (state is GroupDetailLoaded) {
        final currentState = state as GroupDetailLoaded;
        emit(currentState.copyWith(shareLink: link));
      }
    });
  }
}
