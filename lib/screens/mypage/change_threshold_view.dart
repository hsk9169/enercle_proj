import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import 'package:enercle_proj/provider/session_provider.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/const/colors.dart';
import 'package:enercle_proj/utils/number_handler.dart';
import 'package:enercle_proj/services/fake_api_service.dart';
import 'package:enercle_proj/services/real_api_service.dart';

class MypageChangeThresholdView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MypageChangeThresholdView();
}

class _MypageChangeThresholdView extends State<MypageChangeThresholdView> {
  late TextEditingController _textController;
  String _threshold = '';

  final RealApiService _apiService = RealApiService();

  @override
  void initState() {
    _textController = TextEditingController();
    _textController.addListener(_textChanged);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  void _removeText() {
    _textController.text = '';
    _textChanged();
  }

  void _textChanged() {
    setState(() => _threshold = _textController.text);
  }

  void _onPressedSubmit() async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final response = await _apiService.changePeakPower(
        sessionProvider.customerInfo.customerNumber,
        _threshold,
        sessionProvider.customerInfo.isAdmin);

    if (response == 'SOCKET_EXCEPTION') {
      platformProvider.popupErrorMessage = '네트워크 오류 발생';
      platformProvider.isErrorMessagePopup = true;
    } else if (response == 'SERVER_TIMEOUT') {
      platformProvider.popupErrorMessage = '서버 요청시간 만료';
      platformProvider.isErrorMessagePopup = true;
    } else if (response == 'UNKNOWN_ERROR') {
      platformProvider.popupErrorMessage = '알 수 없는 에러 발생';
      platformProvider.isErrorMessagePopup = true;
    } else {
      if (response == 'BAD_REQUEST') {
        platformProvider.popupErrorMessage = '앱 요청 오류 발생';
        platformProvider.isErrorMessagePopup = true;
      } else if (response == 'SERVER_ERROR') {
        platformProvider.popupErrorMessage = '서버 오류 발생';
        platformProvider.isErrorMessagePopup = true;
      } else {
        Provider.of<Session>(context, listen: false)
            .customerInfo
            .powerThreshold5 = _threshold;
        _renderDialog();
        Future.delayed(const Duration(seconds: 2), () async {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    }
  }

  void _renderDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              backgroundColor: Colors.grey[800],
              child: Container(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.check,
                            size: MediaQuery.of(context).size.width * 0.4,
                            color: Colors.white),
                        Text(
                          '최대부하 변경 완료',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.06,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                      ])));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
              color: Colors.white,
              child: SafeArea(
                  top: true,
                  maintainBottomViewPadding: true,
                  child: Container(
                      width: context.pWidth,
                      padding: EdgeInsets.only(
                        top: context.pHeight * 0.01,
                        left: context.pWidth * 0.03,
                        right: context.pWidth * 0.03,
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        _renderTopper(),
                        Padding(
                            padding: EdgeInsets.all(context.pHeight * 0.03)),
                        _renderEditor(),
                      ]))))),
      bottomSheet: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            bottom: context.pHeight * 0.03,
            left: context.pWidth * 0.03,
            right: context.pWidth * 0.03,
          ),
          child: _renderButton()),
    );
  }

  Widget _renderTopper() {
    return SizedBox(
        width: context.pWidth,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios,
                  size: context.pWidth * 0.07, color: Colors.black)),
          Text('5분 최대부하 설정 변경',
              style: TextStyle(
                  fontSize: context.pWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.black))
        ]));
  }

  Widget _renderEditor() {
    final curThreshold = Provider.of<Session>(context, listen: false)
        .customerInfo
        .powerThreshold5;
    final curThresholdStr =
        NumberHandler().makeDoubleFixedPoint(double.parse(curThreshold), 3);
    return Container(
        width: context.pWidth,
        height: context.pHeight * 0.065,
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
            textAlign: TextAlign.center,
            autofocus: true,
            decoration: InputDecoration(
                border: InputBorder.none,
                suffixText: 'kW',
                suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.cancel,
                        color: Colors.grey, size: context.pWidth * 0.05),
                    color: Colors.grey,
                    onPressed: _removeText),
                hintText: '현재 최대부하 : $curThresholdStr'),
            controller: _textController,
            keyboardType: TextInputType.number));
  }

  Widget _renderButton() {
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
            child: Text('설정 변경',
                style: TextStyle(
                    color: Colors.white, fontSize: context.pWidth * 0.06)),
            onPressed: () => _threshold == '' ? null : _onPressedSubmit()));
  }
}
