import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jabar_caang/app/config/app_router.dart';
import 'package:jabar_caang/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app_lifecycle_reactor.dart'; // Pastikan file ini diimpor

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const JabarCaangApp(),
    ),
  );
}

class JabarCaangApp extends StatefulWidget {
  const JabarCaangApp({super.key});

  @override
  _JabarCaangAppState createState() => _JabarCaangAppState();
}

class _JabarCaangAppState extends State<JabarCaangApp> {
  late final AppLifecycleReactor _lifecycleReactor;

  @override
  void initState() {
    super.initState();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final router = AppRouter.getRouter(context);
    _lifecycleReactor = AppLifecycleReactor(authViewModel: authViewModel, router: router);
  }

  @override
  void dispose() {
    _lifecycleReactor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.getRouter(context);

    return MaterialApp.router(
      title: 'CaangMeter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: router,
    );
  }
}