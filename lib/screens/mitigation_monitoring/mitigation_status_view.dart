import 'dart:async';
import 'package:enercle_proj/datatype/data_type.dart';
import 'package:enercle_proj/models/mitigation_realtime_model.dart';
import 'package:enercle_proj/services/real_api_service.dart';
import 'package:enercle_proj/widgets/countdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:enercle_proj/const/colors.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/widgets/circular_loading.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import 'package:enercle_proj/provider/session_provider.dart';
import 'package:enercle_proj/utils/number_handler.dart';
import 'package:enercle_proj/services/fake_api_service.dart';
import 'package:enercle_proj/utils/color_handler.dart';

class MitigationStatusView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MitigationStatusView();
}

class _MitigationStatusView extends State<MitigationStatusView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween;

  final DateTime _curDatetime = DateTime.now();
  DateTime _alarmDatetime = DateTime.now();

  Timer? _timer;

  int _minRemain = 0;
  int _secRemain = 0;
  int _totalSec = 0;

  List<FulfillmentData> _fulfillment = [];

  bool _isLoading = false;
  bool _isTimeSet = false;

  late Future<bool> _future;

  final FakeApiService _fakeApiService = FakeApiService();
  final RealApiService _realApiService = RealApiService();

  List<MitigationRealtimeModel> _mitigationList = [];
  MitigationRealtimeModel _curMitigation = MitigationRealtimeModel.reset();
  List<FulfillRateData> _historyData = [];

  @override
  void initState() {
    _initRemainTime();
    _future = _fetchMitigationData();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (Timer timer) => _updateTime());

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _colorTween =
        ColorTween(begin: Colors.red, end: Colors.red.withOpacity(0.2))
            .animate(_animationController);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (Provider.of<Platform>(context, listen: false).isMitigating) {
        Provider.of<Platform>(context, listen: false).isLoading = true;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _initRemainTime() {
    final curTime = DateTime.now();
    int minPast = curTime.minute -
        Provider.of<Platform>(context, listen: false).mitigationTime.minute;
    int secPast = curTime.second -
        Provider.of<Platform>(context, listen: false).mitigationTime.second;
    if (minPast < 0) {
      minPast = 60 + minPast;
    }
    setState(() {
      _isTimeSet = true;
      _totalSec = 3600 - (minPast * 60 + secPast);
      _minRemain = _totalSec ~/ 60;
      _secRemain = _totalSec % 60;
    });
  }

  Future<bool> _fetchMitigationData() async {
    setState(() => _isLoading = true);
    final dateString = NumberHandler().datetimeToString(DateTime.now());
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final mitigationResponse = await _realApiService.getRealtimeMitigation(
        sessionProvider.customerInfo.customerNumber, dateString);

    platformProvider.isLoading = false;

    if (mitigationResponse == 'SOCKET_EXCEPTION') {
      platformProvider.popupErrorMessage = '네트워크 오류 발생';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else if (mitigationResponse == 'SERVER_TIMEOUT') {
      platformProvider.popupErrorMessage = '서버 요청시간 만료';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else if (mitigationResponse == 'UNKNOWN_ERROR') {
      platformProvider.popupErrorMessage = '알 수 없는 에러 발생';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else {
      if (mitigationResponse == 'BAD_REQUEST') {
        platformProvider.popupErrorMessage = '앱 요청 오류 발생';
        platformProvider.isErrorMessagePopup = true;
        _resetData();
      } else if (mitigationResponse == 'SERVER_ERROR') {
        platformProvider.popupErrorMessage = '서버 오류 발생';
        platformProvider.isErrorMessagePopup = true;
        _resetData();
      } else if (mitigationResponse == 'NO_DATA') {
        platformProvider.popupErrorMessage = '데이터 없음';
        platformProvider.isErrorMessagePopup = true;
        _resetData();
      } else {
        setState(() {
          mitigationResponse.forEach((element) {
            _mitigationList.add(element);
            _historyData.add(FulfillRateData(
                cat:
                    '${element.startTime.substring(0, 2)}~${element.endTime.substring(0, 2)}시',
                rate: int.parse(element.fulfillmentExpect)));
          });
          _fulfillment = [
            FulfillmentData(
                cat: '예상 이행량',
                fulfillment: mitigationResponse[0].mitigationExpect),
            FulfillmentData(
                cat: '현재 이행량',
                fulfillment: mitigationResponse[0].mitigationTotal),
          ];
          _curMitigation = _mitigationList.last;
          _isLoading = false;
        });
      }
    }

    return true;
  }

  void _resetData() {
    setState(() {
      _isLoading = false;
      _mitigationList = [];
      _historyData = [];
      _fulfillment = [];
      _curMitigation = MitigationRealtimeModel.reset();
    });
  }

  void _updateTime() {
    if (_minRemain == 0 && _secRemain == 0) {
      Provider.of<Platform>(context, listen: false).isMitigating = false;
      setState(() {
        _isTimeSet = false;
      });
    } else {
      setState(() {
        _totalSec--;
        _minRemain = _totalSec ~/ 60;
        _secRemain = _totalSec % 60;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<Platform>(context, listen: true).isMitigating &&
        !_isTimeSet) {
      _initRemainTime();
      _future = _fetchMitigationData();
    }
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(
                  top: context.pHeight * 0.01,
                  bottom: context.pHeight * 0.02,
                  left: context.pWidth * 0.03,
                  right: context.pWidth * 0.03),
              color: Colors.white,
              child: Column(children: [
                Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
                _renderMitigationAlertStatus(),
                Provider.of<Platform>(context, listen: true).isMitigating
                    ? _renderCurrentFulfillment()
                    : SizedBox()
              ])));
    });
  }

  Widget _renderMitigationAlertStatus() {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.only(
          left: context.pWidth * 0.05,
          right: context.pWidth * 0.05,
          top: context.pWidth * 0.05,
          bottom: context.pWidth * 0.05,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(3, 3))
          ],
        ),
        child: Column(children: [
          Align(
              alignment: Alignment.topLeft,
              child: Text('감축경보 발령 상태',
                  style: TextStyle(
                      fontSize: context.pHeight * 0.025,
                      fontWeight: FontWeight.bold))),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
          Provider.of<Platform>(context, listen: true).isMitigating
              ? _renderMitigationAlarm()
              : _renderNoAlarm()
        ]));
  }

  Widget _renderNoAlarm() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt,
              color: Colors.green, size: context.pHeight * 0.05),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.005)),
          Text('감축경보 발령 없음',
              style: TextStyle(
                  fontSize: context.pHeight * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.green))
        ]);
  }

  Widget _renderMitigationAlarm() {
    return Column(children: [
      AnimatedBuilder(
          animation: _colorTween,
          builder: (context, child) => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.report,
                        color: _colorTween.value, size: context.pHeight * 0.05),
                    Padding(padding: EdgeInsets.all(context.pHeight * 0.005)),
                    Text('감축경보 발령 중',
                        style: TextStyle(
                            fontSize: context.pHeight * 0.04,
                            fontWeight: FontWeight.bold,
                            color: _colorTween.value)),
                  ])),
      Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
      Countdown(
          targetDatetime: _alarmDatetime, min: _minRemain, sec: _secRemain)
    ]);
  }

  Widget _renderCurrentFulfillment() {
    final session = Provider.of<Session>(context, listen: false);
    Color rateColor = Colors.black;
    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == true) {
            rateColor = ColorHandler()
                .determineFulfillmentRate(_curMitigation.fulfillmentExpect);
          }
          return Column(children: [
            // Fulfillment Rate Graph
            Padding(
                padding: EdgeInsets.only(top: context.pHeight * 0.04),
                child: Stack(children: [
                  Container(
                      width: context.pWidth,
                      padding: EdgeInsets.only(
                        top: context.pWidth * 0.05,
                        bottom: context.pWidth * 0.05,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: Offset(3, 3))
                        ],
                      ),
                      child: Column(children: [
                        Padding(
                            padding: EdgeInsets.only(
                              left: context.pWidth * 0.05,
                              right: context.pWidth * 0.05,
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('감축 이행 상태',
                                      style: TextStyle(
                                          fontSize: context.pHeight * 0.025,
                                          fontWeight: FontWeight.bold)),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '고객사: ${session.customerInfo.customerName}',
                                            style: TextStyle(
                                                fontSize:
                                                    context.pHeight * 0.018)),
                                        Text(
                                            '계약용량: ${_curMitigation.contractPower}',
                                            style: TextStyle(
                                                fontSize:
                                                    context.pHeight * 0.018)),
                                        Text(
                                            'CBL: ${_curMitigation.cbl.toString()}kWh',
                                            style: TextStyle(
                                                fontSize:
                                                    context.pHeight * 0.018)),
                                      ])
                                ])),
                        Padding(
                            padding: EdgeInsets.all(context.pHeight * 0.015)),
                        Padding(
                            padding: EdgeInsets.only(
                              left: context.pWidth * 0.05,
                              right: context.pWidth * 0.05,
                            ),
                            child: SizedBox(
                                height: context.pHeight * 0.045,
                                child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('예상 이행률 : ',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        context.pHeight * 0.04,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                '${_curMitigation.fulfillmentExpect}%',
                                                style: TextStyle(
                                                    color: rateColor,
                                                    fontSize:
                                                        context.pHeight * 0.04,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ]),
                                      Container(
                                          width: context.pHeight * 0.32,
                                          height: context.pHeight * 0.045,
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: rateColor
                                                          .withOpacity(0.4),
                                                      width: context.pHeight *
                                                          0.01))))
                                    ]))),
                        Padding(
                            padding: EdgeInsets.all(context.pHeight * 0.015)),
                        Container(
                            height: context.pHeight * 0.25,
                            padding:
                                EdgeInsets.only(right: context.pWidth * 0.06),
                            child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                primaryYAxis: NumericAxis(
                                    interval: 1000, labelFormat: '{value}kWh'),
                                enableSideBySideSeriesPlacement: false,
                                legend: Legend(
                                    position: LegendPosition.bottom,
                                    isVisible: true),
                                series: <ChartSeries>[
                                  BarSeries<FulfillmentData, String>(
                                      name: '계약용량',
                                      color: Colors.grey.withOpacity(0.5),
                                      width: context.pHeight * 0.0005,
                                      dataSource: _fulfillment,
                                      xValueMapper: (FulfillmentData data, _) =>
                                          data.cat,
                                      yValueMapper: (FulfillmentData data, _) =>
                                          int.parse(
                                              _curMitigation.contractPower),
                                      dataLabelSettings: DataLabelSettings(
                                          isVisible: false,
                                          alignment: ChartAlignment.far,
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold))),
                                  BarSeries<FulfillmentData, String>(
                                      name: '이행량',
                                      color: MyColors.mainColor,
                                      width: context.pHeight * 0.0005,
                                      dataSource: _fulfillment,
                                      xValueMapper: (FulfillmentData data, _) =>
                                          data.cat,
                                      yValueMapper: (FulfillmentData data, _) =>
                                          data.fulfillment,
                                      dataLabelSettings: DataLabelSettings(
                                          isVisible: true,
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold))),
                                ]))
                      ])),
                  _isLoading
                      ? Container(
                          width: context.pWidth,
                          height: context.pHeight * 0.53,
                          alignment: Alignment.center,
                          child: CircularLoading(size: 0.007))
                      : SizedBox()
                ])),

            // Timeline Graph
            Padding(
                padding: EdgeInsets.only(top: context.pHeight * 0.04),
                child: Container(
                    width: context.pWidth,
                    padding: EdgeInsets.only(
                      top: context.pWidth * 0.05,
                      bottom: context.pWidth * 0.05,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: Offset(3, 3))
                      ],
                    ),
                    child: Column(children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: context.pWidth * 0.05,
                          right: context.pWidth * 0.05,
                        ),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('최근 감축 이행률',
                                style: TextStyle(
                                    fontSize: context.pHeight * 0.025,
                                    fontWeight: FontWeight.bold))),
                      ),
                      Padding(padding: EdgeInsets.all(context.pHeight * 0.02)),
                      SizedBox(
                          width: context.pWidth,
                          height: context.pHeight * 0.3,
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(labelFormat: '{value}%'),
                            series: <CartesianSeries>[
                              ColumnSeries<FulfillRateData, String>(
                                  name: '이행률',
                                  pointColorMapper: (FulfillRateData data,
                                          index) =>
                                      ColorHandler().determineFulfillmentRate(
                                          data.rate.toString()),
                                  dataSource: _historyData,
                                  xValueMapper: (FulfillRateData data, _) =>
                                      data.cat,
                                  yValueMapper: (FulfillRateData data, _) =>
                                      data.rate,
                                  dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      alignment: ChartAlignment.center,
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))),
                            ],
                            tooltipBehavior: TooltipBehavior(
                                enable: true, shared: true, opacity: 0.6),
                          ))
                    ])))
          ]);
        });
  }
}
