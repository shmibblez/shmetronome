import 'package:flutter/material.dart';

class MetronomeOptionsNotifier extends ChangeNotifier {
  MetronomeOptionsNotifier({
    @required tempo,
    @required clickEnabled,
    @required vibrationEnabled,
    @required blinkEnabled,
  }) {
    this._tempo = tempo;
    this._clickEnabled = clickEnabled;
    this._vibrationEnabled = vibrationEnabled;
    this._blinkEnabled = blinkEnabled;
  }

  int _tempo;
  bool _clickEnabled;
  bool _vibrationEnabled;
  bool _blinkEnabled;

  get tempo => this._tempo;
  get clickEnabled => this._clickEnabled;
  get vibrationEnabled => this._vibrationEnabled;
  get blinkEnabled => this._blinkEnabled;

  set tempo(int newTempo) {
    if (newTempo != this._tempo) {
      this._tempo = newTempo;
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

  @override
  operator ==(dynamic obj) {
    return obj is MetronomeOptionsNotifier &&
        obj.tempo == this._tempo &&
        obj.clickEnabled == this._clickEnabled &&
        obj.vibrationEnabled == this._vibrationEnabled &&
        obj.blinkEnabled == this._blinkEnabled;
  }

  @override
  int get hashCode =>
      "${this._tempo.hashCode}${this._clickEnabled.hashCode}${this._vibrationEnabled.hashCode}${this._blinkEnabled.hashCode}"
          .hashCode;
}
