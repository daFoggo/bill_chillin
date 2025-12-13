import 'package:bill_chillin/core/config/app_config.dart';
import 'package:bill_chillin/features/auth/presentation/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BỌC BlocProvider Ở ĐÂY (ROOT)
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(), // Khởi tạo AuthBloc từ Service Locator
      child: MaterialApp(
        title: 'BillChillin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        ),
        home: const LoginPage(),
      ),
    );
  }
}
