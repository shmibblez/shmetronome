import 'package:flutter/material.dart';

class Constants {
  static int get minTempo => 20;
  static int get maxTempo => 400;

  static int tempoWithinBounds(int tempo) {
    if (tempo > Constants.maxTempo) {
      return Constants.maxTempo;
    }
    if (tempo < Constants.minTempo) {
      return Constants.minTempo;
    }
    return tempo;
  }

  static const int animation_duration_ms_full = 200;
  static const int animation_duration_ms_half = 100;
  static const double border_width = 2;
  static const int border_radius = 2;
  static const buttonBackgroundColor = Colors.white;

  static const int flex_smol = 2;
  static const int flex_medm = 3;
  static const int flex_masv = 4;
}

class Dimens {
  static const double smol_radius = 10;
  static const double avrg_radius = 10;
  static const double masv_radius = 15;
}
