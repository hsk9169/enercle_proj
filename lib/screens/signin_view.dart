import 'package:enercle_proj/models/customer_model.dart';
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
import 'package:enercle_proj/models/mitigation_realtime_model.dart';

class SignInView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInView();
}

class _SignInView extends State<SignInView>
    with SingleTickerProviderStateMixin {
  final Duration _animateDuration = const Duration(milliseconds: 1000);
  late Animation<double> _animation;
  late AnimationController _controller;

  late TextEditingController _textIdController;
  late TextEditingController _textPwController;
  late TextEditingController _textPhoneNumController;

  final _fakeApiService = FakeApiService();
  final _realApiService = RealApiService();

  String _id = '';
  String _pw = '';
  String _phoneNum = '';

  bool _checkRememberId = false;
  bool _checkRememberPhoneNum = false;
  bool _checkAutoSignin = false;

  final _encryptedStorageService = EncryptedStorageService();

  @override
  void initState() {
    _controller = AnimationController(
      value: 1,
      vsync: this,
      duration: _animateDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _animation.addListener(() {
      setState(() {});
    });
    _textIdController = TextEditingController(
        text: Provider.of<Platform>(context, listen: false).id);
    _textIdController.addListener(_idChanged);
    _textPwController = TextEditingController(
        text: Provider.of<Platform>(context, listen: false).pw);
    _textPwController.addListener(_pwChanged);
    _textPhoneNumController = TextEditingController(
        text: Provider.of<Platform>(context, listen: false).phoneNum);
    _textPhoneNumController.addListener(_phoneNumChanged);
    _getDelay();
    super.initState();
  }

  void _getDelay() async {
    await _encryptedStorageService.initStorage();
    _initData();
    await Future.delayed(const Duration(seconds: 1));
    _controller.reverse();
  }

  void _initData() async {
    setState(() {
      _id = Provider.of<Platform>(context, listen: false).id;
      _pw = Provider.of<Platform>(context, listen: false).pw;
      _phoneNum = Provider.of<Platform>(context, listen: false).phoneNum;
      _checkRememberId = Provider.of<Platform>(context, listen: false).idSaved;
      _checkRememberPhoneNum =
          Provider.of<Platform>(context, listen: false).phoneNumSaved;
      _checkAutoSignin =
          Provider.of<Platform>(context, listen: false).autoSignin;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _idChanged() {
    setState(() => _id = _textIdController.text);
  }

  void _removeIdText() {
    _textIdController.text = '';
    _idChanged();
  }

  void _pwChanged() {
    setState(() => _pw = _textPwController.text);
  }

  void _removePwText() {
    _textPwController.text = '';
    _pwChanged();
  }

  void _phoneNumChanged() {
    setState(() => _phoneNum = _textPhoneNumController.text);
  }

  void _removePhoneNumText() {
    _textPhoneNumController.text = '';
    _phoneNumChanged();
  }

  void _onCheckRememberId(bool val) {
    setState(() => _checkRememberId = val);
  }

  void _onCheckRememberPhoneNum(bool val) {
    setState(() => _checkRememberPhoneNum = val);
  }

  void _onCheckAutoSignin(bool val) {
    setState(() => _checkAutoSignin = val);
  }

  void _onPressedSignIn() async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final String date = NumberHandler().datetimeToString(DateTime.now());

    dynamic signinReturn = await _realApiService.signIn(_id, _pw, _phoneNum);

    if (signinReturn == 'SOCKET_EXCEPTION') {
      _showErrorDialog('네트워크 오류 발생');
    } else if (signinReturn == 'TIMEOUT_EXCEPTION') {
      _showErrorDialog('서버 요청시간 만료');
    } else if (signinReturn == 'UNKNOWN_ERROR') {
      _showErrorDialog('알 수 없는 에러 발생');
    } else {
      if (signinReturn == 'BAD_REQUEST') {
        _showErrorDialog('로그인 정보 입력 오류');
        return;
      } else if (signinReturn == 'SERVER_ERROR') {
        _showErrorDialog('서버 오류 발생');
        return;
      } else {
        sessionProvider.setCustomerInfo = signinReturn;
        dynamic mitigationReturn =
            await _realApiService.getRealtimeMitigation(_id, date);
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

        platformProvider.userId = _id;
        platformProvider.userPw = _pw;
        platformProvider.userPhoneNum = _phoneNum;

        // Setting auto signin
        if (_checkAutoSignin) {
          await _encryptedStorageService.saveData('autoSignin', 'YES');
          await _encryptedStorageService.saveData('userId', _id);
          await _encryptedStorageService.saveData('userPw', _pw);
          await _encryptedStorageService.saveData('userPhoneNum', _phoneNum);
        } else {
          // Changing not to auto signin
          if (platformProvider.autoSignin) {
            await _encryptedStorageService.removeData('autoSignin');
            await _encryptedStorageService.removeData('userPw');
          }
          if (_checkRememberId) {
            await _encryptedStorageService.saveData('idSaved', 'YES');
            await _encryptedStorageService.saveData('userId', _id);
          } else if (platformProvider.idSaved) {
            await _encryptedStorageService.removeData('idSaved');
            await _encryptedStorageService.removeData('userId');
          }
          if (_checkRememberPhoneNum) {
            await _encryptedStorageService.saveData('phoneNumSaved', 'YES');
            await _encryptedStorageService.saveData('userPhoneNum', _phoneNum);
          } else if (platformProvider.phoneNumSaved) {
            await _encryptedStorageService.removeData('phoneNumSaved');
            await _encryptedStorageService.removeData('userPhoneNum');
          }
        }

        Navigator.pushNamedAndRemoveUntil(
            context, Routes.SERVICE, (Route<dynamic> route) => false,
            arguments: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
              child: Stack(children: [
            Container(
              width: context.pWidth,
              height: context.pHeight,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 252, 251, 216),
                  border:
                      Border.all(color: Color.fromARGB(255, 252, 251, 216))),
            ),
            renderLogo(),
            AnimatedOpacity(
                opacity: 1 - _animation.value,
                duration: _animateDuration,
                child: Container(
                    width: context.pWidth,
                    padding: EdgeInsets.only(
                      top: context.pHeight * 0.3,
                      left: context.pWidth * 0.05,
                      right: context.pWidth * 0.05,
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          renderIdInput(),
                          Padding(
                              padding: EdgeInsets.all(context.pWidth * 0.03)),
                          renderPhoneNumInput(),
                          Padding(
                              padding: EdgeInsets.all(context.pWidth * 0.03)),
                          renderPwInput(),
                          Padding(
                              padding: EdgeInsets.all(context.pWidth * 0.03)),
                          renderCheckBox()
                        ])))
          ]))),
      bottomSheet: Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 252, 251, 216),
              border: Border.all(color: Color.fromARGB(255, 252, 251, 216))),
          padding: EdgeInsets.only(
            bottom: context.pHeight * 0.03,
            left: context.pWidth * 0.03,
            right: context.pWidth * 0.03,
          ),
          child: AnimatedOpacity(
              opacity: 1 - _animation.value,
              duration: _animateDuration,
              child: renderSignIn())),
    );
  }

  Widget renderLogo() {
    return Container(
        alignment: Alignment.center,
        height: context.pHeight * 0.8 * (_animation.value / 2 + 0.5),
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

  Widget renderIdInput() {
    return Container(
        width: context.pWidth,
        height: context.pHeight * 0.06,
        padding: EdgeInsets.only(
          left: context.pWidth * 0.02,
          right: context.pWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.3),
        ),
        alignment: Alignment.center,
        child: TextField(
            textAlignVertical: TextAlignVertical.center,
            autofocus: false,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.person_outline,
                    color: Colors.grey, size: context.pWidth * 0.05),
                suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.cancel,
                        color: Colors.grey, size: context.pWidth * 0.05),
                    color: Colors.grey,
                    onPressed: _removeIdText),
                hintText: '아이디',
                hintStyle: TextStyle(color: Colors.grey)),
            controller: _textIdController,
            keyboardType: TextInputType.text));
  }

  Widget renderPwInput() {
    return Container(
        width: context.pWidth,
        height: context.pHeight * 0.06,
        padding: EdgeInsets.only(
          left: context.pWidth * 0.02,
          right: context.pWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.3),
        ),
        alignment: Alignment.center,
        child: TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            textAlignVertical: TextAlignVertical.center,
            autofocus: false,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.lock_outline,
                    color: Colors.grey, size: context.pWidth * 0.05),
                suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.cancel,
                        color: Colors.grey, size: context.pWidth * 0.05),
                    color: Colors.grey,
                    onPressed: _removePwText),
                hintText: '패스워드',
                hintStyle: TextStyle(color: Colors.grey)),
            controller: _textPwController,
            keyboardType: TextInputType.text));
  }

  Widget renderPhoneNumInput() {
    return Container(
        width: context.pWidth,
        height: context.pHeight * 0.06,
        padding: EdgeInsets.only(
          left: context.pWidth * 0.02,
          right: context.pWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.3),
        ),
        alignment: Alignment.center,
        child: TextField(
            enableSuggestions: false,
            autocorrect: false,
            textAlignVertical: TextAlignVertical.center,
            autofocus: false,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.phone,
                    color: Colors.grey, size: context.pWidth * 0.05),
                suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.cancel,
                        color: Colors.grey, size: context.pWidth * 0.05),
                    color: Colors.grey,
                    onPressed: _removePhoneNumText),
                hintText: '전화번호',
                hintStyle: TextStyle(color: Colors.grey)),
            controller: _textPhoneNumController,
            keyboardType: TextInputType.number));
  }

  Widget renderCheckBox() {
    return SizedBox(
        width: context.pWidth,
        child: Row(children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Checkbox(
                onChanged: (value) => _onCheckRememberId(value!),
                value: _checkRememberId,
                side: BorderSide(
                    color: Colors.grey, width: context.pWidth * 0.0015)),
            Text('아이디 저장',
                style: TextStyle(
                    color: Colors.grey, fontSize: context.pWidth * 0.035))
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Checkbox(
                onChanged: (value) => _onCheckRememberPhoneNum(value!),
                value: _checkRememberPhoneNum,
                side: BorderSide(
                    color: Colors.grey, width: context.pWidth * 0.0015)),
            Text('전화번호 저장',
                style: TextStyle(
                    color: Colors.grey, fontSize: context.pWidth * 0.035))
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Checkbox(
                onChanged: (value) => _onCheckAutoSignin(value!),
                value: _checkAutoSignin,
                side: BorderSide(
                    color: Colors.grey, width: context.pWidth * 0.0015)),
            Text('자동 로그인',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: context.pWidth * 0.035,
                ))
          ])
        ]));
  }

  Widget renderSignIn() {
    return Container(
        width: context.pWidth,
        height: context.pHeight * 0.065,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            colors: [MyColors.mainColor, Color.fromARGB(255, 195, 224, 31)],
          ),
        ),
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                shadowColor: MaterialStateProperty.all(Colors.transparent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )),
            child: Text('로그인',
                style: TextStyle(
                    color: Colors.white, fontSize: context.pWidth * 0.05)),
            onPressed: () => _id == '' || _pw == '' || _phoneNum == ''
                ? null
                : _onPressedSignIn()));
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
