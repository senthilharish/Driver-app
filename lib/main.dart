import 'package:driver_application/firebase_options.dart';
import 'package:driver_application/services/auth_managementService.dart';
import 'package:driver_application/services/location_managementService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'ui/bus_entry_screen.dart';
import 'ui/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthManagementService()),
        ChangeNotifierProvider(create: (_) => LocationManagementService()),
      ],
      child: MaterialApp(
        title: 'Bus Tracking Admin',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthManagementService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          return const BusEntryScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}