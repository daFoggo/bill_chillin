import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/group_entity.dart';

class CreateGroupSheet extends StatefulWidget {
  final Function(GroupEntity) onGroupCreated;
  final String currentUserId;

  const CreateGroupSheet({
    super.key,
    required this.onGroupCreated,
    required this.currentUserId,
  });

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final TextEditingController _nameController = TextEditingController();
  final String _currency = 'VND';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create New Group',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                final newGroup = GroupEntity(
                  id: const Uuid().v4(),
                  name: _nameController.text,
                  members: [widget.currentUserId],
                  createdBy: widget.currentUserId,
                  createdAt: DateTime.now(),
                  currency: _currency,
                  searchKeywords: const [],
                );
                widget.onGroupCreated(newGroup);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
