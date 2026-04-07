import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // Patrón Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Solicitar permiso al usuario (Vital para Android 13+)
    await Permission.notification.request();

    // 2. Configurar el ícono de la notificación (usaremos el por defecto de Flutter)
    const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: initSettingsAndroid);
    
    // --- CORRECCIÓN 1: Ahora pide un parámetro nombrado ---
    await _notificationsPlugin.initialize(
      settings: initSettings, 
      // Nota: Si te sigue marcando error pidiendo "settings", cámbialo a:
      // settings: initSettings,
    );
  }

  // Función para lanzar la notificación de prueba
  Future<void> showTherapyReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'therapy_channel', // ID interno del canal
      'Recordatorios de Terapia', // Nombre visible para el usuario
      channelDescription: 'Alertas para preparar tus sesiones',
      importance: Importance.max, // Para que salga en la parte superior (Heads-up)
      priority: Priority.high,
      enableVibration: true,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    
    // --- CORRECCIÓN 2: Todos los argumentos ahora deben llevar su "etiqueta" ---
    await _notificationsPlugin.show(
      id: 0, // ID de la notificación
      title: '¡Prepara tu sesión! 🧠',
      body: 'Entra a revisar tu resumen semanal antes de ver a tu terapeuta.',
      notificationDetails: platformDetails,
    );
  }
}