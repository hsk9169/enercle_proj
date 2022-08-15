import 'package:enercle_proj/services/real_api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/widgets/circular_loading.dart';
import 'package:enercle_proj/datatype/data_type.dart';
import 'package:enercle_proj/const/etc.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import 'package:enercle_proj/provider/session_provider.dart';
import 'package:enercle_proj/services/fake_api_service.dart';
import 'package:enercle_proj/utils/number_handler.dart';

class RealtimeMonitoring1dayView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RealtimeMonitoring1dayView();
}

class _RealtimeMonitoring1dayView extends State<RealtimeMonitoring1dayView> {
  List<RealtimeData> _cblLineData = [];
  List<RealtimeData> _powerColumnData = [];

  late ZoomPanBehavior _zoomPanBehavior;

  DateTime _curDateTime = DateTime.now();
  DateTime _selDateTime = DateTime.now();

  bool _isDatePickerTapped = false;
  bool _isLoading = false;

  late Future<bool> _future;

  final FakeApiService _fakeApiService = FakeApiService();
  final RealApiService _realApiService = RealApiService();

  @override
  void initState() {
    _future = _fetch1dayData();
    _zoomPanBehavior = ZoomPanBehavior(
        enablePinching: true, zoomMode: ZoomMode.x, enablePanning: true);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  void _resetData() {
    setState(() {
      _isLoading = false;
      _powerColumnData = [];
      _cblLineData = [];
    });
  }

  Future<bool> _fetch1dayData() async {
    final String date = NumberHandler().datetimeToString(_selDateTime);
    setState(() => _isLoading = true);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final powerCblResponse = await _realApiService.get1hourPowerCbl(
        sessionProvider.customerInfo.customerNumber, date);

    platformProvider.isLoading = false;

    if (powerCblResponse == 'SOCKET_EXCEPTION') {
      platformProvider.popupErrorMessage = '네트워크 오류 발생';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else if (powerCblResponse == 'SERVER_TIMEOUT') {
      platformProvider.popupErrorMessage = '서버 요청시간 만료';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else if (powerCblResponse == 'UNKNOWN_ERROR') {
      platformProvider.popupErrorMessage = '알 수 없는 에러 발생';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else if (powerCblResponse == 'NO_DATA') {
      platformProvider.popupErrorMessage = '데이터 없음';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else {
      if (powerCblResponse == 'BAD_REQUEST') {
        Provider.of<Platform>(context, listen: false).popupErrorMessage =
            '앱 요청 오류 발생';
        Provider.of<Platform>(context, listen: false).isErrorMessagePopup =
            true;
        _resetData();
      } else if (powerCblResponse == 'SERVER_ERROR') {
        Provider.of<Platform>(context, listen: false).popupErrorMessage =
            '서버 오류 발생';
        Provider.of<Platform>(context, listen: false).isErrorMessagePopup =
            true;
        _resetData();
      } else {
        setState(() {
          _isLoading = false;
          powerCblResponse.asMap().forEach((index, element) {
            final hour = int.parse(element.time.substring(0, 2));
            _powerColumnData.add(RealtimeData(
                hour: hour, power: double.parse(element.power1hour)));
            _cblLineData.add(
                RealtimeData(hour: hour, power: double.parse(element.cbl)));
          });
        });
      }
    }
    return true;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _selDateTime = args.value;
    });
  }

  void _onDateSelected() {
    if (_curDateTime != _selDateTime) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
      _resetData();

      setState(() {
        _future = _fetch1dayData();
        _curDateTime = _selDateTime;
      });
    }
    Navigator.pop(context);
  }

  void _onDateSelectCanceled() {
    Navigator.pop(context);
    setState(() => _selDateTime = _curDateTime);
  }

  void _showDatePickerDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: context.pWidth,
                height: context.pHeight * 0.6,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: SfDateRangePicker(
                  initialSelectedDate: _selDateTime,
                  maxDate: DateTime.now(),
                  view: DateRangePickerView.month,
                  headerHeight: context.pHeight * 0.1,
                  headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Colors.grey,
                      textStyle: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontSize: context.pHeight * 0.03,
                        color: Colors.white,
                      )),
                  monthViewSettings: DateRangePickerMonthViewSettings(
                      viewHeaderHeight: context.pHeight * 0.06,
                      dayFormat: 'EEE',
                      viewHeaderStyle: DateRangePickerViewHeaderStyle(
                          textStyle: TextStyle(
                              fontSize: context.pHeight * 0.02,
                              letterSpacing: 1,
                              color: Colors.black54))),
                  selectionTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  onSelectionChanged: _onSelectionChanged,
                  onSubmit: (value) => _onDateSelected(),
                  onCancel: () => _onDateSelectCanceled(),
                  selectionMode: DateRangePickerSelectionMode.single,
                  showActionButtons: true,
                  showNavigationArrow: true,
                  confirmText: '확인',
                  cancelText: '닫기',
                ),
              ));
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
                return Stack(children: [
                  Container(
                      padding: EdgeInsets.only(
                        top: context.pHeight * 0.02,
                        bottom: context.pHeight * 0.03,
                      ),
                      color: Colors.white,
                      child: Column(children: [
                        _renderDatePicker(),
                        _renderOneDayData()
                      ])),
                  _isLoading
                      ? Container(
                          width: context.pWidth,
                          height: context.pHeight * 0.6,
                          alignment: Alignment.center,
                          child: CircularLoading(size: 0.01))
                      : SizedBox()
                ]);
              }));
    });
  }

  Widget _renderDatePicker() {
    return Container(
        padding: EdgeInsets.only(
            top: context.pHeight * 0.01,
            bottom: context.pHeight * 0.05,
            left: context.pWidth * 0.03,
            right: context.pWidth * 0.03),
        alignment: Alignment.center,
        child: GestureDetector(
          child: Container(
              width: context.pWidth,
              padding: EdgeInsets.only(
                top: context.pHeight * 0.01,
                bottom: context.pHeight * 0.01,
                left: context.pWidth * 0.05,
                right: context.pWidth * 0.05,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(2, 2), // changes position of shadow
                  ),
                ],
              ),
              child: SizedBox(
                  height: context.pHeight * 0.03,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month,
                            color: _isDatePickerTapped
                                ? Colors.grey[400]
                                : Colors.black54,
                            size: context.pWidth * 0.05),
                        Text(
                            '${_selDateTime.year}년 ${_selDateTime.month}월 ${_selDateTime.day}일 ${Etc.weekday[_selDateTime.weekday]}요일',
                            style: TextStyle(
                                color: _isDatePickerTapped
                                    ? Colors.grey[400]
                                    : Colors.black54,
                                fontSize: context.pWidth * 0.045,
                                fontWeight: FontWeight.bold)),
                        VerticalDivider(
                            width: 1,
                            color: _isDatePickerTapped
                                ? Colors.grey[400]
                                : Colors.black54),
                        Text('날짜 변경',
                            style: TextStyle(
                                color: _isDatePickerTapped
                                    ? Colors.grey[400]
                                    : Colors.black54,
                                fontSize: context.pWidth * 0.045,
                                fontWeight: FontWeight.bold)),
                      ]))),
          onTapDown: (details) {
            setState(() {
              _isDatePickerTapped = true;
            });
          },
          onTapUp: (details) {
            Future.delayed(const Duration(milliseconds: 100), () {
              setState(() {
                _isDatePickerTapped = false;
              });
              _showDatePickerDialog();
            });
          },
          onTapCancel: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              setState(() {
                _isDatePickerTapped = false;
              });
            });
          },
        ));
  }

  Widget _renderOneDayData() {
    return Container(
        height: context.pHeight * 0.5,
        padding: EdgeInsets.only(),
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(labelFormat: '{value}kW'),
            legend: Legend(position: LegendPosition.bottom, isVisible: true),
            series: <ChartSeries<RealtimeData, String>>[
              ColumnSeries<RealtimeData, String>(
                name: '사용량',
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.blue.withOpacity(0.7)
                    ]),
                dataSource: _powerColumnData,
                xValueMapper: (RealtimeData rtData, _) => '${rtData.hour}시',
                yValueMapper: (RealtimeData rtData, _) => rtData.power,
              ),
              LineSeries<RealtimeData, String>(
                name: 'CBL',
                color: Colors.deepOrange.withOpacity(0.7),
                dataSource: _cblLineData,
                xValueMapper: (RealtimeData rtData, _) => '${rtData.hour}시',
                yValueMapper: (RealtimeData rtData, _) => rtData.power,
              ),
            ],
            tooltipBehavior:
                TooltipBehavior(enable: true, shared: true, opacity: 0.6),
            zoomPanBehavior:
                _powerColumnData.isNotEmpty ? _zoomPanBehavior : null));
  }
}
