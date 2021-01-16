import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shmetronome/change_notifiers/metronome_options.dart';
import 'package:shmetronome/constants/constants.dart';
import 'package:shmetronome/helpers/helpers.dart';
import 'package:shmetronome/widgets/tempo_bar.dart';
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
    _BlinkBackgroundController controller = _BlinkBackgroundController();
    return Stack(
      children: [
        _BlinkBackground(controller: controller),
        _MetronomeScreen(
          blinkController: controller,
          tempoDetector: TempoDetector(),
        ),
      ],
    );
  }
}

/// figures out which TempoBox needs to light up
class BeatTracker {
  /// [numBeats] is max number of beats
  BeatTracker({@required this.numBeats, this.indx = 0});

  int indx;
  int numBeats;

  /// returns current beat indx and moves to next one
  int nextBeat() {
    int currentBeat = indx;

    indx++;
    if (indx >= numBeats) indx = 0;

    return currentBeat;
  }
}

class _MetronomeScreen extends StatefulWidget {
  _MetronomeScreen({
    @required this.blinkController,
    @required this.tempoDetector,
  });
  final _BlinkBackgroundController blinkController;
  final TempoDetector tempoDetector;

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
  }

  void checkLegal() {
    _checkLegal();
  }

  Future<void> _checkLegal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await showDialog(
      barrierDismissible: false,
      context: this.context,
      builder: (_) {
        return AlertDialog(
          content: Text(
              "By using shmetronome, you acknowledge that you agree to our Terms and Conditions and Privacy Policy. Please actually read them, they're actually pretty short and contain some health warnings in case you suffer from conditions like epilepsy or something similar."),
          actions: [
            TextButton(
              child: Text(
                  "yes, I have read the Terms and Conditions and Privacy Policy and agree wholeheartedly"),
              onPressed: () async {
                await prefs.setBool("agreedToLegal", true);
                Navigator.of(context).pop();
                Provider.of<MetronomeOptionsNotifier>(context, listen: false)
                    .agreedToLegal = true;
              },
            ),
          ],
        );
      },
    );
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
        if (!obj.agreedToLegal) {
          checkLegal();
        }
        if (_tempoBarController == null) {
          _tempoBarController =
              TempoBarController(numBoxes: obj.timeSignature.top);
          _beatTracker = BeatTracker(indx: 0, numBeats: obj.timeSignature.bot);
        } else {
          _tempoBarController.numBoxes = obj.timeSignature.top;
          _beatTracker.numBeats = obj.timeSignature.top;
        }
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
              if (obj.blinkEnabled) {
                widget.blinkController.blink();
              }
              if (obj.vibrationEnabled) {
                Vibration.vibrate(duration: 100);
              }
            },
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            /// here will go time signature selector, indicator selector (click, vibrate, blink), play/pause, etc...
            TempoBar(controller: _tempoBarController),

            /// tempo indicator
            Expanded(
              child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Constants.buttonBackgroundColor,
                    border: Border.all(color: Colors.grey[900], width: 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(Dimens.smol_radius),
                    ),
                  ),
                  child: Text("tempo: ${obj.tempoBPM} bpm",
                      textAlign: TextAlign.center)),
            ),

            /// empty space for blink viewing
            Expanded(flex: 2, child: Container()),

            /// tempo indicator options (click, vibrate, blink)
            // click option
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                      decoration: BoxDecoration(
                        color: Constants.buttonBackgroundColor,
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
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                    ),
                  ),
                  // vibrate option
                  obj.canVibrate
                      ? Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: Constants.buttonBackgroundColor,
                              border:
                                  Border.all(color: Colors.grey[900], width: 1),
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
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                            ),
                          ),
                        )
                      : Container(),
                  // blink option
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 5, right: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Constants.buttonBackgroundColor,
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
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
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
                      color: Constants.buttonBackgroundColor,
                      border: Border.all(color: Colors.grey[900], width: 1),
                      borderRadius:
                          BorderRadius.all(Radius.circular(Dimens.smol_radius)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          // if no more time signature top portions left, disable button
                          onPressed: () {
                            Provider.of<MetronomeOptionsNotifier>(context,
                                    listen: false)
                                .decreaseTempoBy5();
                          },
                          padding: EdgeInsets.only(left: 25),
                          constraints: BoxConstraints(),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                        ),
                        Expanded(
                          child: Slider(
                            // TODO: find way to move slider and only set tempo when finished sliding (now when tempo is changed rebuilds whole widget)
                            // onChangeEnd: (newTempo) {
                            //   Provider.of<MetronomeOptionsNotifier>(context1,
                            //           listen: false)
                            //       .tempoBPM = newTempo.truncate();
                            // },
                            min: Constants.minTempo.toDouble(),
                            max: Constants.maxTempo.toDouble(),
                            divisions: 290,
                            value: obj.tempoBPM.toDouble(),
                            onChanged: (newTempo) {
                              Provider.of<MetronomeOptionsNotifier>(context1,
                                      listen: false)
                                  .tempoBPM = newTempo.truncate();
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          // if no more time signature top portions left, disable button
                          onPressed: () {
                            Provider.of<MetronomeOptionsNotifier>(context,
                                    listen: false)
                                .increaseTempoBy5();
                          },
                          padding: EdgeInsets.only(right: 25),
                          constraints: BoxConstraints(),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            /// play/pause, time signature, & tap to tempo options
            /// [play/pause]
            Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Constants.buttonBackgroundColor,
                        border: Border.all(color: Colors.grey[900], width: 1),
                        borderRadius: BorderRadius.all(
                            Radius.circular(Dimens.smol_radius)),
                      ),
                      child: IconButton(
                        icon:
                            Icon(obj.playing ? Icons.pause : Icons.play_arrow),
                        color: Colors.black,
                        onPressed: () {
                          if (obj.playing == false && obj.showEpilepsyWarning) {
                            showDialog(
                                barrierDismissible: false,
                                context: context1,
                                builder: (_) {
                                  return AlertDialog(
                                    content: Text(
                                        """Warning: "rythmic stimulation" (repetitive sounds, vibration, or blinking) at certain frequencies may trigger seizures, if you suffer from any form of this or a similar condition do not use this app"""),
                                    actions: [
                                      TextButton(
                                        child: Text("ok"),
                                        onPressed: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          await prefs.setBool(
                                              "showEpilepsyWarning", false);
                                          Navigator.of(context).pop();
                                          Provider.of<MetronomeOptionsNotifier>(
                                                  context,
                                                  listen: false)
                                              .showEpilepsyWarning = false;
                                        },
                                      )
                                    ],
                                  );
                                });
                          } else {
                            Provider.of<MetronomeOptionsNotifier>(
                              context1,
                              listen: false,
                            ).playing = !obj.playing;
                          }
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                    ),
                  ),

                  /// [time signature]
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Constants.buttonBackgroundColor,
                        border: Border.all(color: Colors.grey[900], width: 1),
                        borderRadius: BorderRadius.all(
                            Radius.circular(Dimens.smol_radius)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_up),
                                // if no more time signature top portions left, disable button
                                onPressed: obj.timeSignature.onLastTop
                                    ? null
                                    : () {
                                        debugPrint(
                                            "increasing time signature top");
                                        Provider.of<MetronomeOptionsNotifier>(
                                                    context,
                                                    listen: false)
                                                .timeSignature =
                                            TimeSignature(
                                                top: obj.timeSignature.nextTop,
                                                bot: obj.timeSignature.bot);
                                      },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                              ),
                              Text(obj.timeSignature.top.toString()),
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_down),
                                // if no more time signature top portions left, disable button
                                onPressed: obj.timeSignature.onFirstTop
                                    ? null
                                    : () {
                                        debugPrint(
                                            "decreasing time signature top");
                                        Provider.of<MetronomeOptionsNotifier>(
                                                    context,
                                                    listen: false)
                                                .timeSignature =
                                            TimeSignature(
                                                top: obj.timeSignature.prevTop,
                                                bot: obj.timeSignature.bot);
                                        debugPrint(
                                            " - old time sig top: ${obj.timeSignature.top}, new time sig top: ${obj.timeSignature.prevTop}");
                                      },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                              ),
                            ],
                          ),
                          Text("/"),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment:
                                MainAxisAlignment.center, // still need to do
                            children: [
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_up),
                                // if no more time signature top portions left, disable button
                                onPressed: null,
                                // (replace above null with) -> obj.timeSignature.onFirstTop ? null : () {},
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                              ),
                              Text(obj.timeSignature.bot.toString()),
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_down),
                                // if no more time signature top portions left, disable button
                                onPressed: null,
                                // (replace above null with) -> obj.timeSignature.onLastTop ? null : () {},
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  /// [tap to tempo (TODO)]
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Constants.buttonBackgroundColor,
                        border: Border.all(color: Colors.grey[900], width: 1),
                        borderRadius: BorderRadius.all(
                            Radius.circular(Dimens.smol_radius)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.touch_app),
                        color: Colors.black,
                        onPressed: () {
                          // modify tempo here
                          int newTempo = widget.tempoDetector.newTouch();
                          if (newTempo != null) {
                            Provider.of<MetronomeOptionsNotifier>(context,
                                    listen: false)
                                .tempoBPM = newTempo;
                          }
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
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
/// blinking background widgets below
///
class _BlinkBackgroundController extends ChangeNotifier {
  void blink() {
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
      upperBound: 0.5,
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
    _animController.reset();
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
    return Container(
      color: Colors.grey[900].withOpacity(_animController.value),
    );
  }
}
