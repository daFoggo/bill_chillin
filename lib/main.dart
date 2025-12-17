import 'package:bill_chillin/core/config/app_config.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'config/routes/app_router.dart';
import 'core/services/injection_container.dart' as di;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();

  final authBloc = di.sl<AuthBloc>()..add(AuthCheckStatusEvent());
  final appRouter = AppRouter(authBloc);

  runApp(MyApp(router: appRouter.router, authBloc: authBloc));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  final AuthBloc authBloc;

  const MyApp({super.key, required this.router, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'BillChillin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            },
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}
