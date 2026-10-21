import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'constants/app_strings.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/group_selection_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/catan_hex_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return CatanHexBackground(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (authProvider.isAuthenticated) {
            return Consumer<GroupProvider>(
              builder: (context, groupProvider, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  groupProvider.startListeningToNotifications(
                    authProvider.user?.uid,
                  );
                });
                if (groupProvider.activeGroup != null) {
                  return const HomeScreen();
                }
                return const GroupSelectionScreen();
              },
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<GroupProvider>(
              context,
              listen: false,
            ).startListeningToNotifications(null);
          });
          return const AuthScreen();
        },
      ),
    );
  }
}
