import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';
import 'screens/main_shell.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'providers/booking_provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/room_service.dart';
import 'services/booking_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Create API Client
  final apiClient = ApiClient(prefs: prefs);
  
  // Create Services
  final authService = AuthService(apiClient: apiClient);
  final roomService = RoomService(apiClient: apiClient);
  final bookingService = BookingService(apiClient: apiClient);
  
  // Create Providers
  final authProvider = AuthProvider(authService);
  final roomProvider = RoomProvider(roomService);
  final bookingProvider = BookingProvider(bookingService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<RoomProvider>.value(value: roomProvider),
        ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
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
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B5DF5),
          primary: const Color(0xFF3B5DF5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

// Wrapper to handle authentication routing
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication on app start (no async gap)
    final authProvider = context.read<AuthProvider>();
    authProvider.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    final authProvider = context.read<AuthProvider>();
    authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const MainShell();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
