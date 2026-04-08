import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Patrón Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inicializamos las zonas horarias
    tz.initializeTimeZones();
    
    await Permission.notification.request();

    const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: initSettingsAndroid);
    
    await _notificationsPlugin.initialize(settings: initSettings);
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

  Future<void> scheduleReminderForDate(DateTime scheduledDate) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_therapy', 
      'Avisos de Terapia Programados',
      channelDescription: 'Te avisa 24 horas antes de tu cita',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    
    // Convertimos el DateTime normal a un formato "tz" (Timezone) que entiende la librería
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // CORRECCIÓN: Todos los parámetros ahora llevan sus etiquetas de nombre
    await _notificationsPlugin.zonedSchedule(
      id: 1,
      title: 'Tu sesión es mañana 🧠',
      body: 'Es un buen momento para revisar tu resumen de la semana en Between.',
      scheduledDate: tzScheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  // Función para cancelar si el usuario desactiva la terapia
  Future<void> cancelScheduledReminders() async {
    await _notificationsPlugin.cancel(id: 1); // El 1 es el ID que le dimos a la alarma programada
  }
}