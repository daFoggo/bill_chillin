import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/group_list/group_list_bloc.dart';
import '../widgets/create_group_sheet.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch(BuildContext context) {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    context.read<GroupListBloc>().add(const SearchGroupsEvent(query: ''));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view groups')),
      );
    }
    final currentUserId = user.uid;

    return BlocProvider(
      create: (context) =>
          sl<GroupListBloc>()..add(LoadGroupsEvent(userId: currentUserId)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? SizedBox(
                      height: 45,
                      child: SearchBar(
                        controller: _searchController,
                        hintText: "Search groups...",
                        elevation: WidgetStateProperty.all(0),
                        leading: const Icon(Icons.search),
                        onChanged: (query) {
                          context.read<GroupListBloc>().add(
                            SearchGroupsEvent(query: query),
                          );
                        },
                      ),
                    )
                  : const Text(
                      'Group Expenses',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
              actions: [
                if (_isSearching)
                  IconButton(
                    onPressed: () => _stopSearch(context),
                    icon: const Icon(Icons.close),
                  )
                else ...[
                  IconButton(
                    onPressed: _startSearch,
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () {
                      _showGroupActionSheet(context, currentUserId);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ],
            ),
            body: BlocBuilder<GroupListBloc, GroupListState>(
              builder: (context, state) {
                if (state is GroupListLoading || state is GroupListInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GroupListLoaded) {
                  if (state.groups.isEmpty) {
                    if (_isSearching) {
                      return const Center(child: Text('No groups found.'));
                    }
                    return const Center(
                      child: Text('No groups yet. Create one!'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.groups.length,
                    itemBuilder: (context, index) {
                      final group = state.groups[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Text(
                              group.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(
                            group.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${group.members.length} members',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupDetailScreen(
                                  groupId: group.id,
                                  groupName: group.name,
                                ),
                              ),
                            ).then((_) {
                              if (context.mounted) {
                                context.read<GroupListBloc>().add(
                                  LoadGroupsEvent(userId: currentUserId),
                                );
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                } else if (state is GroupListError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  void _showGroupActionSheet(BuildContext context, String currentUserId) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Create New Group'),
            onTap: () {
              Navigator.pop(ctx);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => CreateGroupSheet(
                  currentUserId: currentUserId,
                  onGroupCreated: (group) {
                    context.read<GroupListBloc>().add(
                      CreateNewGroupEvent(group: group),
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Join Group via Link/Code'),
            onTap: () {
              Navigator.pop(ctx);
              _showJoinGroupDialog(context, currentUserId);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context, String currentUserId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Join Group"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Invite Link or Code",
            hintText: "Paste the link here",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                context.read<GroupListBloc>().add(
                  JoinGroupEvent(inviteCode: code, userId: currentUserId),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text("Join"),
          ),
        ],
      ),
    );
  }
}
