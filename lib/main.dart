import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shmetronome/change_notifiers/metronome_options.dart';
import 'package:shmetronome/pages/metronome_page.dart';
import 'package:shmetronome/pages/settings_page.dart';
import 'package:soundpool/soundpool.dart';

// CHORE:
// not really chore, just red because looks nice
//
// app stuff / structure:
// - make provider app parent (shares stuff like tempo, item colors, etc (if changed from settings, rebuild))
// - when tempo is changed (scroll bar), update tempo click, vibration, and screen flashes for next scheduled flash
// - IMPORTANT: make sure Provider notifies all consumers at same time
// widget structure
// - provider is parent (above)
// - indexed stack with bottom nav (metronome & settings) is child
//   METRONOME NAV SELECTED: ----
// - child is stack (buttons & visible screen 1 child, and behind have screen that flashes to show tempo (only rebuild background flashing screen on metronome tick)
//
// CONSIDERATIONS:
// - how to time ticks? have async timer and on each tick vibrate, click, and flash screen depending on selected items? (if no item selected, don't activate timer)
//   - use Timer.periodic? (yeah looks like best option)
// - lowest & highest tempo? -> 20-400?
//
// IMPROVEMENTS:
// - initially tempo selector will be slider, but turn into 3d wheel later (wheel inside screen - sides are smaller and center is bigger, looks like wheel inside screen)
// -

// steps
// - first get shared preferences (last tempo, settings like colors, etc)
// - init BlocProvider with options -> MetronomeOptionsCubit
// - create bottom nav with metronome screen as default
// - setup metronome screen (bloc notifies changes in options, timers commit actions on each metronome click (vibrate, click, blink)), remember stack (buttons in front, blinking screen behind (will be rebuilt constantly))
// INDIVIDUAL ACTION HANDLING (WHEN TO CLICK)
// - blinking screen receives metronome options, and listens to tempo changes and whether enabled or not. Has individual timer whos bpm is determined by tempo
// -------- vibration is in metronome button stack (in front of blinking screen), and listens to tempo change and whether enabled. Can be paired with click timer (if enabled -> vibrate and if cliick -> playSound)
// - individual tempo boxes blink depending on beat number (box #), and here logic can include vibration and click if enabled, since boxes always blink
// - boxes blink one after the other depending on current beat #
// - beat # is modified in box blink timer

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: initialSetup(),
    );
  }
}

Widget initialSetup() {
  return FutureBuilder<MetronomeOptionsNotifier>(
    future: loadPrefs(),
    builder:
        (BuildContext _, AsyncSnapshot<MetronomeOptionsNotifier> snapshot) {
      if (snapshot.hasData) {
        return ChangeNotifierProvider.value(
          value: snapshot.data,
          child: BottomNavContainer(),
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  );
}

/// get metronome options from SharedPreferences
Future<MetronomeOptionsNotifier> loadPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Soundpool pool = Soundpool(streamType: StreamType.notification);

  return MetronomeOptionsNotifier(
    tempoBPM: prefs.getInt("tempo") ?? 200,
    clickEnabled: prefs.getBool("clickEnabled") ?? true,
    blinkEnabled: prefs.getBool("blinkEnabled") ?? false,
    vibrationEnabled: prefs.getBool("vibrationEnabled") ?? false,
    playing: prefs.getBool("vibrationEnabled") ?? true,
  );
}

class BottomNavContainer extends StatefulWidget {
  @override
  _BottomNavContainerState createState() {
    return _BottomNavContainerState();
  }
}

class _BottomNavContainerState extends State<BottomNavContainer> {
  int _selectedPageIndex;
  List<Widget> _pages;
  List<BottomNavigationBarItem> _bottomNavItems;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    _selectedPageIndex = 0;
    _pages = [
      MetronomePage(),
      SettingsPage(),
    ];
    _bottomNavItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.timer),
        label: "metronome",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "settings",
      ),
    ];

    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    super.dispose();

    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems,
        currentIndex: _selectedPageIndex,
        onTap: (selectedPageIndex) {
          setState(() {
            _selectedPageIndex = selectedPageIndex;
            _pageController.jumpToPage(selectedPageIndex);
          });
        },
      ),
    );
  }
}
