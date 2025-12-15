import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/features/group_expenses/domain/entities/group_entity.dart';
import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_detail/group_detail_bloc.dart';
import 'package:bill_chillin/features/group_expenses/presentation/widgets/group_stats_tab.dart';
import 'package:bill_chillin/features/group_expenses/presentation/widgets/group_transactions_tab.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/transaction_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) =>
          sl<GroupDetailBloc>()
            ..add(LoadGroupDetailEvent(groupId: widget.groupId)),
      child: BlocListener<GroupDetailBloc, GroupDetailState>(
        listener: (context, state) {
          if (state is GroupDetailLoaded && state.shareLink != null) {
            final bloc = context.read<GroupDetailBloc>();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Invite to Group"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Share this link with others to join:"),
                    const SizedBox(height: 16),
                    SelectableText(
                      state.shareLink!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Close"),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: state.shareLink!));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Link copied to clipboard!"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy"),
                  ),
                ],
              ),
            ).then((_) {
              bloc.add(ResetGroupLinkEvent());
            });
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: BlocBuilder<GroupDetailBloc, GroupDetailState>(
                builder: (context, state) {
                  if (state is GroupDetailLoaded) {
                    return Text(state.group.name);
                  }
                  return Text(widget.groupName);
                },
              ),
              actions: [
                BlocBuilder<GroupDetailBloc, GroupDetailState>(
                  builder: (context, state) {
                    return PopupMenuButton<String>(
                      onSelected: (value) {
                        final bloc = context.read<GroupDetailBloc>();
                        if (value == 'share') {
                          bloc.add(
                            ShareGroupLinkEvent(groupId: widget.groupId),
                          );
                        } else if (value == 'edit') {
                          if (state is GroupDetailLoaded) {
                            _showEditGroupSheet(context, state.group);
                          }
                        } else if (value == 'delete') {
                          _showDeleteConfirmDialog(context, bloc);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share, size: 20),
                                SizedBox(width: 12),
                                Text('Share Link'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 12),
                                Text('Edit Group'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Delete Group',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    );
                  },
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Transactions"),
                  Tab(text: "Stats & Debts"),
                ],
              ),
            ),
            body: BlocBuilder<GroupDetailBloc, GroupDetailState>(
              builder: (context, state) {
                if (state is GroupDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GroupDetailError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is GroupDetailLoaded) {
                  return TabBarView(
                    children: [
                      GroupTransactionsTab(state: state),
                      GroupStatsTab(state: state),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            floatingActionButton:
                BlocBuilder<GroupDetailBloc, GroupDetailState>(
                  builder: (context, state) {
                    if (state is GroupDetailLoaded) {
                      return FloatingActionButton.extended(
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (bottomSheetContext) {
                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (_) => sl<CategoryBloc>(),
                                  ),
                                ],
                                child: TransactionBottomSheet(
                                  userId: user.uid,
                                  group: state.group,
                                  onSave: (transaction) {
                                    context.read<GroupDetailBloc>().add(
                                      AddGroupTransactionEvent(
                                        transaction: transaction,
                                      ),
                                    );
                                    Navigator.pop(bottomSheetContext);
                                  },
                                ),
                              );
                            },
                          );
                        },
                        label: const Text("Add Expense"),
                        icon: const Icon(Icons.add),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, GroupDetailBloc bloc) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Group"),
        content: const Text(
          "Are you sure you want to delete this group? keep in mind that this action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeleteGroupEvent(groupId: widget.groupId));
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showEditGroupSheet(BuildContext context, GroupEntity group) {
    final nameController = TextEditingController(text: group.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Edit Group",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                hintText: "Enter new group name",
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final updatedGroup = group.copyWith(
                    name: nameController.text.trim(),
                  );
                  context.read<GroupDetailBloc>().add(
                    UpdateGroupEvent(group: updatedGroup),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Save Changes"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
