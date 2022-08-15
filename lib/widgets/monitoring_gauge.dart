import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:countup/countup.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/const/colors.dart';
import 'package:enercle_proj/utils/number_handler.dart';

class MonitoringGauge extends StatelessWidget {
  final String title;
  final List<Color> gradientColors;
  final double curValue;
  final double lastValue;
  final String subText;

  const MonitoringGauge({
    Key? key,
    required this.title,
    required this.gradientColors,
    required this.curValue,
    required this.lastValue,
    required this.subText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int rate = lastValue > 0 ? (curValue / lastValue * 100).round() : 0;
    return Stack(children: [
      Container(
          height: context.pHeight * 0.42,
          padding: EdgeInsets.only(
            left: context.pWidth * 0.05,
            right: context.pWidth * 0.05,
            top: context.pWidth * 0.05,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3))
            ],
          ),
          child: Column(children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                    style: TextStyle(
                        fontSize: context.pWidth * 0.05,
                        fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
            Container(
                height: context.pHeight * 0.32,
                alignment: Alignment.bottomCenter,
                child: SfRadialGauge(axes: <RadialAxis>[
                  RadialAxis(
                      startAngle: 140,
                      endAngle: 40,
                      showTicks: false,
                      showLabels: false,
                      axisLineStyle: AxisLineStyle(
                        thickness: context.pHeight * 0.02,
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: rate.toDouble(),
                          width: context.pHeight * 0.025,
                          gradient: SweepGradient(
                            colors: gradientColors,
                          ),
                          enableAnimation: true,
                          cornerStyle: CornerStyle.bothCurve,
                        )
                      ])
                ]))
          ])),
      Container(
          padding: EdgeInsets.only(
              left: context.pWidth * 0.05, top: context.pHeight * 0.03),
          height: context.pHeight * 0.4,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      lastValue > 0
                          ? Countup(
                              begin: 0,
                              end: rate.toDouble(),
                              duration: Duration(seconds: 1),
                              style: TextStyle(
                                  fontSize: context.pHeight * 0.06,
                                  fontWeight: FontWeight.bold))
                          : Text('?',
                              style: TextStyle(
                                  fontSize: context.pHeight * 0.06,
                                  fontWeight: FontWeight.bold)),
                      Text(' %',
                          style: TextStyle(
                              fontSize: context.pHeight * 0.035,
                              fontWeight: FontWeight.bold))
                    ]),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          curValue > 0
                              ? NumberHandler().addComma(curValue.toString())
                              : '0',
                          style: TextStyle(
                              color: MyColors.mainColor,
                              fontSize: context.pWidth * 0.068,
                              fontWeight: FontWeight.bold)),
                      Text(' kW',
                          style: TextStyle(
                              color: MyColors.mainColor,
                              fontSize: context.pWidth * 0.04,
                              fontWeight: FontWeight.bold))
                    ]),
                Padding(padding: EdgeInsets.all(context.pHeight * 0.03)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('0',
                        style: TextStyle(
                            fontSize: context.pHeight * 0.023,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    Text(
                        lastValue > 0
                            ? NumberHandler().addComma(lastValue.toString())
                            : '0',
                        style: TextStyle(
                            fontSize: context.pHeight * 0.023,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold))
                  ],
                ),
                Padding(padding: EdgeInsets.all(context.pHeight * 0.007)),
                Padding(
                    padding: EdgeInsets.only(right: context.pWidth * 0.05),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(subText,
                              style: TextStyle(
                                  fontSize: context.pHeight * 0.02,
                                  color: Colors.grey)),
                          Text(
                              lastValue > 0
                                  ? '${NumberHandler().addComma(lastValue.toString())} kW'
                                  : '0 kW',
                              style: TextStyle(
                                  fontSize: context.pHeight * 0.02,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold)),
                        ])),
              ]))
    ]);
  }
}
