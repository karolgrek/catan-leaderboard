import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/group_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Real Firebase Initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catan Leaderboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (authProvider.isAuthenticated) {
            return const GroupSelectionScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
