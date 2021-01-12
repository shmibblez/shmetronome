import 'package:flutter/material.dart';

class MetronomeOptionsNotifier extends ChangeNotifier {
  MetronomeOptionsNotifier({
    @required tempoBPM,
    @required clickEnabled,
    @required vibrationEnabled,
    @required blinkEnabled,
    @required playing,
  }) {
    this._tempoBPM = tempoBPM;
    this._clickEnabled = clickEnabled;
    this._vibrationEnabled = vibrationEnabled;
    this._blinkEnabled = blinkEnabled;
    this._playing = playing;
  }

  int _tempoBPM;
  bool _clickEnabled;
  bool _vibrationEnabled;
  bool _blinkEnabled;
  bool _playing;

  get tempoBPM => this._tempoBPM;
  get clickEnabled => this._clickEnabled;
  get vibrationEnabled => this._vibrationEnabled;
  get blinkEnabled => this._blinkEnabled;
  get playing => this._playing;

  set tempoBPM(int newTempo) {
    if (newTempo != this._tempoBPM) {
      this._tempoBPM = newTempo;
      notifyListeners();
    }
  }

  set clickEnabled(bool enabled) {
    if (enabled != this._clickEnabled) {
      this._clickEnabled = enabled;
      notifyListeners();
    }
  }

  set vibrationEnabled(bool enabled) {
    if (enabled != this._vibrationEnabled) {
      this._vibrationEnabled = enabled;
      notifyListeners();
    }
  }

  set blinkEnabled(bool enabled) {
    if (enabled != this._blinkEnabled) {
      this._blinkEnabled = enabled;
      notifyListeners();
    }
  }

  set playing(bool playing) {
    if (playing != this._playing) {
      this._playing = playing;
      notifyListeners();
    }
  }

  @override
  operator ==(dynamic obj) {
    return obj is MetronomeOptionsNotifier &&
        obj.tempoBPM == this._tempoBPM &&
        obj.clickEnabled == this._clickEnabled &&
        obj.vibrationEnabled == this._vibrationEnabled &&
        obj.blinkEnabled == this._blinkEnabled;
  }

  @override
  int get hashCode =>
      "${this._tempoBPM.hashCode}${this._clickEnabled.hashCode}${this._vibrationEnabled.hashCode}${this._blinkEnabled.hashCode}"
          .hashCode;
}
