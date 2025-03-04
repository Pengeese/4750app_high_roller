import 'package:flutter/material.dart';

class ScorecardPage extends StatefulWidget {
  const ScorecardPage({super.key, required this.title});

  final String title;

  @override
  State<ScorecardPage> createState() => _ScorecardPageState();
}

class _ScorecardPageState extends State<ScorecardPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Scoring Page with scorecard ui',
            ),
          ],
        ),
      ),
    );
  }
}