import 'package:flutter/material.dart';

class ColorHandler {
  Color determineFulfillmentRate(String rate) {
    final int rateInt = int.parse(rate);
    late final Color ret;
    if (rateInt < 90) {
      ret = Colors.red.withOpacity(0.7);
    } else if (rateInt >= 90 && rateInt < 97) {
      ret = Colors.yellow.withOpacity(0.7);
    } else if (rateInt >= 97 && rateInt < 105) {
      ret = Colors.lightGreen.withOpacity(0.7);
    } else if (rateInt >= 105) {
      ret = Colors.green.withOpacity(0.7);
    } else {
      ret = Colors.grey.withOpacity(0.7);
    }
    return ret;
  }
}
