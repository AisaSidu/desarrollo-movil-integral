import 'package:between/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModels
import 'view_models/auth_view_model.dart';
import 'view_models/mood_view_model.dart';
import 'view_models/notes_view_model.dart';
import 'view_models/therapy_view_model.dart';

// Pantallas
import 'views/login_screen.dart';
import 'views/mood_screen.dart';

// Servicios
import 'services/notification_service.dart';

void main() async {
  // Asegurarnos de que Flutter esté listo antes de correr servicios nativos
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Inicializamos nuestro servicio de notificaciones
  await NotificationService().init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MoodViewModel()),
        ChangeNotifierProvider(create: (_) => NotesViewModel()),
        ChangeNotifierProvider(create: (_) => TherapyViewModel()),
      ],
      child: MaterialApp(
        title: 'Between',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Roboto', // O la fuente que estés usando
        ),
        // Aquí conectamos a nuestro "portero"
        home: const AuthGate(),
      ),
    );
  }
}

// ─── WIDGET PORTERO (AuthGate) ──────────────────────────────────────────
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    // Llamamos al AuthViewModel para verificar la sesión y la biometría
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final result = await authVM.checkAndAuthenticate();
    
    // Una vez que termina, actualizamos la pantalla
    setState(() {
      _isAuthenticated = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Mientras verifica, mostramos una pantalla de carga con los colores de Between
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3EEFF), // lilacFog
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6B4FA0), // deepPurple
          ),
        ),
      );
    }

    // 2. Si pasó la seguridad, va al Dashboard; si no, al Login
    return _isAuthenticated ? MoodScreen() : LoginScreen();
  }
}