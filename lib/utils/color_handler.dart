import 'package:flutter/material.dart';

class ColorHandler {
  Color determineFulfillmentRate(String rate) {
    final String rateStr = double.parse(rate).toStringAsFixed(2);
    final double rateDouble = double.parse(rateStr);
    late final Color ret;
    if (rateDouble < 90) {
      ret = Colors.red.withOpacity(0.7);
    } else if (rateDouble >= 90 && rateDouble < 97) {
      ret = Colors.yellow.withOpacity(0.7);
    } else if (rateDouble >= 97 && rateDouble < 105) {
      ret = Colors.lightGreen.withOpacity(0.7);
    } else if (rateDouble >= 105) {
      ret = Colors.green.withOpacity(0.7);
    } else {
      ret = Colors.grey.withOpacity(0.7);
    }
    return ret;
  }
}
