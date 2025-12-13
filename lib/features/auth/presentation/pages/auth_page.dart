import 'package:bill_chillin/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart'; // Import State để check trạng thái
import '../widgets/sign_in_bottom_sheet.dart';
import '../widgets/sign_up_bottom_sheet.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    // Tạm thời comment dòng này lại để test nút Google cho dễ,
    // đỡ bị cái BottomSheet che mất nút Google mỗi khi load lại.
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   showSignInBottomSheet(context);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // --- BẮT ĐẦU SỬA TỪ ĐÂY ---
    // Bọc Scaffold bằng BlocConsumer để vừa nghe (listener) vừa vẽ (builder)
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // 1. XỬ LÝ SIDE EFFECT (Chuyển trang, thông báo lỗi)

        if (state is AuthAuthenticated) {
          // Đăng nhập thành công -> Chuyển sang HomePage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else if (state is AuthFailure) {
          // Đăng nhập thất bại -> Hiện SnackBar đỏ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // 2. XỬ LÝ GIAO DIỆN (Loading)
        // Kiểm tra xem có đang loading không
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: colorScheme.primaryContainer,
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Icon(
                    Icons.savings_rounded,
                    size: 100,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Bill Chillin",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Nút Sign In
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        // Nếu đang loading thì disable nút này
                        onPressed: isLoading
                            ? null
                            : () => showSignInBottomSheet(context),
                        icon: const Icon(Icons.login),
                        label: const Text(
                          "Sign In",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nút Create Account
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => showSignUpBottomSheet(context),
                        child: const Text(
                          "Create an account",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(color: colorScheme.onPrimaryContainer),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: colorScheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- NÚT GOOGLE (CÓ HIỆU ỨNG LOADING) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 2,
                        ),
                        // Nếu đang loading thì disable nút (null)
                        onPressed: isLoading
                            ? null
                            : () {
                                // Gửi sự kiện khi bấm
                                context.read<AuthBloc>().add(
                                  AuthGoogleSignInEvent(),
                                );
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/google.svg',
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ... Giữ nguyên 2 hàm showBottomSheet ở dưới
void showSignInBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const SignInBottomSheet(),
  );
}

void showSignUpBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const SignUpBottomSheet(),
  );
}
