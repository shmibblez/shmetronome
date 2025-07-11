import 'package:flutter/material.dart';
import 'package:shmetronome/constants/constants.dart';
import 'package:soundpool/soundpool.dart';

class MetronomeOptionsNotifier extends ChangeNotifier {
  MetronomeOptionsNotifier({
    @required int tempoBPM,
    @required bool clickEnabled,
    @required bool vibrationEnabled,
    @required bool blinkEnabled,
    @required bool playing,
    @required int soundID,
    @required Soundpool soundPool,
    @required this.canVibrate,
    @required TimeSignature timeSignature,
    @required this.showEpilepsyWarning,
    @required this.agreedToLegal,
  }) {
    this._tempoBPM = tempoBPM;
    this._clickEnabled = clickEnabled;
    this._vibrationEnabled = vibrationEnabled;
    this._blinkEnabled = blinkEnabled;
    this._playing = playing;
    this._soundID = soundID;
    this._soundPool = soundPool;
    this._timeSignature = timeSignature;
  }

  int _tempoBPM;
  bool _clickEnabled;
  bool _vibrationEnabled;
  bool _blinkEnabled;
  bool _playing;
  int _soundID;
  Soundpool _soundPool;
  final bool canVibrate;
  TimeSignature _timeSignature;
  bool showEpilepsyWarning;
  bool agreedToLegal;

  int get tempoBPM => this._tempoBPM;
  bool get clickEnabled => this._clickEnabled;
  bool get vibrationEnabled => this._vibrationEnabled;
  bool get blinkEnabled => this._blinkEnabled;
  bool get playing => this._playing;
  int get soundID => this._soundID;
  Soundpool get soundPool => this._soundPool;
  TimeSignature get timeSignature => this._timeSignature;

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

  set timeSignature(TimeSignature newTimeSig) {
    debugPrint("time signature changed");
    if (this._timeSignature != newTimeSig) {
      debugPrint("time signatures not equal, notifying listeners");
      this._timeSignature = newTimeSig;
      notifyListeners();
      return;
    }
    debugPrint("time signatures equal, not notifying listeners");
    debugPrint(
        "hash codes: this ${this.timeSignature.hashCode}, obj ${newTimeSig.hashCode}");
    debugPrint("tops: this ${this.timeSignature.top}, obj ${newTimeSig.top}");
  }

  void increaseTempoBy5() {
    int newTempo = this.tempoBPM + 5;
    if (newTempo % 5 != 0) {
      newTempo = (newTempo / 5).floor() * 5;
    }
    if (newTempo > Constants.maxTempo) {
      newTempo = Constants.maxTempo;
    }
    if (newTempo != this.tempoBPM) {
      this.tempoBPM = newTempo;
      notifyListeners();
    }
  }

  void decreaseTempoBy5() {
    int newTempo = this.tempoBPM - 5;
    if (newTempo % 5 != 0) {
      newTempo = (newTempo / 5).ceil() * 5;
    }
    if (newTempo < Constants.minTempo) {
      newTempo = Constants.minTempo;
    }
    if (newTempo != this.tempoBPM) {
      this.tempoBPM = newTempo;
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

class TimeSignature {
  TimeSignature({@required int top, @required int bot}) {
    this._top = top;
    this._bot = bot;
    this.tops = _generateTops();
    this.bots = _generateBots();

    debugPrint("tops: ${this.tops}");
    debugPrint("bots: ${this.bots}");
  }

  int _top;
  int _bot;
  List<int> tops;
  List<int> bots;

  int get top => this._top;
  int get bot => this._bot;
  static int get minTops => 1;
  static int get maxTops => 17;
  bool get onFirstTop => this.tops.indexOf(this._top) == 0;
  bool get onLastTop => this.tops.indexOf(this._top) == this.tops.length - 1;

  /// get previous top if available, if not, return current
  int get prevTop {
    if (this.top != tops[0]) {
      return this.tops[this.tops.indexOf(this.top) - 1];
    }
    return this.top;
  }

  /// get next top if available, if not, return current
  int get nextTop {
    if (this.top != this.tops[this.tops.length - 1]) {
      debugPrint("tops not equal");
      return this.tops[this.tops.indexOf(this.top) + 1];
    }
    return this.top;
  }

  static int get minBots => 1;
  static int get maxBots => 32;

  set top(int newTop) {
    this._top = newTop;
  }

  // TODO: add checks if available lower or upper tops / bots (if first or last item) for enabling arrows

  set bot(int newBot) {
    this._bot = newBot;
  }

  static List<int> _generateTops() {
    List<int> tops = [];
    for (int i = TimeSignature.minTops; i <= TimeSignature.maxTops; i++) {
      tops.add(i);
    }
    return tops;
  }

  static List<int> _generateBots() {
    List<int> tops = [];
    for (int i = TimeSignature.minBots; i <= TimeSignature.maxTops; i *= 2) {
      tops.add(i);
    }
    return tops;
  }

  @override
  operator ==(dynamic obj) {
    return obj is TimeSignature && obj.top == this._top && obj.bot == this._bot;
  }

  @override
  int get hashCode => "${this._top}${this._bot}".hashCode;
}

/// receives touch events and calculates tempo from them
class TempoDetector {
  TempoDetector();

// window to stop listening
  static const _windowMicros = 5000000;

  int lastMicros = 0;
  double calculatedBPM;
  int avgBias;

  /// returns [calculated tempo], which is null if no previous touch event received
  int newTouch() {
    // if too many micros, reset calculated tempo and lastMicros (set to null)
    int newMicros = DateTime.now().microsecondsSinceEpoch;
    int diff = newMicros - this.lastMicros;

    this.lastMicros = newMicros;

    if (diff > _windowMicros) {
      // reset stuff
      this.calculatedBPM = null;
      this.avgBias = 0;
      return null;
    }

    double newBPM = _bpmFromMicros(diff);
    // increment bias since adding new num
    this.avgBias += 1;

    this.calculatedBPM =
        (((this.avgBias - 1) * (this.calculatedBPM ?? 0)) + newBPM) / avgBias;

    debugPrint("calculated bpm: ${this.calculatedBPM}, diff: $diff");

    return Constants.tempoWithinBounds(this.calculatedBPM.toInt());

    // calculated tempo is average of received times (get diff between current time, last time, and add to avg)
    // avg bias -> # times avg calculated (multiply calculatedTempo by this, add new tempo, and divide by avgBias + 1)
  }

  double _bpmFromMicros(int micros) {
    return 60000000 / micros;
  }
}
