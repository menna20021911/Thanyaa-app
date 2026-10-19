import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanya/repositories/auth_repository.dart';
import 'package:thanya/widgets/custom_snakebar.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkUserLoggedIn() async {
    emit(AuthLoading());
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthSuccess(user.uid));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.loginWithEmail(email, password);
      if (user != null) {
        CustomSnackBar.show(
          context,
          "Welcome back, ${user.email ?? 'user'} 👋",
        );
        emit(AuthSuccess(user.uid));
      } else {
        CustomSnackBar.show(context, "Login failed", isError: true);
        emit(const AuthFailure("Login failed"));
      }
    } catch (e) {
      _handleError(context, e);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> register(
    BuildContext context,
    String name,
    String email,
    String bandId,
    String password,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.registerUser(
        name,
        email,
        bandId,
        password,
      );
      if (user != null) {
        CustomSnackBar.show(context, "Account created successfully");
        emit(AuthSuccess(user.uid));
      } else {
        CustomSnackBar.show(context, "Registration failed", isError: true);
        emit(const AuthFailure("Registration failed"));
      }
    } catch (e) {
      _handleError(context, e);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.loginWithGoogle();
      if (user != null) {
        CustomSnackBar.show(
          context,
          "Signed in as ${user.displayName ?? user.email ?? 'Google user'} 🌟",
        );
        emit(AuthSuccess(user.uid));
      } else {
        CustomSnackBar.show(context, "Google sign-in canceled", isError: true);
        emit(const AuthFailure("Google login canceled"));
      }
    } catch (e) {
      _handleError(context, e);
      emit(AuthFailure(e.toString()));
    }
  }

  void _handleError(BuildContext context, dynamic e) {
    String message = "An unexpected error occurred.";

    final error = e.toString();
    if (error.contains("web-context-canceled")) {
      message = "Google sign-in was canceled by the user.";
    } else if (error.contains("wrong-password")) {
      message = "Incorrect password. Please try again.";
    } else if (error.contains("user-not-found")) {
      message = "No account found with that email.";
    } else if (error.contains("email-already-in-use")) {
      message = "This email is already registered.";
    } else if (error.contains("network-request-failed")) {
      message = "Please check your internet connection.";
    } else if (error.contains("invalid-email")) {
      message = "Invalid email format.";
    } else if (error.contains("too-many-requests")) {
      message = "Too many attempts. Try again later.";
    }

    CustomSnackBar.show(context, message, isError: true);
  }
}
