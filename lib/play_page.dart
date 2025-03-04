import 'package:flutter/material.dart';
import 'dart:math';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key, required this.title});

  final String title;

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int screenIndex = 0;
  late bool showNavigationDrawer;

  int _die1 = 6;
  int _die2 = 6;
  int _die3 = 6;
  int _die4 = 6;
  int _die5 = 6;

  void rollDice () {
    setState(() {
      _die1 = Random().nextInt(6)+1;
      _die2 = Random().nextInt(6)+1;
      _die3 = Random().nextInt(6)+1;
      _die4 = Random().nextInt(6)+1;
      _die5 = Random().nextInt(6)+1;
    });
  }

  void openDrawer () {
    scaffoldKey.currentState!.openEndDrawer();
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Quit',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Die 1: $_die1',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            Text(
              'Die 2: $_die2',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            Text(
              'Die 3: $_die3',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            Text(
              'Die 4: $_die4',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            Text(
              'Die 5: $_die5',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  rollDice();
                },
                child: Text(
                  'Roll!',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.green,
                  ),
                )
            ),
            ElevatedButton(
                onPressed: () {
                  openDrawer();
                },
                child: Text(
                  'Scoring',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
            ),
          ],
        ),
      ),
      endDrawer: NavigationDrawer(
          onDestinationSelected: handleScreenChanged,
          selectedIndex: screenIndex,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Text(
                'Header',
              ),
            ),
          ]
      ),
    );
  }
}