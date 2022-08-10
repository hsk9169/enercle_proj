import 'package:enercle_proj/services/local_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enercle_proj/widgets/dissmiss_keyboard.dart';
import 'package:enercle_proj/routes.dart';
import 'package:enercle_proj/screens/screens.dart';
import 'package:enercle_proj/const/colors.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import 'package:enercle_proj/provider/session_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
        child: MultiProvider(
            providers: [
          ChangeNotifierProvider<Platform>.value(value: Platform()),
          ChangeNotifierProvider<Session>.value(value: Session()),
        ],
            child: MaterialApp(
              navigatorObservers: [routeObserver],
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: MyColors.mainMaterialColor,
                scaffoldBackgroundColor: Colors.white,
                bottomSheetTheme: BottomSheetThemeData(
                    backgroundColor: Colors.black.withOpacity(0.5)),
              ),
              routes: {
                Routes.SPLASH: (context) => SplashView(),
                Routes.SIGNIN: (context) => SignInView(),
                Routes.SERVICE: (context) => ServiceView(
                    ModalRoute.of(context)!.settings.arguments as int),
              },
              initialRoute: Routes.SPLASH,
            )
            //)
            ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
