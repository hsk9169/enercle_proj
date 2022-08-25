import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import 'package:enercle_proj/provider/session_provider.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/const/colors.dart';
import 'package:enercle_proj/utils/number_handler.dart';
import 'package:enercle_proj/screens/mypage/change_password_view.dart';
import 'package:enercle_proj/screens/mypage/change_threshold_view.dart';
import 'package:enercle_proj/services/encrypted_storage_service.dart';
import 'package:enercle_proj/routes.dart';
import 'package:enercle_proj/services/real_api_service.dart';

class MypageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MypageView();
}

class _MypageView extends State<MypageView> {
  final _encryptedStorageService = EncryptedStorageService();

  final RealApiService _apiService = RealApiService();

  bool _isSignOutTapped = false;

  @override
  void initState() {
    super.initState();
    _initStorage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initStorage() async {
    await _encryptedStorageService.initStorage();
  }

  void _onAlarmChanged(bool value) async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final String resourceCode =
        Provider.of<Session>(context, listen: false).customerInfo.resourceCode;
    final String customerNumber = Provider.of<Session>(context, listen: false)
        .customerInfo
        .customerNumber;
    platformProvider.allowAlarm = value;
    if (value) {
      try {
        await FirebaseMessaging.instance.subscribeToTopic(resourceCode);
        await FirebaseMessaging.instance.subscribeToTopic(customerNumber);
        await _encryptedStorageService.saveData('allowAlarm', 'TRUE');
      } catch (err) {
        platformProvider.popupErrorMessage = '네트워크 오류 발생';
        platformProvider.isErrorMessagePopup = true;
      }
    } else {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(resourceCode);
        await FirebaseMessaging.instance.unsubscribeFromTopic(customerNumber);
        await _encryptedStorageService.saveData('allowAlarm', 'FALSE');
      } catch (err) {
        platformProvider.popupErrorMessage = '네트워크 오류 발생';
        platformProvider.isErrorMessagePopup = true;
      }
    }
  }

  void _onTapSignOut() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    dynamic response = await _apiService.signOut(
        sessionProvider.customerInfo.customerNumber, platformProvider.phoneNum);

    if (response == 'SOCKET_EXCEPTION') {
      platformProvider.popupErrorMessage = '네트워크 오류 발생';
      platformProvider.isErrorMessagePopup = true;
    } else if (response == 'TIMEOUT_EXCEPTION') {
      platformProvider.popupErrorMessage = '서버 요청시간 만료';
      platformProvider.isErrorMessagePopup = true;
    } else if (response == 'UNKNOWN_ERROR') {
      platformProvider.popupErrorMessage = '알 수 없는 에러 발생';
      platformProvider.isErrorMessagePopup = true;
    } else {
      if (response == 'BAD_REQUEST') {
        platformProvider.popupErrorMessage = '로그인 정보 입력 오류';
        platformProvider.isErrorMessagePopup = true;
        return;
      } else if (response == 'SERVER_ERROR') {
        platformProvider.popupErrorMessage = '서버 오류 발생';
        platformProvider.isErrorMessagePopup = true;
        return;
      } else {
        await _encryptedStorageService.saveData('isSignedOut', 'TRUE');
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.SIGNIN, (Route<dynamic> route) => false);
        platformProvider.flush();
        sessionProvider.flush();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: context.pHeight,
        color: Colors.white,
        child: SingleChildScrollView(
            child: SafeArea(
                top: false,
                maintainBottomViewPadding: true,
                child: Stack(children: [
                  Container(
                      alignment: Alignment.topCenter,
                      width: context.pWidth,
                      height: context.pHeight * 0.3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [MyColors.mainColor, Colors.white],
                        ),
                      )),
                  Container(
                      padding: EdgeInsets.only(
                        top: context.pHeight * 0.1,
                        left: context.pWidth * 0.03,
                        right: context.pWidth * 0.03,
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _renderCorpInfo(),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: context.pHeight * 0.025,
                                    left: context.pWidth * 0.02,
                                    right: context.pWidth * 0.02),
                                child: _renderMenu())
                          ]))
                ]))));
  }

  Widget _renderCorpInfo() {
    final session = Provider.of<Session>(context, listen: false);
    final lineSpacing = context.pHeight * 0.0035;
    final double threshold = NumberHandler().makeDoubleFixedPoint(
        double.parse(session.customerInfo.powerThreshold5), 3);
    final String thresholdStr = NumberHandler().addComma(threshold.toString());
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.only(
          left: context.pWidth * 0.07,
          right: context.pWidth * 0.07,
          top: context.pHeight * 0.04,
          bottom: context.pHeight * 0.04,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(3, 3))
          ],
        ),
        child: SizedBox(
            width: context.pWidth,
            child: Column(children: [
              Container(
                  width: context.pWidth * 0.8,
                  alignment: Alignment.center,
                  child: Text(session.customerInfo.customerName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.pHeight * 0.035,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false)),
              Padding(padding: EdgeInsets.all(context.pHeight * 0.005)),
              const Divider(
                color: Colors.black26,
                thickness: 1,
              ),
              Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('고객사 ID',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: context.pHeight * 0.02,
                      )),
                  Padding(padding: EdgeInsets.all(lineSpacing)),
                  Text('계약 용량',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: context.pHeight * 0.02,
                      )),
                  Padding(padding: EdgeInsets.all(lineSpacing)),
                  Text('실시간 최대 전력사용량',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: context.pHeight * 0.02,
                      )),
                ]),
                Padding(padding: EdgeInsets.all(context.pWidth * 0.04)),
                SizedBox(
                    width: context.pWidth * 0.32,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.customerInfo.customerNumber,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: context.pHeight * 0.02,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false),
                          Padding(padding: EdgeInsets.all(lineSpacing)),
                          Text(
                              '${NumberHandler().addComma(session.customerInfo.contractPower)}kWh',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: context.pHeight * 0.02,
                                  fontWeight: FontWeight.bold)),
                          Padding(padding: EdgeInsets.all(lineSpacing)),
                          Text(
                            '${thresholdStr}kWh',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: context.pHeight * 0.02,
                                fontWeight: FontWeight.bold),
                          ),
                        ])),
              ])
            ])));
  }

  Widget _renderMenu() {
    final bool isAdmin =
        Provider.of<Session>(context, listen: false).customerInfo.isAdmin ==
                'TRUE'
            ? true
            : false;
    final platform = Provider.of<Platform>(context, listen: false);
    return Column(children: [
      _menuItem(
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(Icons.notifications_active_outlined,
              size: context.pWidth * 0.07),
          Padding(padding: EdgeInsets.all(context.pWidth * 0.02)),
          Text('앱 푸시 알림 설정',
              style: TextStyle(
                  color: Colors.black, fontSize: context.pWidth * 0.055))
        ]),
        CupertinoSwitch(
          value: platform.allowAlarm,
          onChanged: (bool value) => _onAlarmChanged(value),
        )
      ])),
      isAdmin
          ? _renderClickableArrow(
              'PASSWORD',
              _menuItem(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.lock_outline, size: context.pWidth * 0.07),
                      Padding(padding: EdgeInsets.all(context.pWidth * 0.02)),
                      Text('비밀번호 변경',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: context.pWidth * 0.055))
                    ]),
                    Icon(Icons.arrow_forward_ios,
                        size: context.pWidth * 0.07, color: Colors.grey)
                  ])))
          : SizedBox(),
      isAdmin
          ? _renderClickableArrow(
              'THRESHOLD',
              _menuItem(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.electric_bolt, size: context.pWidth * 0.07),
                      Padding(padding: EdgeInsets.all(context.pWidth * 0.02)),
                      Text('최대 전력사용량 설정 변경',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: context.pWidth * 0.055))
                    ]),
                    Icon(Icons.arrow_forward_ios,
                        size: context.pWidth * 0.07, color: Colors.grey)
                  ])))
          : SizedBox(),
      SizedBox(
          width: context.pWidth,
          height: context.pHeight * 0.2,
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            _renderSignOut(),
            _renderAppVersion(),
          ]))
    ]);
  }

  Widget _menuItem(Widget childWidget) {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.only(
          top: context.pHeight * 0.03,
          bottom: context.pHeight * 0.025,
          left: context.pWidth * 0.02,
          right: context.pWidth * 0.02,
        ),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey))),
        child: childWidget);
  }

  Widget _renderClickableArrow(String key, Widget childWidget) {
    return GestureDetector(
        onTap: () {
          if (key == 'PASSWORD') {
            Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        MypageChangePasswordView()));
          } else if (key == 'THRESHOLD') {
            Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        MypageChangeThresholdView()));
          }
        },
        child: childWidget);
  }

  Widget _renderSignOut() {
    return GestureDetector(
        onTapDown: (details) {
          setState(() {
            _isSignOutTapped = true;
          });
        },
        onTapUp: (details) {
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _isSignOutTapped = false;
            });
            _onTapSignOut();
          });
        },
        onTapCancel: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _isSignOutTapped = false;
            });
          });
        },
        child: Text('로그아웃',
            style: TextStyle(
              color: _isSignOutTapped ? Colors.black26 : Colors.black54,
              fontSize: context.pWidth * 0.05,
            )));
  }

  Widget _renderAppVersion() {
    return Padding(
        padding: EdgeInsets.only(
            bottom: context.pHeight * 0.005, top: context.pHeight * 0.025),
        child: Column(children: [
          Text('${String.fromCharCode(0x00A9)} Copyright 2022 Enercle, Inc.',
              style: TextStyle(color: Colors.grey)),
          Text('All Rights Reserved', style: TextStyle(color: Colors.grey))
        ]));
  }
}
