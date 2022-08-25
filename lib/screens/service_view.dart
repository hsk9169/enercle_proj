import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:enercle_proj/screens/screens.dart';
import 'package:enercle_proj/const/colors.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import 'package:enercle_proj/provider/session_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:enercle_proj/routes.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;

class ServiceView extends StatefulWidget {
  final int? arg;
  const ServiceView(this.arg);
  @override
  State<StatefulWidget> createState() => _ServiceView();
}

class _ServiceView extends State<ServiceView> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final notificationDetails = NotificationDetails(
    // Android details
    android: AndroidNotificationDetails('main_channel', 'Main Channel',
        channelDescription: "ashwin",
        importance: Importance.max,
        priority: Priority.max),
    // iOS details
    iOS: IOSNotificationDetails(),
  );

  bool isMessage = false;

  @override
  void initState() {
    _initMessaging();
    _checkMitigationAlarm();
    super.initState();
  }

  Widget? _bodyWidget(int _index) {
    switch (_index) {
      case 0:
        return RealtimeMonitoringView();
      case 1:
        return MitigationMonitoringView();
      case 2:
        return MypageView();
      default:
        break;
    }
  }

  void _onItemTapped(int sel) {
    Provider.of<Platform>(context, listen: false).servicePageNum = sel;
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = Provider.of<Platform>(context, listen: true).isLoading;
    bool isMitigating =
        Provider.of<Platform>(context, listen: true).isMitigating;
    bool isErrorMessagePopup =
        Provider.of<Platform>(context, listen: true).isErrorMessagePopup;

    _showErrorDialog(isErrorMessagePopup);

    return AbsorbPointer(
        absorbing: isLoading,
        child: Scaffold(
          body: PageTransitionSwitcher(
              transitionBuilder: (
                child,
                animation,
                secondaryAnimation,
              ) {
                return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child);
              },
              child: _bodyWidget(
                  Provider.of<Platform>(context, listen: true).servicePageNum)),
          bottomNavigationBar: BottomNavigationBar(
            selectedFontSize: context.pHeight * 0.018,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Stack(children: [
                  Icon(Icons.power),
                  isMessage
                      ? Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: Icon(Icons.brightness_1,
                              size: context.pHeight * 0.012, color: Colors.red))
                      : SizedBox()
                ]),
                label: '사용량 모니터링',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.energy_savings_leaf,
                    color: isMitigating ? Colors.red : Colors.grey),
                activeIcon: Icon(Icons.energy_savings_leaf,
                    color: isMitigating ? Colors.red : MyColors.mainColor),
                label: '감축량 모니터링',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '마이 페이지',
              ),
            ],
            elevation: 1,
            currentIndex:
                Provider.of<Platform>(context, listen: true).servicePageNum,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            selectedIconTheme: IconThemeData(
                color: MyColors.mainColor, size: context.pHeight * 0.035),
            unselectedIconTheme: IconThemeData(
                color: Colors.black.withOpacity(0.35),
                size: context.pHeight * 0.03),
          ),
        ));
  }

  void _initMessaging() async {
    tz.initializeTimeZones();
    final _platformProvider = Provider.of<Platform>(context, listen: false);
    final _sessionProvider = Provider.of<Session>(context, listen: false);
    final String resourceCode = _sessionProvider.customerInfo.resourceCode;
    final String customerNumber = _sessionProvider.customerInfo.customerNumber;
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.getToken();

    if (_platformProvider.allowAlarm) {
      await FirebaseMessaging.instance.subscribeToTopic(resourceCode);
      await FirebaseMessaging.instance.subscribeToTopic(customerNumber);
    }

    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) =>
            selectNotification(payload!));

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        Provider.of<Platform>(context, listen: false).popupErrorMessage = '0';
        setState(() => isMessage = !isMessage);
        showLocalNotification(message.data, true);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      selectNotification(message.data['alarm_type']);
    });
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      setState(() => isMessage = !isMessage);
      showLocalNotification(message.data, false);
    }
  }

  int _initRemainTime() {
    int minRemain;
    final curTime = DateTime.now();
    int minPast = curTime.minute -
        Provider.of<Platform>(context, listen: false).mitigationTime.minute;
    int secPast = curTime.second -
        Provider.of<Platform>(context, listen: false).mitigationTime.second;
    if (minPast < 0) {
      minPast = 60 + minPast;
    }
    final int totalSec = 3600 - (minPast * 60 + secPast);
    minRemain = totalSec ~/ 60;
    return minRemain;
  }

  void _checkMitigationAlarm() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final DateTime mitigationTime = platformProvider.mitigationTime;
    final String mitigationTitle = Provider.of<Session>(context, listen: false)
        .customerInfo
        .fcmReduceTitle;
    final String mitigationBody =
        Provider.of<Session>(context, listen: false).customerInfo.fcmReduceBody;
    if (platformProvider.isMitigating) {
      final int minRemain = _initRemainTime();

      if (minRemain > 30) {
        _flutterLocalNotificationsPlugin.zonedSchedule(
            2,
            mitigationTitle,
            '${mitigationBody.substring(0, 2)} ${mitigationTime.hour}시 ${mitigationTime.minute}분 ${mitigationBody.substring(3)}, 해제까지 30분 남음',
            tz.TZDateTime.now(tz.local).add(Duration(minutes: minRemain - 30)),
            notificationDetails,
            payload: 'reduce',
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true);
        _flutterLocalNotificationsPlugin.zonedSchedule(
            3,
            mitigationTitle,
            '${mitigationBody.substring(0, 2)} ${mitigationTime.hour}시 ${mitigationTime.minute}분 ${mitigationBody.substring(3)}, 해제까지 10분 남음',
            tz.TZDateTime.now(tz.local).add(Duration(minutes: minRemain - 10)),
            notificationDetails,
            payload: 'reduce',
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true);
      } else if (minRemain > 10) {
        _flutterLocalNotificationsPlugin.zonedSchedule(
            3,
            mitigationTitle,
            '${mitigationBody.substring(0, 2)} ${mitigationTime.hour}시 ${mitigationTime.minute}분 ${mitigationBody.substring(3)}, 해제까지 10분 남음',
            tz.TZDateTime.now(tz.local).add(Duration(minutes: minRemain - 10)),
            notificationDetails,
            payload: 'reduce',
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true);
      }
    }
  }

  Future<void> showLocalNotification(
      Map<String, dynamic> data, bool isForeground) async {
    var platform = Theme.of(context).platform;
    final String maxloadTitle = Provider.of<Session>(context, listen: false)
        .customerInfo
        .fcmMaxloadTitle;
    final String maxloadBody = Provider.of<Session>(context, listen: false)
        .customerInfo
        .fcmMaxloadBody;
    final String mitigationTitle = Provider.of<Session>(context, listen: false)
        .customerInfo
        .fcmReduceTitle;
    final String mitigationBody =
        Provider.of<Session>(context, listen: false).customerInfo.fcmReduceBody;
    final String alarm_type = data['alarm_type'];
    final String startTime = data['hhmi1'] ?? '';
    final String endTime = data['hhmi2'] ?? '';
    final String time = data['hhmi'] ?? '';
    final DateTime mitigationDate = time == ''
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(int.parse(time)).toUtc();
    Provider.of<Platform>(context, listen: false).popupErrorMessage = '1';
    _showErrorDialog(true);

    switch (alarm_type) {
      case 'maxload':
        Provider.of<Platform>(context, listen: false).popupErrorMessage = '2';
        _showErrorDialog(true);
        if (platform == TargetPlatform.android && isForeground) {
          Provider.of<Platform>(context, listen: false).popupErrorMessage = '3';
          _showErrorDialog(true);
          _flutterLocalNotificationsPlugin.show(
              0,
              maxloadTitle,
              '${maxloadBody.substring(0, 2)} $time ${maxloadBody.substring(3)}',
              notificationDetails);
        }
        Provider.of<Platform>(context, listen: false).addPeakBadgeCount();
        FlutterAppBadger.updateBadgeCount(
            Provider.of<Platform>(context, listen: false).totalBadgeCount);
        break;
      case 'reduce':
        _flutterLocalNotificationsPlugin.cancelAll();
        _flutterLocalNotificationsPlugin.show(
            1,
            mitigationTitle,
            '${mitigationBody.substring(0, 2)} $startTime - $endTime시 ${mitigationBody.substring(3)}',
            notificationDetails);
        Provider.of<Platform>(context, listen: false).isMitigating = true;
        Provider.of<Platform>(context, listen: false).mitigationTime =
            mitigationDate;
        Provider.of<Platform>(context, listen: false).addMitigationBadgeCount();
        FlutterAppBadger.updateBadgeCount(
            Provider.of<Platform>(context, listen: false).totalBadgeCount);
        _flutterLocalNotificationsPlugin.zonedSchedule(
            2,
            mitigationTitle,
            '${mitigationBody.substring(0, 2)} $startTime - $endTime시 ${mitigationBody.substring(3)}, 해제까지 30분 남음',
            tz.TZDateTime.now(tz.local).add(const Duration(minutes: 30)),
            notificationDetails,
            payload: 'reduce',
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true);
        _flutterLocalNotificationsPlugin.zonedSchedule(
            3,
            mitigationTitle,
            '${mitigationBody.substring(0, 2)} $startTime - $endTime시 ${mitigationBody.substring(3)}, 해제까지 10분 남음',
            tz.TZDateTime.now(tz.local).add(const Duration(minutes: 50)),
            notificationDetails,
            payload: 'reduce',
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true);
        break;
      default:
        break;
    }
  }

  Future<void> selectNotification(String payload) async {
    switch (payload) {
      case 'maxload':
        Navigator.pushNamed(context, Routes.SERVICE, arguments: 0);
        break;
      case 'reduce':
        Navigator.pushNamed(context, Routes.SERVICE, arguments: 1);
        break;
      default:
        break;
    }
  }

  void _showErrorDialog(bool isError) {
    Future.delayed(Duration.zero, () {
      if (isError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(Provider.of<Platform>(context, listen: false)
                .popupErrorMessage),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 3)));
        Provider.of<Platform>(context, listen: false).isErrorMessagePopup =
            false;
      }
    });
  }
}
