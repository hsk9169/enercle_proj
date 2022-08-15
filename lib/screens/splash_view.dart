import 'package:enercle_proj/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import 'package:enercle_proj/provider/session_provider.dart';
import 'package:enercle_proj/routes.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/const/colors.dart';
import 'package:enercle_proj/services/encrypted_storage_service.dart';
import 'package:enercle_proj/services/fake_api_service.dart';
import 'package:enercle_proj/services/real_api_service.dart';
import 'package:enercle_proj/utils/number_handler.dart';

class SplashView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashView();
}

class _SplashView extends State<SplashView> {
  final _encryptedStorageService = EncryptedStorageService();

  final _fakeApiService = FakeApiService();
  final _realApiService = RealApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            top: false,
            bottom: false,
            child: Stack(children: [
              Container(
                  width: context.pWidth,
                  height: context.pHeight,
                  color: Color.fromARGB(255, 252, 251, 216)),
              renderLogo(),
            ])));
  }

  void _initData() async {
    await Future.delayed(const Duration(seconds: 2));
    await _encryptedStorageService.initStorage();
    await _getStoredData();
    await _autoSignin();
  }

  Future<void> _getStoredData() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);

    platformProvider.userId = await _encryptedStorageService.readData('userId');
    platformProvider.userPw = await _encryptedStorageService.readData('userPw');
    platformProvider.allowAlarm =
        await _encryptedStorageService.readData('allowAlarm') != 'FALSE'
            ? true
            : false;
    await _encryptedStorageService.saveData(
        'allowAlarm', platformProvider.allowAlarm ? 'TRUE' : 'FALSE');
    platformProvider.userPhoneNum =
        await _encryptedStorageService.readData('userPhoneNum');
    platformProvider.idSaved =
        await _encryptedStorageService.readData('idSaved') != '' ? true : false;
    platformProvider.phoneNumSaved =
        await _encryptedStorageService.readData('phoneNumSaved') != ''
            ? true
            : false;
    platformProvider.autoSignin =
        await _encryptedStorageService.readData('autoSignin') != ''
            ? true
            : false;
    platformProvider.isSignedOut =
        await _encryptedStorageService.readData('isSignedOut') == 'TRUE'
            ? true
            : false;
  }

  Future<void> _autoSignin() async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    String goto = 'signin';

    if (platformProvider.autoSignin && !platformProvider.isSignedOut) {
      final String date = NumberHandler().datetimeToString(DateTime.now());

      dynamic signinReturn = await _realApiService.signIn(
          platformProvider.id, platformProvider.pw, platformProvider.phoneNum);

      if (signinReturn == 'SOCKET_EXCEPTION') {
        _showErrorDialog('네트워크 오류 발생');
      } else if (signinReturn == 'SERVER_TIMEOUT') {
        _showErrorDialog('서버 요청시간 만료');
      } else if (signinReturn == 'UNKNOWN_ERROR') {
        _showErrorDialog('알 수 없는 에러 발생');
      } else {
        if (signinReturn == 'BAD_REQUEST') {
          _showErrorDialog('로그인 정보 입력 오류');
        } else if (signinReturn == 'SERVER_ERROR') {
          _showErrorDialog('서버 오류 발생');
        } else {
          sessionProvider.setCustomerInfo = signinReturn;
          dynamic mitigationReturn = await _realApiService
              .getRealtimeMitigation(platformProvider.id, date);
          if (mitigationReturn != 'BAD_REQUEST' &&
              mitigationReturn != 'SERVER_ERROR' &&
              mitigationReturn != 'NO_DATA') {
            if (mitigationReturn[0].state == 'doing') {
              platformProvider.isMitigating = true;
              platformProvider.mitigationTime = DateTime(
                  int.parse(mitigationReturn[0].date.substring(0, 4)),
                  int.parse(mitigationReturn[0].date.substring(4, 6)),
                  int.parse(mitigationReturn[0].date.substring(6, 8)),
                  int.parse(mitigationReturn[0].time.substring(0, 2)),
                  0);
              platformProvider.mitigationType = mitigationReturn[0].type;
            }
          }
          goto = 'service';
        }
      }
    }

    if (goto == 'signin') {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => SignInView(),
            transitionDuration: Duration.zero,
          ),
        );
      });
    } else if (goto == 'service') {
      Navigator.pushNamedAndRemoveUntil(
          context, Routes.SERVICE, (Route<dynamic> route) => false,
          arguments: 0);
    }
  }

  Widget renderLogo() {
    return Container(
        alignment: Alignment.center,
        height: context.pHeight * 0.8,
        width: context.pWidth,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: context.pWidth,
                  height: context.pHeight * 0.1,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage('assets/images/logo-white-3.png')),
                  )),
              Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
              Text('Value No.01 Solution Provider',
                  style: TextStyle(
                      color: MyColors.mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: context.pWidth * 0.04)),
            ]));
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
