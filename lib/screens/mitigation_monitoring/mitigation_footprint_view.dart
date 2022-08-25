import 'package:enercle_proj/services/real_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:enercle_proj/const/colors.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/datatype/data_type.dart';
import 'package:enercle_proj/widgets/circular_loading.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import 'package:enercle_proj/provider/session_provider.dart';
import 'package:enercle_proj/services/fake_api_service.dart';
import 'package:enercle_proj/models/fulfillment_history_model.dart';
import 'package:enercle_proj/utils/number_handler.dart';

class MitigationFootprintView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MitigationFootprintView();
}

class _MitigationFootprintView extends State<MitigationFootprintView> {
  DateTime _curDateTime = DateTime.now();
  DateTime _selDateTime = DateTime.now();

  bool _isDatePickerTapped = false;

  late Future<bool> _future;

  final FakeApiService _fakeApiService = FakeApiService();
  final RealApiService _realApiService = RealApiService();

  List<FulfillmentHistoryModel> _annualFulfillmentData = [];
  List<List<FulfillmentData>> _chartData = [];

  List<bool> _annualFulfillmentItemHeightStatus = [];

  @override
  void initState() {
    _future = _fetchAnnualData();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _fetchAnnualData() async {
    final String date = NumberHandler().datetimeToString(_selDateTime);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    //final annualFulfillment = await _fakeApiService.getAnnualFulfillment(
    //    sessionProvider.customerInfo.customerNumber, 'date');
    final annualFulfillmentResponse =
        await _realApiService.getAnnualFulfillment(
            sessionProvider.customerInfo.customerNumber, date.substring(0, 4));

    platformProvider.isLoading = false;

    if (annualFulfillmentResponse == 'SOCKET_EXCEPTION') {
      platformProvider.popupErrorMessage = '네트워크 오류 발생';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else if (annualFulfillmentResponse == 'SERVER_TIMEOUT') {
      platformProvider.popupErrorMessage = '서버 요청시간 만료';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else if (annualFulfillmentResponse == 'UNKNOWN_ERROR') {
      platformProvider.popupErrorMessage = '알 수 없는 에러 발생';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else if (annualFulfillmentResponse == 'NO_DATA') {
      platformProvider.popupErrorMessage = '데이터 없음';
      platformProvider.isErrorMessagePopup = true;
      _resetData();
    } else {
      if (annualFulfillmentResponse == 'BAD_REQUEST') {
        platformProvider.popupErrorMessage = '앱 요청 오류 발생';
        platformProvider.isErrorMessagePopup = true;
        _resetData();
      } else if (annualFulfillmentResponse == 'SERVER_ERROR') {
        platformProvider.popupErrorMessage = '서버 오류 발생';
        platformProvider.isErrorMessagePopup = true;
        _resetData();
      } else {
        setState(() {
          annualFulfillmentResponse.forEach((element) {
            _annualFulfillmentData.add(element);
            _annualFulfillmentItemHeightStatus.add(false);
            _chartData.add([
              FulfillmentData(
                  cat: '사용량', fulfillment: double.parse(element.power)),
              FulfillmentData(
                  cat: 'CBL', fulfillment: double.parse(element.cbl)),
              FulfillmentData(
                  cat: '감축량',
                  fulfillment: double.parse(element.mitigationPower)),
            ]);
          });
        });
      }
    }
    return true;
  }

  void _resetData() {
    setState(() {
      _annualFulfillmentData = [];
      _annualFulfillmentItemHeightStatus = [];
      _chartData = [];
    });
  }

  void _onSelectionChanged(int value) {
    setState(() {
      _selDateTime = DateTime(DateTime.now().year - value);
    });
  }

  void _onDateSelected() {
    if (_curDateTime != _selDateTime) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
      _resetData();

      setState(() {
        _future = _fetchAnnualData();
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
                  width: context.pWidth * 0.1,
                  height: context.pHeight * 0.35,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(children: [
                    Expanded(
                        flex: 4,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem:
                                  DateTime.now().year - _selDateTime.year),
                          children: _getYearWidgetList(),
                          onSelectedItemChanged: (value) =>
                              _onSelectionChanged(value),
                          itemExtent: 50,
                          diameterRatio: 0.8,
                          useMagnifier: true,
                          magnification: 1.3,
                        )),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding:
                                EdgeInsets.only(right: context.pWidth * 0.05),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                      onTap: _onDateSelectCanceled,
                                      child: Text('닫기',
                                          style: TextStyle(
                                              fontSize: context.pHeight * 0.02,
                                              color: MyColors.mainColor))),
                                  Padding(
                                      padding: EdgeInsets.all(
                                          context.pWidth * 0.03)),
                                  GestureDetector(
                                      onTap: _onDateSelected,
                                      child: Text('확인',
                                          style: TextStyle(
                                              fontSize: context.pHeight * 0.02,
                                              color: MyColors.mainColor))),
                                ])))
                  ])));
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
                      left: context.pWidth * 0.03,
                      right: context.pWidth * 0.03,
                      top: context.pHeight * 0.02,
                      bottom: context.pHeight * 0.03,
                    ),
                    color: Colors.white,
                    child: Column(children: [
                      _renderDatePicker(),
                      _annualFulfillmentData.isNotEmpty
                          ? _renderAnnualData()
                          : const SizedBox()
                    ]));
              }));
    });
  }

  Widget _renderDatePicker() {
    return Container(
        padding: EdgeInsets.only(
            top: context.pHeight * 0.01, bottom: context.pHeight * 0.05),
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
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: SizedBox(
                  height: context.pHeight * 0.03,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month,
                            color: _isDatePickerTapped
                                ? Colors.grey[400]
                                : Colors.black54,
                            size: context.pWidth * 0.05),
                        Text('${_curDateTime.year}년',
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
                        Text('이행 이력 조회 년도 변경',
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

  List<Widget> _getYearWidgetList() {
    final thisYear = DateTime.now().year;
    return List.generate(
        thisYear - 2000 + 1,
        (index) => Center(
                child: Text(
              '${(thisYear - index)} 년',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            )));
  }

  Widget _renderAnnualData() {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(
          context.pWidth * 0.05,
        ),
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
        child: Column(
            children: List.generate(
                _annualFulfillmentData.length,
                (index) => _renderFulfillmentData(
                    _annualFulfillmentData[index], index))));
  }

  void _onTapData(int index) {
    setState(() {
      _annualFulfillmentItemHeightStatus[index] =
          !_annualFulfillmentItemHeightStatus[index];
    });
  }

  Widget _renderFulfillmentData(FulfillmentHistoryModel model, int index) {
    final String date = NumberHandler().mrymdToDate(model.date);
    final String startTime = NumberHandler().hhmiToTime(model.startTime, 12);
    final String endTime = NumberHandler().hhmiToTime(model.endTime, 12);
    final bool status = _annualFulfillmentItemHeightStatus[index];
    return SizedBox(
        width: context.pWidth,
        child: Column(children: [
          AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: status ? context.pHeight * 0.45 : context.pHeight * 0.16,
              padding: EdgeInsets.only(
                top: context.pHeight * 0.01,
                bottom: context.pHeight * 0.01,
              ),
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(model.type,
                                  style: TextStyle(
                                      fontSize: context.pWidth * 0.045,
                                      fontWeight: FontWeight.bold)),
                              GestureDetector(
                                  onTap: () => _onTapData(index),
                                  child: AnimatedRotation(
                                      turns: status ? 0.5 : 0.0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: context.pHeight * 0.045,
                                      )))
                            ]),
                        Padding(
                            padding: EdgeInsets.all(context.pHeight * 0.001)),
                        Text('날짜: $date',
                            style: TextStyle(
                              fontSize: context.pWidth * 0.045,
                            )),
                        Padding(
                            padding: EdgeInsets.all(context.pHeight * 0.001)),
                        Text('시간: $startTime ~ $endTime',
                            style: TextStyle(
                              fontSize: context.pWidth * 0.045,
                            )),
                        Padding(
                            padding: EdgeInsets.all(context.pHeight * 0.001)),
                        Text('이행률: ${model.fulfillmentRate}%',
                            style: TextStyle(
                              fontSize: context.pWidth * 0.045,
                            )),
                        Padding(
                            padding: EdgeInsets.all(context.pHeight * 0.015)),
                        status ? _renderMitigationGraph(index) : SizedBox()
                      ]))),
          const Divider(
            color: Colors.black26,
            thickness: 1,
          ),
        ]));
  }

  Widget _renderMitigationGraph(int index) {
    return SizedBox(
        height: context.pHeight * 0.28,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(labelFormat: '{value}kWh'),
          series: <CartesianSeries>[
            ColumnSeries<FulfillmentData, String>(
                name: '이행률',
                pointColorMapper: (FulfillmentData data, index) => index == 0
                    ? Colors.blue.withOpacity(0.7)
                    : index == 1
                        ? Colors.red.withOpacity(0.7)
                        : index == 2
                            ? Colors.green.withOpacity(0.7)
                            : Colors.grey.withOpacity(0.7),
                dataSource: _chartData[index],
                xValueMapper: (FulfillmentData data, _) => data.cat,
                yValueMapper: (FulfillmentData data, _) => data.fulfillment,
                dataLabelMapper: (FulfillmentData data, _) => data.fulfillment >
                        0
                    ? '${NumberHandler().addComma(data.fulfillment.toString())}kWh'
                    : '0kWh',
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold))),
          ],
        ));
  }
}
