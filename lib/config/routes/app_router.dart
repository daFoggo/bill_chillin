import 'dart:async';

import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/features/auth/presentation/pages/auth_page.dart';
import 'package:bill_chillin/features/main/presentation/pages/main_screen.dart';
import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:bill_chillin/features/scan/presentation/pages/scan_receipt_page.dart';
import 'package:bill_chillin/features/scan/presentation/pages/review_scanned_transactions_page.dart';
import 'package:bill_chillin/features/group_expenses/presentation/pages/join_group_page.dart';
import 'package:bill_chillin/features/group_expenses/presentation/screens/group_detail_screen.dart';
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
        path: '/app/scan',
        name: 'scan_receipt',
        builder: (context, state) => const ScanReceiptPage(),
      ),
      GoRoute(
        path: '/app/scan/review',
        name: 'review_scanned_transactions',
        builder: (context, state) {
          final extra = state.extra;

          // Supported extras:
          // 1) List<ScannedTransaction>
          // 2) Map { 'transactions': List<ScannedTransaction>, 'groupId': String?, 'members': Map<String,String>? }
          if (extra is List &&
              extra.isNotEmpty &&
              extra.first is ScannedTransaction) {
            return ReviewScannedTransactionsPage(
              scannedTransactions: List<ScannedTransaction>.from(extra),
            );
          }

          if (extra is Map) {
            final txList = extra['transactions'];
            final groupId = extra['groupId'] as String?;
            final members = extra['members'] as Map<String, String>?;
            if (txList is List &&
                txList.isNotEmpty &&
                txList.first is ScannedTransaction) {
              return ReviewScannedTransactionsPage(
                scannedTransactions: List<ScannedTransaction>.from(txList),
                initialGroupId: groupId,
                groupMembers: members ?? const {},
              );
            }
          }

          return const ReviewScannedTransactionsPage();
        },
      ),
      GoRoute(
        path: AppRoutes.joinGroup,
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return JoinGroupPage(groupId: groupId);
        },
      ),
      GoRoute(
        path: AppRoutes.groupDetail,
        name: 'group_detail',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupDetailScreen(groupId: groupId);
        },
      ),
    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;

      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isJoinGroup = state.matchedLocation.startsWith('/app/join');

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
