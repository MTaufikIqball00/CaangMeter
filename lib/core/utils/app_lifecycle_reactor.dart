import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jabar_caang/features/auth/viewmodel/auth_viewmodel.dart';

class AppLifecycleReactor with WidgetsBindingObserver {
  final AuthViewModel authViewModel;
  final GoRouter router;

  DateTime? _backgroundTime;
  final Duration timeoutDuration = const Duration(minutes: 1);

  AppLifecycleReactor({required this.authViewModel, required this.router}) {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final duration = DateTime.now().difference(_backgroundTime!);
        if (duration > timeoutDuration) {
          _forceLogout();
        }
      }
    }
  }

  void _forceLogout() {
    authViewModel.logout(); // Pastikan logout() ada di AuthViewModel
    router.go('/login');
  }
}
