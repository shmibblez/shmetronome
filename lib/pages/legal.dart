import 'package:flutter/material.dart';

enum LegalType { termsAndConditions, privacyPolicy }

class LegalPage extends StatelessWidget {
  LegalPage({@required this.legalType});
  final LegalType legalType;
  final String tc = "shmetronome (we, us, our), are a simple app, and don't have a database so this should be pretty simple. " +
      "By using shmetronome you agree to these Terms and acknowledge that you have read our Privacy Policy and agree " +
      "to it. For the sake of simplicity, we're not responsible for any damages that may occur due to the use of " +
      "shmetronome, including personal injury, or damage to others." +
      "\n\n" +
      "We created this app so that others could use a metronome with vibration capabilities, since most mobile phones " +
      "are capable of using it, and it comes in handy. Don't do anything that may harm yourself or others.";
  final String pp =
      "shmetronome (we, us), don't send or receive data, or otherwise interact with the internet. We do however " +
          "store metronome options such as enabled indicators (click, vibration, blinking background), or last tempo, but this data " +
          "stays on your device. In an upcoming update we may change this in order to add analytics (anonymized of course), and possibly " +
          "a database of metronome sounds uploaded by the community, which would be pretty epic.";
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    (this.legalType == LegalType.termsAndConditions
                            ? "Terms and Conditions"
                            : "Privacy Policy") +
                        "\n",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    this.legalType == LegalType.termsAndConditions ? tc : pp,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
