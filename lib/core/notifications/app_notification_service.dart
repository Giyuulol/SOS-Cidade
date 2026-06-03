/// Facade de notificações usada pela application layer.
///
/// Dependency Inversion Principle: controllers dependem deste contrato, não do
/// plugin `flutter_local_notifications`.
abstract interface class AppNotificationService {
  Future<void> initialize();

  Future<void> showCriticalAlert({required String title, required String body});

  Future<void> showNewChamadoNotification({
    required String chamadoTitle,
    required String prioridade,
  });
}
