import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jabar_caang/app/constants/app_constants.dart';
import 'package:jabar_caang/features/aduan/view/form_aduan_page.dart';
import 'package:jabar_caang/features/aduan/view/list_aduan_page.dart';
import 'package:jabar_caang/features/admin/view/admin_page.dart';
import 'package:jabar_caang/features/auth/view/login_page.dart';
import 'package:jabar_caang/features/auth/view/register_page.dart';
import 'package:jabar_caang/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jabar_caang/features/home/view/home_page.dart';
import 'package:jabar_caang/features/main_navigation/view/main_navigation_page.dart';
import 'package:jabar_caang/features/monitoring/view/monitoring_page.dart';
import 'package:jabar_caang/features/profile/view/profile_page.dart';
import 'package:jabar_caang/features/profile/view/about_us_page.dart';
import 'package:jabar_caang/features/profile/view/setting_profile_page.dart';
import 'package:jabar_caang/features/profile/view/ubah_password_page.dart';
import 'package:jabar_caang/features/simulasi_solar/model/simulasi_result_model.dart';
import 'package:jabar_caang/features/simulasi_solar/view/simulasi_hasil_page.dart';
import 'package:jabar_caang/features/simulasi_solar/view/simulasi_solar_page.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter getRouter(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppConstants.monitoringRoute,
      refreshListenable: authViewModel,
      redirect: (BuildContext context, GoRouterState state) {
        final bool isLoggedIn = authViewModel.currentUser != null;
        final bool isAdmin = authViewModel.isAdmin;

        final isGoingToAuth = state.matchedLocation == AppConstants.loginRoute ||
            state.matchedLocation == AppConstants.registerRoute;

        if (!isLoggedIn && !isGoingToAuth) return AppConstants.loginRoute;
        if (isLoggedIn && isGoingToAuth) return AppConstants.homeRoute;
        if (isLoggedIn &&
            isAdmin &&
            state.matchedLocation == AppConstants.homeRoute) {
          return AppConstants.adminRoute;
        }
        if (isLoggedIn &&
            !isAdmin &&
            state.matchedLocation == AppConstants.adminRoute) {
          return AppConstants.homeRoute;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppConstants.loginRoute,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppConstants.registerRoute,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppConstants.adminRoute,
          builder: (context, state) => const AdminPage(),
        ),
        GoRoute(
          path: AppConstants.formAduanRoute,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => FormAduanPage(),
        ),
        GoRoute(
          path: AppConstants.listAduanRoute,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ListAduanPage(),
        ),
        GoRoute(
          path: AppConstants.aboutUsRoute,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AboutUsPage(),
        ),
        GoRoute(
          path: AppConstants.ubahPasswordRoute,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const UbahPasswordPage(),
        ),
        GoRoute(
          path: AppConstants.settingProfileRoute,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SettingProfilePage(role: 'user'),
        ),
        GoRoute(
          path: '/simulasi-solar',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SimulasiSolarPage(),
        ),
        GoRoute(
          path: '/simulasi-hasil',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final result = state.extra as SimulasiResultModel;
            return SimulasiHasilPage(result: result);
          },
        ),

        // Profil Admin
        GoRoute(
          path: AppConstants.profileAdminRoute,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ProfilePage(role: 'admin'),
        ),

        // Menu utama untuk user
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigationPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AppConstants.homeRoute,
                  builder: (context, state) => const HomePage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AppConstants.monitoringRoute,
                  builder: (context, state) => const MonitoringPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AppConstants.profileRoute,
                  builder: (context, state) =>
                  const ProfilePage(role: 'user')),
            ]),
          ],
        ),
      ],
    );
  }
}
