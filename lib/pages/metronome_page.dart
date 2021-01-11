import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shmetronome/change_notifiers/metronome_options.dart';
import 'package:tuple/tuple.dart';

class MetronomePage extends StatefulWidget {
  @override
  _MetronomePageState createState() {
    return _MetronomePageState();
  }
}

class _MetronomePageState extends State<MetronomePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: []);
  }
}

class BlinkBackground extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BlinkBackgroundState();
  }
}

class _BlinkBackgroundState extends State<BlinkBackground> {
  @override
  Widget build(BuildContext context) {
    return Selector<MetronomeOptionsNotifier, Tuple2<int, bool>>(
        builder: (_, obj, __) {
      // adjust timer and tempo inside container -> how to animate blinking?
      // TODO: animate
      return Container();
    });
  }
}
