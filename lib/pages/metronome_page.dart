import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shmetronome/change_notifiers/metronome_options.dart';
import 'package:shmetronome/constants/constants.dart';
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

/// figures out which TempoBox needs to light up
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

    // TODo: add time signature selector (left and right wheels) (number of boxes) -> replace all "4" time signatures with val at MetronomeOptions (get from SharedPreferences)
    // TODO: in other words -> add time signature to MetronomeOptionsNotifier (defualt is 4/4), and show changes in TempoBar
    // when time signature selected, show alertDialog that allows selection (1 wheel on left, 1 on right, with slash (/) between them)   (0)_0)
    _tempoBarController = TempoBarController(numBoxes: 4);
    _beatTracker = BeatTracker(indx: 0, beatNum: 4);
  }

  @override
  Widget build(BuildContext _) {
    return Selector<MetronomeOptionsNotifier, Tuple2<bool, int>>(
      selector: (BuildContext _, MetronomeOptionsNotifier obj) {
        return Tuple2(obj.playing, obj.tempoBPM);
      },
      builder: (BuildContext context1, Tuple2<bool, int> obj, __) {
        final bool playing = obj.item1;
        double tempo = obj.item2.toDouble();
        _tempoTimer?.cancel();
        if (playing) {
          // if playing selected, play
          _tempoTimer = Timer.periodic(
            _durationFromBPM(tempo.truncate()),
            (timer) {
              _tempoBarController.blinkAtIndex(_beatTracker.nextBeat());
            },
          );
        }
        debugPrint("rebuilt after tempo change");

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            /// here will go tempo bar, tempo indicator, time signature selector, indicator selector (click, vibrate, blink), play/pause, etc...
            TempoBar(controller: _tempoBarController),

            // empty space for blink viewing
            Expanded(flex: 2, child: Container()),

            // tempo slider
            Builder(
              builder: (context2) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[900], width: 1),
                      borderRadius:
                          BorderRadius.all(Radius.circular(Dimens.smol_radius)),
                    ),
                    child: Slider(
                        // TODO: find way to move slider and only set tempo when finished sliding (now when tempo is changed rebuilds whole widget)
                        // onChangeEnd: (newTempo) {
                        //   Provider.of<MetronomeOptionsNotifier>(context1,
                        //           listen: false)
                        //       .tempoBPM = newTempo.truncate();
                        // },
                        min: 10,
                        max: 300,
                        divisions: 290,
                        value: tempo,
                        onChanged: (newTempo) {
                          Provider.of<MetronomeOptionsNotifier>(context1,
                                  listen: false)
                              .tempoBPM = newTempo.truncate();
                        }),
                  ),
                );
              },
            ),

            // play/pause buttons
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    /// [play / pause]
                    child: Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[900], width: 1),
                        borderRadius: BorderRadius.all(
                            Radius.circular(Dimens.smol_radius)),
                      ),
                      child: IconButton(
                        splashColor: Colors.transparent,
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        color: Colors.black,
                        onPressed: () {
                          Provider.of<MetronomeOptionsNotifier>(
                            context1,
                            listen: false,
                          ).playing = !playing;
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    /// [tempo selector (TODO)]
                    child: Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[900], width: 1),
                        borderRadius: BorderRadius.all(
                            Radius.circular(Dimens.smol_radius)),
                      ),
                      child: IconButton(
                        splashColor: Colors.transparent,
                        icon: Icon(Icons.touch_app),
                        color: Colors.black,
                        onPressed: () {
                          // modify tempo here
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
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
