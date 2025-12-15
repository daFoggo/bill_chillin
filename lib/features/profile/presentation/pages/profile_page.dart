import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_event.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String email = '';
        String name = 'User';
        String? avatarUrl;

        if (state is AuthAuthenticated) {
          email = state.user.email;
          name = state.user.name ?? 'User';
          avatarUrl = state.user.avatarUrl;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 48,
                  ), // Added top spacing since 'X' is gone
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: avatarUrl == null
                        ? Text(
                            name[0].toUpperCase(),
                            style: Theme.of(context).textTheme.displaySmall,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    "Hi, $name!",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email (displayed in header or just used for context)
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Sign Out Button
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    leading: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      context.read<AuthBloc>().add(AuthSignOutEvent());
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
