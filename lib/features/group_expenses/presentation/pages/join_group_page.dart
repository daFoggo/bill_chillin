import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/join_group_via_link_usecase.dart';
import 'package:bill_chillin/features/group_expenses/presentation/screens/group_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinGroupPage extends StatefulWidget {
  final String groupId;

  const JoinGroupPage({super.key, required this.groupId});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _joinGroup();
  }

  Future<void> _joinGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _error = "You must be logged in to join a group.";
          _isLoading = false;
        });
      }
      return;
    }

    final useCase = sl<JoinGroupViaLinkUseCase>();

    final result = await useCase(
      JoinGroupViaLinkParams(inviteCode: widget.groupId, userId: user.uid),
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                GroupDetailScreen(groupId: widget.groupId, groupName: "Group"),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Joining Group...")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error ?? "Unknown Error",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        // Go Home
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      child: const Text("Go Home"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
