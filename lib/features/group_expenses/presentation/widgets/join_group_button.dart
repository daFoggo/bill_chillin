import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/join_group_via_link_usecase.dart';
import 'package:bill_chillin/features/group_expenses/presentation/screens/group_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinGroupButton extends StatefulWidget {
  const JoinGroupButton({super.key});

  @override
  State<JoinGroupButton> createState() => _JoinGroupButtonState();
}

class _JoinGroupButtonState extends State<JoinGroupButton> {
  void _showJoinBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const _JoinGroupSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showJoinBottomSheet(context),
      icon: const Icon(Icons.link),
      tooltip: 'Join Group via Link',
    );
  }
}

class _JoinGroupSheet extends StatefulWidget {
  const _JoinGroupSheet();

  @override
  State<_JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends State<_JoinGroupSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = "You must be logged in to join a group.";
        _isLoading = false;
      });
      return;
    }

    final useCase = sl<JoinGroupViaLinkUseCase>();
    final result = await useCase(
      JoinGroupViaLinkParams(inviteCode: input, userId: user.uid),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (_) {
        Navigator.pop(context);

        String groupId = input;
        final prefixes = [
          'https://billchillin.web.app/app/join/',
          'http://billchillin.web.app/app/join/',
          'https://billchillin.firebaseapp.com/app/join/',
          'http://billchillin.firebaseapp.com/app/join/',
          'billchillin://app/join/',
          'billchillin://join/',
        ];

        for (final prefix in prefixes) {
          if (input.startsWith(prefix)) {
            groupId = input.split(prefix).last;
            break;
          }
        }

        // Navigate to Group Detail
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupDetailScreen(
              groupId: groupId,
              groupName: "Group", // Name will be loaded by screen
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Join Group", style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Group Link or ID",
              hintText: "Paste link or enter ID",
              errorText: _error,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.link),
            ),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _joinGroup,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Join"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
