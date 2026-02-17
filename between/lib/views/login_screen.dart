import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'mood_screen.dart'; // Tu pantalla principal

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLogin = true; // Alternar entre Login y Signup

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              _isLogin ? "Bienvenido de nuevo" : "Crear Cuenta",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Correo", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passController,
              decoration: InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success;
                if (_isLogin) {
                  success = await authViewModel.login(_emailController.text, _passController.text);
                } else {
                  success = await authViewModel.signup(_emailController.text, _passController.text);
                }

                if (success) {
                  // Navegar a la pantalla principal
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => MoodScreen())
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: Credenciales incorrectas o usuario ya existe"))
                  );
                }
              },
              child: Text(_isLogin ? "Entrar" : "Registrarse"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => _showPrivacyDialog(context),
              child: Text(
                "Aviso de Privacidad y Uso de Datos",
                style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia sesión"),
            )
          ],
        ),
      ),
    );
  }
}

void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Aviso de Privacidad"),
          content: SingleChildScrollView( // Permite scrollear si el texto es largo
            child: ListBody(
              children: <Widget>[
                Text(
                  "De conformidad con lo establecido en la Ley Federal de Protección de Datos Personales...",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(height: 10),
                Text("1. ALMACENAMIENTO LOCAL: Sus datos (notas, emociones y credenciales) se almacenan únicamente en su dispositivo. No se envían a servidores externos."),
                SizedBox(height: 10),
                Text("2. CIFRADO: Utilizamos el estándar AES-256 para cifrar su información sensible, asegurando que solo usted tenga acceso a ella."),
                SizedBox(height: 10),
                Text("3. CONSENTIMIENTO: Al registrarse, usted acepta el uso de la aplicación para fines de monitoreo personal de salud mental."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }