import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/mood_view_model.dart';
import 'views/mood_screen.dart';
import 'view_models/auth_view_model.dart';
import 'views/login_screen.dart';

void main() {
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