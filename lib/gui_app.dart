import 'dart:io';

import 'package:despresso/model/services/state/screen_saver.dart';
import 'package:flutter/material.dart';
import 'objectbox.dart';
import 'ui/landingpage.dart';
import 'color_schemes.g.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'helper/objectbox_cache_provider.dart';
import 'package:feedback_sentry/feedback_sentry.dart';
import 'package:logging/logging.dart';
import 'package:despresso/model/services/state/settings_service.dart';
import 'package:despresso/service_locator.dart';
import 'package:flutter/services.dart';
import 'logger_util.dart';
import 'dart:async';
import 'package:despresso/devices/decent_de1_simulated.dart';

late ObjectBox objectbox;

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: ObjectBoxPreferenceCache(),
  );
}

Future<void> guiMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  initLogger();

  final log = Logger("main");
  objectbox = await ObjectBox.create();
  getIt.registerSingleton<ObjectBox>(objectbox, signalsReady: false);
  log.info("Starting app");

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: []);

  initSettings().then((_) async {
    if (const String.fromEnvironment("simulate") == "1") {
      Timer(
        const Duration(seconds: 1),
        () => DE1Simulated(),
      );
    }

    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  MyApp({super.key}) {
    setupServices();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SettingsService _settings;
  late ScreensaverService _screensaver;

  @override
  void initState() {
    super.initState();
    _settings = getIt<SettingsService>();
    _settings.addListener(() {
      setState(() {});
    });
    _screensaver = getIt<ScreensaverService>();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        //behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          _screensaver.handleTap();
        },
        child: appRoot(context));
  }

  Widget appRoot(BuildContext context) {
    return BetterFeedback(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'REA',
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: _settings.locale == "auto" ? null : Locale(_settings.locale),
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.brown, brightness: Brightness.light)),
        darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.amber, brightness: Brightness.dark)),
        //theme: ThemeData.from(
        //  useMaterial3: true,
        //  colorScheme: schemaLight,
        //),
        //darkTheme: ThemeData.from(
        //  useMaterial3: true,
        //  colorScheme: themeDark,
        //),
        themeMode: _settings.screenThemeMode == 0
            ? ThemeMode.system
            : _settings.screenThemeMode == 1
                ? ThemeMode.dark
                : ThemeMode.light,
        home: const LandingPage(title: 'REA'),
      ),
    );
  }
}
