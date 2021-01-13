import 'package:flutter/material.dart';
import 'package:shmetronome/constants/constants.dart';

class TempoBarController extends ChangeNotifier {
  TempoBarController({@required numBoxes, blinkAt}) {
    this._numBoxes = numBoxes;
    this._blinkAt = blinkAt;
  }

  int _numBoxes;
  int _blinkAt;

  int get numBoxes => this._numBoxes;
  int get blinkAt => this._blinkAt;

  set numBoxes(int num) {
    if (this._numBoxes != num) {
      this._numBoxes = num;
      this._blinkAt = null;
      notifyListeners();
    }
  }

  void blinkAtIndex(int indx) {
    _blinkAt = indx;
    notifyListeners();
  }
}

class TempoBar extends StatefulWidget {
  TempoBar({@required this.controller});

  final TempoBarController controller;

  @override
  State<StatefulWidget> createState() {
    return _TempoBarState();
  }
}

class _TempoBarState extends State<TempoBar> {
  List<TempoBox> _boxes;
  int _numBoxes;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      if (this._numBoxes != widget.controller.numBoxes) {
        setState(() {
          _updateBoxes();
        });
      }
      if (widget.controller.blinkAt != null) {
        _boxes[widget.controller.blinkAt].controller.blink();
      }
    });

    _updateBoxes();
  }

  @override
  void dispose() {
    super.dispose();

    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("-----------------tempo box count: ${_boxes.length}");
    return Expanded(
      flex: 2,
      child: Row(
        children: _boxes,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }

  void _updateBoxes() {
    final List<TempoBox> boxes = [];
    for (int i = 0; i < widget.controller.numBoxes; i++) {
      boxes.add(TempoBox(controller: TempoBoxController()));
    }
    _boxes = boxes;
    _numBoxes = boxes.length;
  }
}

class TempoBoxController extends ChangeNotifier {
  void blink() {
    notifyListeners();
  }
}

class TempoBox extends StatefulWidget {
  TempoBox({@required this.controller});

  final TempoBoxController controller;

  @override
  _TempoBoxState createState() {
    return _TempoBoxState();
  }
}

class _TempoBoxState extends State<TempoBox>
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
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[700].withOpacity(_animController.value),
          border: Border.all(color: Colors.grey[900], width: 1),
          borderRadius: BorderRadius.all(Radius.circular(Dimens.smol_radius)),
        ),
      ),
    );
  }
}
