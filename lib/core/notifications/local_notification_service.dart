import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app_notification_service.dart';

/// Implementação concreta da facade de notificações locais.
///
/// Facade Pattern: encapsula detalhes do plugin e deixa o restante do app
/// falar somente com a abstração `AppNotificationService`.
final class LocalNotificationService implements AppNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Abrir');

    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
      linux: linux,
    );

    await _plugin.initialize(settings: settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  @override
  Future<void> showCriticalAlert({
    required String title,
    required String body,
  }) {
    return _show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      importance: Importance.max,
      priority: Priority.high,
    );
  }

  @override
  Future<void> showNewChamadoNotification({
    required String chamadoTitle,
    required String prioridade,
  }) {
    return _show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Novo chamado cadastrado',
      body: '$chamadoTitle - prioridade $prioridade',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    required Importance importance,
    required Priority priority,
  }) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      'chamados_urbanos',
      'Chamados urbanos',
      channelDescription: 'Alertas de chamados críticos e novos chamados',
      importance: importance,
      priority: priority,
    );

    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
