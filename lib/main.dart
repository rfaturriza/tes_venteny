import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';

import 'core/utils/local_notification.dart';
import 'injection.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  await configureDependencies();
  await getIt<LocalNotification>().init();
  DartPingIOS.register();

  runApp(MyApp(settingsController: settingsController));
}
