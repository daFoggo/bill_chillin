import 'package:bill_chillin/core/config/app_config.dart';
import 'package:bill_chillin/features/auth/presentation/pages/auth_page.dart';
import 'package:bill_chillin/features/home/presentation/pages/home_page.dart'; // Import trang Home
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart'; // Import Event
import 'features/auth/presentation/bloc/auth_state.dart'; // Import State
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
    return BlocProvider(
      // 1. THAY ĐỔI Ở ĐÂY:
      // Thêm ..add(...) để bắn sự kiện kiểm tra đăng nhập ngay khi App mở lên
      create: (_) => di.sl<AuthBloc>()..add(AuthCheckStatusEvent()),

      child: MaterialApp(
        title: 'BillChillin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        ),

        // 2. THAY ĐỔI Ở ĐÂY:
        // Dùng BlocBuilder để điều hướng màn hình
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Nếu đã đăng nhập -> Vào thẳng Home
            if (state is AuthAuthenticated) {
              return const HomePage();
            }

            // Nếu chưa đăng nhập (hoặc lỗi) -> Vào AuthPage
            if (state is AuthUnauthenticated || state is AuthFailure) {
              return const AuthPage();
            }

            // Mặc định hoặc khi đang Loading ban đầu -> Hiện màn hình chờ (Splash)
            // Để tránh hiện Login Page 1 giây rồi mới nhảy sang Home
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
