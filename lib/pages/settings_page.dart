import 'package:flutter/material.dart';
import 'package:shmetronome/pages/legal.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "legal",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text("Terms and Conditions"),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LegalPage(
                        legalType: LegalType.termsAndConditions,
                      )));
            },
          ),
          TextButton(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text("Privacy Policy"),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LegalPage(
                        legalType: LegalType.privacyPolicy,
                      )));
            },
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "...\n\nmore settings coming soon",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
