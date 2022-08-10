import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  double get pWidth => MediaQuery.of(this).size.width;
  double get pHeight => MediaQuery.of(this).size.height;
  double get leftPadding => pWidth * 0.05;
  double get rightPadding => pWidth * 0.05;
  double get bigButtonHeight => pHeight * 0.06;
  double get bigButtonWidth => pWidth - leftPadding + rightPadding;
}
