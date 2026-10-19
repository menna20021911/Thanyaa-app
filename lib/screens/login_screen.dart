import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanya/cubit/auth/auth_cubit.dart';
import 'package:thanya/cubit/auth/auth_state.dart';
import 'package:thanya/widgets/custom_button.dart';
import 'package:thanya/widgets/custom_input_field.dart';
import 'package:thanya/widgets/loading_overlay.dart';
import 'register_screen.dart';
import 'navigte_bar.dart';
import '../services/connectivity_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const NavigateBar()),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                _buildLoginForm(context, isLoading),
                LoadingOverlay(show: isLoading),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isLoading) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          colors: [Color(0xFF1BA24A), Color(0xFFFFD700), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  Text(
                    "Welcome Back",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.asset('assets/logo2.png', width: 500),
                          CustomInputField(
                            controller: _emailController,
                            hint: "Email",
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value!.isEmpty
                                ? "Please enter your email"
                                : null,
                          ),
                          CustomInputField(
                            controller: _passwordController,
                            hint: "Password",
                            obscureText: true,
                            validator: (value) =>
                                value!.length < 6 ? "Password too short" : null,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: "Login",
                            isLoading: isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().login(
                                  context,
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          MaterialButton(
                            onPressed: () {
                              context.read<AuthCubit>().loginWithGoogle(
                                context,
                              );
                            },
                            height: 50,
                            minWidth: double.infinity,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/google.png', height: 30),
                                const SizedBox(width: 10),
                                const Text(
                                  "Sign in with Google",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Don’t have an account? ',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Register',
                                    style: TextStyle(
                                      color: const Color(0xFF1BA24A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
