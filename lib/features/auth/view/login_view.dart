import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter/constants/constants.dart';
import 'package:twitter/features/auth/view/sign_up_view.dart';
import 'package:twitter/features/auth/widgets/auth_field.dart';
import 'package:twitter/theme/theme.dart';

import '../../../common/common.dart';
import '../controller/auth_controller.dart';

class LoginView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginView(),
      );
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final appBar = UIConstants.appBar();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void onLogin() {
    ref.read(authControllerProvider.notifier).login(
          email: emailController.text,
          password: passwordController.text,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: appBar,
      body: isLoading
          ? const Loader()
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      AuthField(
                        controller: emailController,
                        hintText: 'Email Address',
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      AuthField(
                        controller: passwordController,
                        hintText: 'Password',
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: RoundedSmallButton(
                          onTap: onLogin,
                          text: "Done",
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Don't have an account?",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                  text: ' Sign up',
                                  style: const TextStyle(
                                    color: Pallete.blueColor,
                                    fontSize: 16,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushAndRemoveUntil(context,
                                          SignUpView.route(), (route) => false);
                                    }),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
