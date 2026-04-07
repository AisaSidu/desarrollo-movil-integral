import 'package:between/services/notification_service.dart';
import 'package:between/view_models/notes_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/mood_view_model.dart';
import 'view_models/auth_view_model.dart';
import 'views/login_screen.dart';

void main() async {
  // Asegurarnos de que Flutter esté listo antes de correr servicios nativos
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos nuestro servicio de notificaciones
  await NotificationService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aquí "inyectamos" el ViewModel a toda la app
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => NotesViewModel()),
      ],
      child: MaterialApp(
        title: 'Diario Emocional',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
      ),
    );
  }
}