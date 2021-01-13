class Helpers {
  static Duration durationFromBPM(int bpm) {
    // num of microseconds in second / bpm
    return Duration(microseconds: (60000000 / bpm).truncate());
  }
}
