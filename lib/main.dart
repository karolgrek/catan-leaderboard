import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/group_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Setup Firebase credentials!
  // - Android: Download google-services.json and place it in android/app/
  // - iOS: Download GoogleService-Info.plist and place it in ios/Runner/
  
  /* MOCKED OUT FOR UI PREVIEW
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error (Did you add the config files?): $e");
  }
  */

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
