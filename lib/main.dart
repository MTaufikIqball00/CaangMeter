import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jabar_caang/app/config/app_router.dart';
import 'package:jabar_caang/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    // Bungkus dengan MultiProvider untuk menyediakan ViewModel
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const JabarCaangApp(),
    ),
  );
}

class JabarCaangApp extends StatelessWidget {
  const JabarCaangApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil router dari AppRouter
    final router = AppRouter.getRouter(context);

    return MaterialApp.router(
      title: 'CaangMeter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Gunakan routerConfig
      routerConfig: router,
    );
  }
}
