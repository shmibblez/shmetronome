import 'package:flutter/material.dart';
import 'package:soundpool/soundpool.dart';

class MetronomeOptionsNotifier extends ChangeNotifier {
  MetronomeOptionsNotifier({
    @required tempoBPM,
    @required clickEnabled,
    @required vibrationEnabled,
    @required blinkEnabled,
    @required playing,
    @required soundID,
    @required soundPool,
    @required this.canVibrate,
  }) {
    this._tempoBPM = tempoBPM;
    this._clickEnabled = clickEnabled;
    this._vibrationEnabled = vibrationEnabled;
    this._blinkEnabled = blinkEnabled;
    this._playing = playing;
    this._soundID = soundID;
    this._soundPool = soundPool;
  }

  int _tempoBPM;
  bool _clickEnabled;
  bool _vibrationEnabled;
  bool _blinkEnabled;
  bool _playing;
  int _soundID;
  Soundpool _soundPool;
  final bool canVibrate;

  int get tempoBPM => this._tempoBPM;
  bool get clickEnabled => this._clickEnabled;
  bool get vibrationEnabled => this._vibrationEnabled;
  bool get blinkEnabled => this._blinkEnabled;
  bool get playing => this._playing;
  int get soundID => this._soundID;
  Soundpool get soundPool => this._soundPool;

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

  set soundID(int newID) {
    if (newID != this._soundID) {
      this._soundID = newID;
      notifyListeners();
    }
  }

  @override
  operator ==(dynamic obj) {
    return obj is MetronomeOptionsNotifier &&
        obj.tempoBPM == this._tempoBPM &&
        obj.clickEnabled == this._clickEnabled &&
        obj.vibrationEnabled == this._vibrationEnabled &&
        obj.blinkEnabled == this._blinkEnabled &&
        obj.soundID == this._soundID;
  }

  @override
  int get hashCode =>
      "${this._tempoBPM.hashCode}${this._clickEnabled.hashCode}${this._vibrationEnabled.hashCode}${this._blinkEnabled.hashCode}${this._soundID.hashCode}"
          .hashCode;
}
