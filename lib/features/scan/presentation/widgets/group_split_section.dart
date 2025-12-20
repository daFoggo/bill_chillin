import 'package:bill_chillin/features/auth/domain/entities/user_entity.dart';
import 'package:bill_chillin/features/group_expenses/domain/entities/group_entity.dart';
import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_list/group_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupSplitSection extends StatelessWidget {
  final GroupEntity? selectedGroup;
  final String? selectedPayerId;
  final Set<String> selectedMembers;
  final Map<String, UserEntity> memberDetails;
  final VoidCallback onGroupDropdownTap;
  final ValueChanged<String> onPayerSelected;
  final Function(String memberId, bool selected) onMemberToggle;

  const GroupSplitSection({
    super.key,
    required this.selectedGroup,
    required this.selectedPayerId,
    required this.selectedMembers,
    required this.memberDetails,
    required this.onGroupDropdownTap,
    required this.onPayerSelected,
    required this.onMemberToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<GroupListBloc, GroupListState>(
      builder: (context, state) {
        List<GroupEntity> groups = [];
        if (state is GroupListLoaded) {
          groups = state.groups;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                if (groups.isNotEmpty) {
                  onGroupDropdownTap();
                } else if (state is GroupListLoading) {
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No groups found')),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Selected Group',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.groups_3_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  selectedGroup?.name ?? 'Select a group',
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (selectedGroup != null) ...[
              Text('Paid By', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              if (memberDetails.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: memberDetails.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final memberId = memberDetails.keys.elementAt(index);
                      final user = memberDetails[memberId];
                      final isSelected = selectedPayerId == memberId;
                      return ChoiceChip(
                        label: Text(user?.name ?? 'Unknown'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            onPayerSelected(memberId);
                          }
                        },
                        avatar: user?.avatarUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(user!.avatarUrl!),
                              )
                            : null,
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              Text('Split Between', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              if (memberDetails.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: memberDetails.entries.map((entry) {
                    final memberId = entry.key;
                    final user = entry.value;
                    final isSelected = selectedMembers.contains(memberId);
                    return FilterChip(
                      label: Text(user.name ?? user.email),
                      selected: isSelected,
                      onSelected: (selected) {
                        onMemberToggle(memberId, selected);
                      },
                      avatar: user.avatarUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(user.avatarUrl!),
                            )
                          : null,
                    );
                  }).toList(),
                ),
            ],
          ],
        );
      },
    );
  }
}
