import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/widgets/monitoring_gauge.dart';
import 'package:enercle_proj/widgets/circular_loading.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import 'package:enercle_proj/provider/session_provider.dart';
import 'package:enercle_proj/services/fake_api_service.dart';
import 'package:enercle_proj/services/real_api_service.dart';
import 'package:enercle_proj/utils/number_handler.dart';

class RealtimeMonitoring5minView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RealtimeMonitoring5minView();
}

class _RealtimeMonitoring5minView extends State<RealtimeMonitoring5minView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween1;
  late Animation _colorTween2;
  String _date = '';
  String _time = '';
  String _dateTimeString = 'No Data';
  double _realtimeLastPower = 0;
  double _realtimeYesterdayPower = 0;
  double _cumulatedCurPower = 0;
  double _cumulatedLastPower = 0;

  bool _isLoading = false;
  bool _isRefreshButtonTapped = false;

  late Future<bool> _future;

  final FakeApiService _fakeApiService = FakeApiService();
  final RealApiService _realApiService = RealApiService();

  @override
  void initState() {
    _future = _fetch5minData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _colorTween1 = ColorTween(begin: Colors.red, end: Colors.white)
        .animate(_animationController);
    _colorTween2 = ColorTween(begin: Colors.black, end: Colors.white)
        .animate(_animationController);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _fetch5minData() async {
    setState(() => _isLoading = true);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final dateString = NumberHandler().datetimeToString(DateTime.now());

    if (!platformProvider.isSignedOut) {
      dynamic powerRealtimeResponse = await _realApiService.getRealtimePower(
          sessionProvider.customerInfo.customerNumber, dateString);

      // Unlock Screen Touch
      platformProvider.isLoading = false;

      if (powerRealtimeResponse == 'SOCKET_EXCEPTION') {
        platformProvider.popupErrorMessage = '네트워크 오류 발생';
        platformProvider.isErrorMessagePopup = true;
        _resetData();
      } else if (powerRealtimeResponse == 'SERVER_TIMEOUT') {
        platformProvider.popupErrorMessage = '서버 요청시간 만료';
        platformProvider.isErrorMessagePopup = true;
        _resetData();
      } else if (powerRealtimeResponse == 'UNKNOWN_ERROR') {
        platformProvider.popupErrorMessage = '알 수 없는 에러 발생';
        platformProvider.isErrorMessagePopup = true;
        _resetData();
      } else {
        if (powerRealtimeResponse == 'BAD_REQUEST') {
          platformProvider.popupErrorMessage = '앱 요청 오류 발생';
          platformProvider.isErrorMessagePopup = true;
          _resetData();
        } else if (powerRealtimeResponse == 'SERVER_ERROR') {
          platformProvider.popupErrorMessage = '서버 오류 발생';
          platformProvider.isErrorMessagePopup = true;
          _resetData();
        } else if (powerRealtimeResponse == 'NO_DATA') {
          platformProvider.popupErrorMessage = '데이터 없음';
          platformProvider.isErrorMessagePopup = true;
          _resetData();
        } else {
          setState(() {
            _isLoading = false;
            _realtimeLastPower = NumberHandler().makeDoubleFixedPoint(
                double.parse(powerRealtimeResponse.powerLast5min), 2);
            _realtimeYesterdayPower = NumberHandler().makeDoubleFixedPoint(
                double.parse(powerRealtimeResponse.powerYesterday5min), 2);
            _date = powerRealtimeResponse.date;
            _time = powerRealtimeResponse.time;
            _cumulatedCurPower = NumberHandler().makeDoubleFixedPoint(
                double.parse(powerRealtimeResponse.powerLastSum), 2);
            _cumulatedLastPower = NumberHandler().makeDoubleFixedPoint(
                double.parse(powerRealtimeResponse.powerYesterdaySum), 2);
            _dateTimeString = NumberHandler().makeCurTimeString(_date, _time);
          });
        }
      }
    }
    return true;
  }

  void _refreshData() {
    Provider.of<Platform>(context, listen: false).isLoading = true;
    setState(() {
      _realtimeLastPower = 0;
      _realtimeYesterdayPower = 0;
      _cumulatedCurPower = 0;
      _cumulatedLastPower = 0;
    });
    _future = _fetch5minData();
  }

  void _resetData() {
    setState(() {
      _isLoading = false;
      _realtimeLastPower = 0;
      _realtimeYesterdayPower = 0;
      _date = '';
      _time = '';
      _cumulatedCurPower = 0;
      _dateTimeString = 'No Data';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
          child: FutureBuilder(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return Container(
                    padding: EdgeInsets.only(
                        top: context.pHeight * 0.01,
                        bottom: context.pHeight * 0.02,
                        left: context.pWidth * 0.03,
                        right: context.pWidth * 0.03),
                    color: Colors.white,
                    child: Column(children: [
                      _renderCurrentTime(),
                      Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
                      Stack(alignment: Alignment.center, children: [
                        MonitoringGauge(
                          title: '전일 총 사용량 대비 금일 사용률',
                          gradientColors: const [
                            Color.fromARGB(255, 140, 193, 26),
                            Color.fromARGB(255, 251, 255, 0),
                            Color.fromARGB(255, 255, 217, 0),
                            Color.fromARGB(255, 255, 145, 0),
                            Color.fromARGB(255, 255, 0, 0),
                          ],
                          curValue: _cumulatedCurPower,
                          lastValue: _cumulatedLastPower,
                          subText: '전일 누적 전력사용량',
                        ),
                        _isLoading ? CircularLoading(size: 0.01) : SizedBox()
                      ]),
                      Padding(padding: EdgeInsets.all(context.pHeight * 0.02)),
                      Stack(alignment: Alignment.center, children: [
                        MonitoringGauge(
                          title: '전일 동시간대 5분 사용량 대비 사용률',
                          gradientColors: const [
                            Color.fromARGB(255, 43, 204, 137),
                            Color.fromARGB(255, 43, 204, 196),
                            Color.fromARGB(255, 43, 153, 204),
                            Color.fromARGB(255, 43, 99, 204),
                            Color.fromARGB(255, 43, 107, 243)
                          ],
                          curValue: _realtimeLastPower,
                          lastValue: _realtimeYesterdayPower,
                          subText: '전일 5분 전력사용량',
                        ),
                        _isLoading ? CircularLoading(size: 0.01) : SizedBox()
                      ]),
                    ]));
              }));
    });
  }

  Widget _renderCurrentTime() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Row(children: [
        AnimatedBuilder(
            animation: _colorTween1,
            builder: (context, child) => Container(
                padding: EdgeInsets.all(context.pHeight * 0.006),
                decoration: BoxDecoration(
                    border: Border.all(color: _colorTween1.value, width: 1),
                    borderRadius: BorderRadius.circular(30)),
                child: Text('LIVE',
                    style: TextStyle(
                        color: _colorTween1.value,
                        fontWeight: FontWeight.bold,
                        fontSize: context.pHeight * 0.015)))),
        Padding(padding: EdgeInsets.all(context.pHeight * 0.007)),
        AnimatedBuilder(
            animation: _colorTween1,
            builder: (context, child) => Text(_dateTimeString,
                style: TextStyle(
                    color: _colorTween2.value,
                    fontWeight: FontWeight.bold,
                    fontSize: context.pHeight * 0.02)))
      ]),
      _renderRefreshButton()
    ]);
  }

  Widget _renderRefreshButton() {
    return GestureDetector(
        child: Container(
            width: context.pHeight * 0.08,
            padding: EdgeInsets.all(context.pWidth * 0.01),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(3, 3), // changes position of shadow
                ),
              ],
            ),
            child: Icon(Icons.refresh,
                size: context.pHeight * 0.03,
                color:
                    _isRefreshButtonTapped ? Colors.grey[400] : Colors.black)),
        onTapDown: (details) {
          setState(() {
            _isRefreshButtonTapped = true;
          });
        },
        onTapUp: (details) {
          _refreshData();
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _isRefreshButtonTapped = false;
            });
          });
        },
        onTapCancel: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _isRefreshButtonTapped = false;
            });
          });
        });
  }
}
