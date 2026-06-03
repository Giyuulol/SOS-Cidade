import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_notification_service.dart';
import 'local_notification_service.dart';

final notificationServiceProvider = Provider<AppNotificationService>((ref) {
  return LocalNotificationService();
});
