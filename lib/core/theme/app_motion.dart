import 'package:flutter/animation.dart';

/// Motion tokens for restrained, purposeful DN Audio interactions.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration emphasized = Duration(milliseconds: 240);

  static const Curve standardCurve = Curves.easeInOut;
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
}
