import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shmetronome/change_notifiers/metronome_options.dart';
import 'package:shmetronome/widgets/tempo_bar.dart';
import 'package:tuple/tuple.dart';

/// names are confusing so:
/// - MetronomePage encompasses MetronomeScreen and BlinkBackground
/// - MetronomeScreen contains buttons & options
/// - BlinkBackground blinks to tempo

class MetronomePage extends StatefulWidget {
  @override
  _MetronomePageState createState() {
    return _MetronomePageState();
  }
}

class _MetronomePageState extends State<MetronomePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [_MetronomeScreen()]);
  }
}

class BeatTracker {
  /// [beatNum] is max number of beats
  BeatTracker({@required this.beatNum, this.indx = 0});

  int indx;
  int beatNum;

  /// returns current beat indx and moves to next one
  int nextBeat() {
    int currentBeat = indx;

    indx++;
    if (indx >= beatNum) indx = 0;

    return currentBeat;
  }
}

class _MetronomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MetronomeScreenState();
  }
}

class _MetronomeScreenState extends State<_MetronomeScreen> {
  TempoBarController _tempoBarController;
  Timer _tempoTimer;
  BeatTracker _beatTracker;

  @override
  void initState() {
    super.initState();

    // TODO: add time signature selector (left and right wheels) (number of boxes) -> replace all "4" time signatures with val at MetronomeOptions (get from SharedPreferences)
    _tempoBarController = TempoBarController(numBoxes: 4);
    _beatTracker = BeatTracker(indx: 0, beatNum: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MetronomeOptionsNotifier, Tuple2<bool, int>>(
      selector: (BuildContext _, MetronomeOptionsNotifier obj) {
        return Tuple2(obj.playing, obj.tempoBPM);
      },
      builder: (_, Tuple2<bool, int> obj, __) {
        _tempoTimer?.cancel();
        if (obj.item1) {
          // if playing selected, play
          _tempoTimer = Timer.periodic(
            _durationFromBPM(obj.item2),
            (timer) {
              _tempoBarController.blinkAtIndex(_beatTracker.nextBeat());
            },
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            /// here will go tempo bar, tempo indicator, time signature selector, indicator selector (click, vibrate, blink), play/pause, etc...
            TempoBar(controller: _tempoBarController),
          ],
        );
      },
    );
  }

  Duration _durationFromBPM(int bpm) {
    // num of microseconds in second / bpm
    return Duration(microseconds: (60000000 / bpm).truncate());
  }
}

///
/// blinking background below
///
class _BlinkBackground extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BlinkBackgroundState();
  }
}

class _BlinkBackgroundState extends State<_BlinkBackground>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Selector<MetronomeOptionsNotifier, Tuple2<int, bool>>(
      selector: (_, obj) => Tuple2(obj.tempoBPM, obj.blinkEnabled),
      builder: (_, obj, __) {
        // adjust timer and tempo inside container -> how to animate blinking?
        // TODO: animate like tempo_box, dont need controller here
        return Container();
      },
    );
  }
}
