import "package:flutter/material.dart";
import "dart:math" as math;

class Responsive {
  late double _width, _height, _diagonal;
  late bool _isTablet;

  Responsive._(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;
    _diagonal = math.sqrt(math.pow(_width, 2) + math.pow(_height, 2));
    _isTablet = size.shortestSide >= 600;
  }

  //
  // fdp: for font or objects size, is similar to default size in devices like
  // iPhone 11.
  // hp: for containers with height, padding/margin vertical
  // wp: for containers with width, padding/margin horizontal.
  // dp: can be used to set the values if dp or wp doesn't work properly.
  //
  static Responsive of(BuildContext context) => Responsive._(context);
  double wp(double percent) => _width * percent / 100;
  double hp(double percent) => _height * percent / 100;
  double dp(double percent) => _diagonal * percent / 100;
  double fdp(double percent) => _diagonal * percent / 1000;
  double get width => _width;
  double get height => _height;
  double get diagonal => _diagonal;
  bool get isTablet => _isTablet;
}
