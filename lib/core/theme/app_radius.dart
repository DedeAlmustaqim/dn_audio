import 'package:flutter/material.dart';

/// Shared shape tokens for DN Audio surfaces and controls.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double artwork = 22;
  static const double pill = 999;

  static const BorderRadius small = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));
  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius artworkShape =
      BorderRadius.all(Radius.circular(artwork));
  static const BorderRadius pillShape =
      BorderRadius.all(Radius.circular(pill));
}
