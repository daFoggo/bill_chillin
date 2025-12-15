import 'dart:async';

import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/features/auth/presentation/pages/auth_page.dart';
import 'package:bill_chillin/features/main/presentation/pages/main_screen.dart';
import 'package:bill_chillin/features/group_expenses/presentation/pages/join_group_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppRoutes.joinGroup,
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return JoinGroupPage(groupId: groupId);
        },
      ),
    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;

      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isJoinGroup = state.matchedLocation.startsWith('/join');

      if (!isAuthenticated) {
        if (isJoinGroup) return null;
        return isLoggingIn ? null : AppRoutes.login;
      }

      if (isLoggingIn) {
        return AppRoutes.home;
      }

      return null;
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
