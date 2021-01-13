import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shmetronome/change_notifiers/metronome_options.dart';
import 'package:shmetronome/constants/constants.dart';
import 'package:shmetronome/helpers/helpers.dart';
import 'package:shmetronome/widgets/tempo_bar.dart';
import 'package:tuple/tuple.dart';
import 'package:vibration/vibration.dart';

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
  Timer timer;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Selector<MetronomeOptionsNotifier, Tuple3<bool, int, bool>>(
          selector: (_, obj) =>
              Tuple3(obj.playing, obj.tempoBPM, obj.blinkEnabled),
          builder: (_, obj, __) {
            _BlinkBackgroundController controller =
                _BlinkBackgroundController();
            timer?.cancel();
            debugPrint(
                "blink selector event received, playing: ${obj.item1}, blink enabled: ${obj.item3}");
            if (obj.item1 && obj.item3) {
              // if blink enabled
              timer = Timer.periodic(
                Helpers.durationFromBPM(obj.item2),
                (_) {
                  controller.blink();
                  debugPrint("blink activated");
                },
              );
            }
            return _BlinkBackground(controller: controller);
          },
        ),
        _MetronomeScreen(),
      ],
    );
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
    return Consumer<MetronomeOptionsNotifier>(
      // selector: (BuildContext _, MetronomeOptionsNotifier obj) {
      //   return Tuple6(
      //     obj.playing,
      //     obj.tempoBPM,
      //     obj.clickEnabled,
      //     obj.vibrationEnabled,
      //     obj.blinkEnabled,
      //     obj.soundID,
      //   );
      // },
      builder: (BuildContext context1, obj, __) {
        _tempoTimer?.cancel();
        if (obj.playing) {
          // if playing selected, play
          _tempoTimer = Timer.periodic(
            Helpers.durationFromBPM(obj.tempoBPM.truncate()),
            (timer) {
              _tempoBarController.blinkAtIndex(_beatTracker.nextBeat());
              if (obj.clickEnabled) {
                obj.soundPool.play(obj.soundID);
              }
              if (obj.vibrationEnabled) {}
            },
          );
        }
        debugPrint("rebuilt after tempo change");

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            /// here will go tempo bar, tempo indicator, time signature selector, indicator selector (click, vibrate, blink), play/pause, etc...
            TempoBar(controller: _tempoBarController),

            // tempo indicator
            Expanded(
              child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[900], width: 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(Dimens.smol_radius),
                    ),
                  ),
                  child: Text("tempo: ${obj.tempoBPM}",
                      textAlign: TextAlign.center)),
            ),

            // empty space for blink viewing
            Expanded(flex: 2, child: Container()),

            // tempo indicator options (click, vibrate, blink)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[900], width: 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Dimens.smol_radius),
                          bottomLeft: Radius.circular(Dimens.smol_radius),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(obj.clickEnabled
                            ? Icons.volume_up
                            : Icons.volume_off),
                        color:
                            obj.clickEnabled ? Colors.black : Colors.grey[400],
                        onPressed: () {
                          Provider.of<MetronomeOptionsNotifier>(context,
                                  listen: false)
                              .clickEnabled = !obj.clickEnabled;
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[900], width: 1),
                        // borderRadius: BorderRadius.only(
                        //   topLeft: Radius.circular(Dimens.smol_radius),
                        //   bottomLeft: Radius.circular(Dimens.smol_radius),
                        // ),
                      ),
                      child: IconButton(
                        icon: Icon(obj.vibrationEnabled
                            ? Icons.vibration
                            : Icons.not_interested),
                        color: obj.vibrationEnabled
                            ? Colors.black
                            : Colors.grey[400],
                        onPressed: () async {
                          if (obj.canVibrate) {
                            Provider.of<MetronomeOptionsNotifier>(context,
                                    listen: false)
                                .vibrationEnabled = !obj.vibrationEnabled;
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[900], width: 1),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(Dimens.smol_radius),
                          bottomRight: Radius.circular(Dimens.smol_radius),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(obj.blinkEnabled
                            ? Icons.lightbulb
                            : Icons.lightbulb_outline),
                        color:
                            obj.blinkEnabled ? Colors.black : Colors.grey[400],
                        onPressed: () {
                          Provider.of<MetronomeOptionsNotifier>(context,
                                  listen: false)
                              .blinkEnabled = !obj.blinkEnabled;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                        value: obj.tempoBPM.toDouble(),
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
              flex: 1,
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
                        icon:
                            Icon(obj.playing ? Icons.pause : Icons.play_arrow),
                        color: Colors.black,
                        onPressed: () {
                          Provider.of<MetronomeOptionsNotifier>(
                            context1,
                            listen: false,
                          ).playing = !obj.playing;
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
}

///
/// blinking background below
///

class _BlinkBackgroundController extends ChangeNotifier {
  void blink() {
    debugPrint("controller blink called");
    notifyListeners();
  }
}

class _BlinkBackground extends StatefulWidget {
  _BlinkBackground({@required this.controller});

  final _BlinkBackgroundController controller;
  @override
  State<StatefulWidget> createState() {
    return _BlinkBackgroundState();
  }
}

// doesnt need a controller since has it's own timer
class _BlinkBackgroundState extends State<_BlinkBackground>
    with SingleTickerProviderStateMixin {
  AnimationController _animController;
  bool forward;
  void Function() listener;
  void Function(AnimationStatus) statusListener;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      duration: Duration(milliseconds: Constants.animation_duration_ms_half),
      value: 0,
    )..stop();

    forward = true;
    listener = () {
      setState(() {});
    };
    statusListener = (status) {
      if (status == AnimationStatus.completed) {
        _animController.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        _animController.stop();
      }
    };
    // add listeners
    _animController.addListener(listener);
    _animController.addStatusListener(statusListener);

    widget.controller.addListener(blink);
  }

  void blink() {
    debugPrint("blink called");
    _animController.forward();
  }

  @override
  void dispose() {
    super.dispose();

    _animController.dispose();
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("blink widget rebuilt");
    return Container(
      color: Colors.grey[700].withOpacity(_animController.value),
    );
  }
}
