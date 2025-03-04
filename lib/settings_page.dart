import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _rollAmountSlider = 3;
  double _rollSpeedSlider = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center (
        child: Column(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 200),
            const Text(
              'Roll Amount:',
              style: TextStyle(
                fontSize: 28,
              ),
            ),
            Slider(
              value: _rollAmountSlider,
              max: 5,
              min: 1,
              divisions: 4,
              label: _rollAmountSlider.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _rollAmountSlider = value;
                });
              },
            ),
            SizedBox(height: 150),
            const Text(
              'Roll Speed:',
              style: TextStyle(
                fontSize: 28,
              ),
            ),
            Slider(
              value: _rollSpeedSlider,
              max: 5,
              min: 1,
              divisions: 4,
              label: '${_rollSpeedSlider.round()}x',
              onChanged: (double value) {
                setState(() {
                  _rollSpeedSlider = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}