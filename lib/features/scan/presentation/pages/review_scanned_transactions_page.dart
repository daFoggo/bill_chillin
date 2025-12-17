import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/features/group_expenses/domain/entities/group_entity.dart';
import 'package:bill_chillin/features/group_expenses/domain/repositories/group_repository.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/add_group_transaction_usecase.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/get_group_member_details_usecase.dart';
import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_list/group_list_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:bill_chillin/features/personal_expenses/domain/repositories/personal_expenses_repository.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/transaction_bottom_sheet.dart';
import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:bill_chillin/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum ScanTargetMode { personal, group }

class ReviewScannedTransactionsPage extends StatefulWidget {
  final List<ScannedTransaction> scannedTransactions;
  final String? initialGroupId;
  final Map<String, String> groupMembers; // memberId -> memberName

  const ReviewScannedTransactionsPage({
    super.key,
    this.scannedTransactions = const [],
    this.initialGroupId,
    this.groupMembers = const {},
  });

  @override
  State<ReviewScannedTransactionsPage> createState() =>
      _ReviewScannedTransactionsPageState();
}

class _ReviewScannedTransactionsPageState
    extends State<ReviewScannedTransactionsPage> {
  ScanTargetMode _mode = ScanTargetMode.personal;
  String? _selectedGroupId;
  final Set<String> _selectedMembers = {};
  String? _selectedPayerId; // Người trả tiền
  Map<String, UserEntity> _memberDetails = {}; // memberId -> UserEntity
  GroupEntity? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.initialGroupId;
    if (widget.groupMembers.isNotEmpty) {
      // Nếu có members từ widget, convert sang UserEntity map
      _memberDetails = {
        for (var entry in widget.groupMembers.entries)
          entry.key: UserEntity(
            id: entry.key,
            email: entry.value,
            name: entry.value,
          ),
      };
    }
    // Nếu có initialGroupId nhưng chưa có members, load sau khi widget build xong
    if (widget.initialGroupId != null && widget.groupMembers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadGroupMembers(widget.initialGroupId!);
      });
    }
  }

  Future<void> _loadGroupMembers(String groupId) async {
    final groupRepo = sl<GroupRepository>();
    final getMemberDetails = sl<GetGroupMemberDetailsUseCase>();

    // Load group details để lấy members list
    final groupResult = await groupRepo.getGroupDetails(groupId);
    groupResult.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load group: ${failure.toString()}'),
            ),
          );
        }
      },
      (group) async {
        setState(() {
          _selectedGroup = group;
        });

        // Load member details
        final membersResult = await getMemberDetails(group.members);
        membersResult.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to load members: ${failure.toString()}',
                  ),
                ),
              );
            }
          },
          (users) {
            if (mounted) {
              setState(() {
                _memberDetails = {for (var u in users) u.id: u};
                // Reset selections khi đổi group
                _selectedMembers.clear();
                _selectedPayerId = null;
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review scanned transactions'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<ScanTargetMode>(
              segments: const [
                ButtonSegment(
                  value: ScanTargetMode.personal,
                  icon: Icon(Icons.person),
                  label: Text('Personal'),
                ),
                ButtonSegment(
                  value: ScanTargetMode.group,
                  icon: Icon(Icons.groups_3),
                  label: Text('Group'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (value) {
                setState(() {
                  _mode = value.first;
                });
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mode == ScanTargetMode.personal
                  ? 'Review personal transactions'
                  : 'Review group transactions',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Detected items: ${widget.scannedTransactions.length}',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 16),
            if (_mode == ScanTargetMode.group) ...[
              BlocProvider(
                create: (context) {
                  final bloc = sl<GroupListBloc>();
                  if (user != null) {
                    bloc.add(LoadGroupsEvent(userId: user.uid));
                  }
                  return bloc;
                },
                child: _buildGroupSelectors(theme),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: widget.scannedTransactions.isEmpty
                  ? Center(
                      child: Text(
                        'No scanned transactions to review.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: widget.scannedTransactions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = widget.scannedTransactions[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Amount: ${item.amount.toStringAsFixed(2)} • Date: ${DateFormat('yyyy-MM-dd').format(item.date.toLocal())}',
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => _onSave(context),
            child: Text(
              _mode == ScanTargetMode.personal
                  ? 'Save to personal'
                  : 'Save to group',
            ),
          ),
        ),
      ),
    );
  }

  void _onSave(BuildContext context) {
    if (widget.scannedTransactions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No scanned items to save')));
      return;
    }

    if (_mode == ScanTargetMode.personal) {
      _saveToPersonal(context);
    } else {
      _saveToGroup(context);
    }
  }

  void _saveToPersonal(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to save data')),
      );
      return;
    }

    final userId = authState.user.id;
    final now = DateTime.now();
    final repo = sl<PersonalExpensesRepository>();

    Future<void> openSheetFor(ScannedTransaction scanned) async {
      final draft = TransactionEntity(
        id: '', // Firestore will generate the ID
        userId: userId,
        amount: scanned.amount,
        currency: 'VND',
        type: 'expense',
        date: scanned.date,
        categoryId: 'uncategorized',
        categoryName: scanned.category.isNotEmpty
            ? scanned.category
            : 'Unclassified',
        categoryIcon: '',
        note: scanned.description,
        searchKeywords: const [],
        status: 'draft',
        imageUrl: null,
        createdAt: now,
        updatedAt: null,
        groupId: null,
        groupName: null,
        payerId: null,
        participants: null,
        splitDetails: null,
      );

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) {
          return BlocProvider<CategoryBloc>(
            create: (_) => sl<CategoryBloc>(),
            child: TransactionBottomSheet(
              userId: userId,
              transaction: draft,
              onSave: (tx) async {
                await repo.addTransaction(tx);
                Navigator.pop(sheetContext);
              },
            ),
          );
        },
      );
    }

    // Mở bottom sheet lần lượt cho từng giao dịch AI trả về
    Future<void> run() async {
      for (final s in widget.scannedTransactions) {
        await openSheetFor(s);
      }
    }

    run().then((_) => Navigator.pop(context));
  }

  void _saveToGroup(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to save data')),
      );
      return;
    }

    if (_selectedGroupId == null || _selectedGroupId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a group')));
      return;
    }

    if (_selectedPayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select who paid for this transaction'),
        ),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one member to split'),
        ),
      );
      return;
    }

    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group information is not loaded')),
      );
      return;
    }

    final now = DateTime.now();
    final addGroupTransaction = sl<AddGroupTransactionUseCase>();

    // Tính splitDetails mặc định từ selected members
    final evenSplitter = _EvenSplitHelper(members: _selectedMembers.toList());

    Future<void> openSheetFor(ScannedTransaction scanned) async {
      // Tính splitDetails mặc định cho transaction này
      final defaultSplitDetails = evenSplitter.split(scanned.amount);

      final draft = TransactionEntity(
        id: '', // Firestore will generate the ID
        userId: user.uid,
        amount: scanned.amount,
        currency: 'VND',
        type: 'expense',
        date: scanned.date,
        categoryId: 'uncategorized',
        categoryName: scanned.category.isNotEmpty
            ? scanned.category
            : 'Unclassified',
        categoryIcon: '',
        note: scanned.description,
        searchKeywords: const [],
        status: 'draft',
        imageUrl: null,
        createdAt: now,
        updatedAt: null,
        groupId: _selectedGroupId,
        groupName: _selectedGroup?.name,
        payerId: _selectedPayerId ?? user.uid,
        participants: _selectedMembers.toList(),
        splitDetails: defaultSplitDetails,
      );

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) {
          return BlocProvider<CategoryBloc>(
            create: (_) => sl<CategoryBloc>(),
            child: TransactionBottomSheet(
              userId: user.uid,
              transaction: draft,
              group: _selectedGroup,
              memberDetails: _memberDetails,
              onSave: (tx) {
                // Không dùng async ở đây, dùng .then() để xử lý
                debugPrint('onSave called with transaction:');
                debugPrint('  - id: ${tx.id} (isEmpty: ${tx.id.isEmpty})');
                debugPrint('  - groupId: ${tx.groupId}');
                debugPrint('  - payerId: ${tx.payerId}');
                debugPrint('  - participants: ${tx.participants}');
                debugPrint('  - splitDetails: ${tx.splitDetails}');
                debugPrint('  - amount: ${tx.amount}');
                debugPrint('  - status: ${tx.status}');

                // Validate transaction trước khi save
                if (tx.groupId == null || tx.groupId!.isEmpty) {
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Group ID is missing'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                if (tx.payerId == null || tx.payerId!.isEmpty) {
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Payer ID is missing'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                if (tx.participants == null || tx.participants!.isEmpty) {
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Participants list is empty'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                // Validate splitDetails
                if (tx.splitDetails == null || tx.splitDetails!.isEmpty) {
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Split details are missing'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                // Validate amount > 0
                if (tx.amount <= 0) {
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Amount must be greater than 0'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                // Gọi use case để save (async)
                addGroupTransaction(
                      AddGroupTransactionParams(
                        groupId: _selectedGroupId!,
                        transaction: tx,
                      ),
                    )
                    .then((result) {
                      result.fold(
                        (failure) {
                          // Lỗi từ repository
                          debugPrint('Save failed: ${failure.toString()}');
                          if (sheetContext.mounted) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to save: ${failure.toString()}',
                                ),
                                backgroundColor: Theme.of(
                                  sheetContext,
                                ).colorScheme.error,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        (_) {
                          // Save thành công, đóng bottom sheet
                          debugPrint('Save successful, closing sheet');
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(
                                content: Text('Transaction saved successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    })
                    .catchError((error, stackTrace) {
                      // Catch bất kỳ exception nào không được handle
                      debugPrint('Error saving group transaction: $error');
                      debugPrint('Stack trace: $stackTrace');
                      if (sheetContext.mounted) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Unexpected error: ${error.toString()}',
                            ),
                            backgroundColor: Theme.of(
                              sheetContext,
                            ).colorScheme.error,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    });
              },
            ),
          );
        },
      );
    }

    // Mở bottom sheet lần lượt cho từng giao dịch AI trả về
    Future<void> run() async {
      for (final s in widget.scannedTransactions) {
        await openSheetFor(s);
      }
    }

    run().then((_) => Navigator.pop(context));
  }

  Widget _buildGroupSelectors(ThemeData theme) {
    return BlocBuilder<GroupListBloc, GroupListState>(
      builder: (context, state) {
        if (state is GroupListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GroupListError) {
          return Text(
            'Error loading groups: ${state.message}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          );
        }

        final groups = state is GroupListLoaded
            ? state.groups
            : <GroupEntity>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Selection Dropdown
            Text('Select Group', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedGroupId,
              decoration: const InputDecoration(
                labelText: 'Group',
                hintText: 'Choose a group',
                border: OutlineInputBorder(),
              ),
              items: groups.map((group) {
                return DropdownMenuItem<String>(
                  value: group.id,
                  child: Text(group.name),
                );
              }).toList(),
              onChanged: (groupId) {
                if (groupId != null) {
                  setState(() {
                    _selectedGroupId = groupId;
                    _selectedGroup = groups.firstWhere((g) => g.id == groupId);
                    _selectedMembers.clear();
                    _selectedPayerId = null;
                    _memberDetails.clear();
                  });
                  _loadGroupMembers(groupId);
                }
              },
            ),
            const SizedBox(height: 16),

            // Members Selection (chỉ hiện khi đã chọn group và có members)
            if (_selectedGroupId != null && _memberDetails.isNotEmpty) ...[
              Text(
                'Select Payer (Who paid for this)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _memberDetails.entries.map((entry) {
                  final memberId = entry.key;
                  final user = entry.value;
                  final isPayer = _selectedPayerId == memberId;
                  return FilterChip(
                    label: Text(user.name ?? user.email),
                    selected: isPayer,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPayerId = selected ? memberId : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Members to Split Evenly',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _memberDetails.entries.map((entry) {
                  final memberId = entry.key;
                  final user = entry.value;
                  final isSelected = _selectedMembers.contains(memberId);
                  return FilterChip(
                    label: Text(user.name ?? user.email),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMembers.add(memberId);
                        } else {
                          _selectedMembers.remove(memberId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ] else if (_selectedGroupId != null && _memberDetails.isEmpty) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              Text('Loading members...', style: theme.textTheme.bodySmall),
            ] else if (_selectedGroupId == null) ...[
              Text(
                'Please select a group first',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _EvenSplitHelper {
  final List<String> members;

  _EvenSplitHelper({required this.members});

  Map<String, double> split(double amount) {
    if (members.isEmpty) return {};
    final share = amount / members.length;
    return {for (final m in members) m: share};
  }
}
