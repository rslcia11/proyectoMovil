import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/register_type_screen.dart';
import 'screens/register_player_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/owner_home_screen.dart';
import 'screens/register_owner_screen.dart';
import 'providers/theme_provider.dart';
import 'screens/create_field_screen.dart';
import 'screens/fields_list_screen.dart';
import 'screens/field_detail_screen.dart';
import 'utils/app_routes.dart'; // Import AppRoutes
import 'utils/app_theme.dart'; // Import AppTheme
import 'di/locator.dart'; // Import locator

void main() {
  setupLocator(); // Initialize GetIt
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'CanchApp',
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme, // Use AppTheme for light theme
      darkTheme: AppTheme.darkTheme, // Use AppTheme for dark theme
      home: const LoginScreen(),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterTypeScreen(),
        AppRoutes.registerPlayer: (context) => const RegisterPlayerScreen(),
        AppRoutes.registerOwner: (context) => const RegisterOwnerScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.clientHome: (context) => const ClientHomeScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.ownerHome: (context) => const OwnerHomeScreen(),
        AppRoutes.createField: (context) => const CreateFieldScreen(),
        AppRoutes.fieldsList: (context) => const FieldsListScreen(),
        AppRoutes.fieldDetail: (context) => const FieldDetailScreen(),
      },
    );
  }
}