import 'package:enercle_proj/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:enercle_proj/sizes.dart';

class Countdown extends StatelessWidget {
  final DateTime targetDatetime;
  final int min;
  final int sec;

  Countdown({
    required this.targetDatetime,
    required this.min,
    required this.sec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.only(
          left: context.pHeight * 0.015,
          right: context.pHeight * 0.015,
          top: context.pHeight * 0.025,
          bottom: context.pHeight * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
            child: Column(children: [
          Text('감축경보 발령 해제까지',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: context.pHeight * 0.035,
                  fontWeight: FontWeight.bold)),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.007)),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$min',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: context.pHeight * 0.045,
                        fontWeight: FontWeight.bold)),
                Text(' 분  ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: context.pHeight * 0.045,
                        fontWeight: FontWeight.bold)),
                Text('$sec',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: context.pHeight * 0.045,
                        fontWeight: FontWeight.bold)),
                Text(' 초',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: context.pHeight * 0.045,
                        fontWeight: FontWeight.bold)),
              ]),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.007)),
          Text('남았습니다.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: context.pHeight * 0.035,
                  fontWeight: FontWeight.bold))
        ])));
  }
}
