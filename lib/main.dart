import 'package:logging/logging.dart';

import 'package:despresso/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'logger_util.dart';
import 'objectbox.dart';
import 'ui/landingpage.dart';
import 'package:wakelock/wakelock.dart';
import 'color_schemes.g.dart';

import 'package:logging/logging.dart';
// import 'package:logging_appenders/logging_appenders.dart';

late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initLogger();

  final log = Logger("main");
  // final appender = PrintAppender.setupLogging(stderrLevel: Level.SEVERE);
  // final basePath = await getApplicationDocumentsDirectory();
  // RotatingFileAppender(baseFilePath: "${basePath.path}/logs", keepRotateCount: 3);

  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  log.info("Starting app");
  try {
    Wakelock.enable();
  } on MissingPluginException catch (e) {
    log.info('Failed to set wakelock: $e');
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);

  // SystemChrome.setEnabledSystemUIOverlays([
  //   SystemUiOverlay.bottom, //This line is used for showing the bottom bar
  // ]);
  initSettings().then((_) {
    runApp(MyApp());
  });
}

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: SharePreferenceCache(),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    getIt.registerSingleton<ObjectBox>(objectbox, signalsReady: false);
    setupServices();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'despresso',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        // colorScheme: lightColorScheme,
        // textTheme: const TextTheme(
        //   displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        //   titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.normal),
        //   bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        // ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.dark),
        colorScheme: darkColorScheme,
        // textTheme: const TextTheme(
        //     // displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        //     // titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.normal),
        //     // bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        //     ),
      ),
      themeMode: ThemeMode.dark,

      // theme: ThemeData(
      //   useMaterial3: true,
      //   brightness: Brightness.light,
      // ),
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   brightness: Brightness.dark,
      //   scaffoldBackgroundColor: theme.Colors.backgroundColor,
      //   backgroundColor: theme.Colors.backgroundColor,
      //   colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
      //     primary: theme.Colors.secondaryColor,
      //     secondary: Colors.green,
      //     // brightness: Brightness.dark,
      //   ),

      home: const LandingPage(title: 'despresso'),
    );
  }
}
