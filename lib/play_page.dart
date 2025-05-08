import 'package:flutter/material.dart';
import 'dart:math';

class PlayPage extends StatefulWidget {
  const PlayPage({
    super.key,
    required this.title,
    this.initialRollAmount = 3, // Default 3 rolls per turn
  });

  final String title;
  final int initialRollAmount;

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late int _rollsRemaining;

  // Player management
  int currentPlayer = 1; // 1 or 2
  String playerTurnText = "Player 1's Turn";

  // Dice state
  List<int> diceValues = [6, 6, 6, 6, 6];
  List<bool> heldDice = [false, false, false, false, false];

  // Roll management
  //int rollsRemaining = 3;
  bool turnEnded = false;

  // Score tracking
  Map<String, int?> player1Scores = {
    'ones': null,
    'twos': null,
    'threes': null,
    'fours': null,
    'fives': null,
    'sixes': null,
    'threeOfKind': null,
    'fourOfKind': null,
    'fullHouse': null,
    'smallStraight': null,
    'largeStraight': null,
    'highRoll': null,
    'chance': null,
  };

  Map<String, int?> player2Scores = {
    'ones': null,
    'twos': null,
    'threes': null,
    'fours': null,
    'fives': null,
    'sixes': null,
    'threeOfKind': null,
    'fourOfKind': null,
    'fullHouse': null,
    'smallStraight': null,
    'largeStraight': null,
    'highRoll': null,
    'chance': null,
  };

  @override
  void initState() {
    super.initState();
    _rollsRemaining = widget.initialRollAmount;
    resetRolls();
  }

  void resetRolls() {
    _rollsRemaining = widget.initialRollAmount;
    turnEnded = false;
    heldDice = List.generate(5, (_) => false);
  }

  void rollDice() {
    if (_rollsRemaining > 0 && !turnEnded) {
      setState(() {
        for (int i = 0; i < 5; i++) {
          if (!heldDice[i]) {
            diceValues[i] = Random().nextInt(6) + 1;
          }
        }
        _rollsRemaining--;

        if (_rollsRemaining == 0) {
          // Auto-open the score card when out of rolls
          Future.delayed(Duration(milliseconds: 500), () {
            openDrawer();
          });
        }
      });
    }
  }

  void toggleHold(int dieIndex) {
    if (_rollsRemaining < widget.initialRollAmount && !turnEnded) { // Can only hold after first roll
      setState(() {
        heldDice[dieIndex] = !heldDice[dieIndex];
      });
    }
  }

  void openDrawer() {
    scaffoldKey.currentState!.openEndDrawer();
  }

  void endTurn() {
    setState(() {
      // Switch players
      currentPlayer = currentPlayer == 1 ? 2 : 1;
      playerTurnText = "Player $currentPlayer's Turn";

      // Reset for new turn
      resetRolls();

      // Reset dice
      for (int i = 0; i < 5; i++) {
        diceValues[i] = 6;
      }

      // Check if game is over
      if (isGameOver()) {
        showGameOverDialog();
      }
    });
  }

  bool isGameOver() {
    // Game is over when all score categories are filled for both players
    return !player1Scores.values.contains(null) && !player2Scores.values.contains(null);
  }

  void showGameOverDialog() {
    int player1Total = calculateTotalScore(player1Scores);
    int player2Total = calculateTotalScore(player2Scores);
    String winner = player1Total > player2Total ? "Player 1" : (player2Total > player1Total ? "Player 2" : "It's a tie");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Player 1 Score: $player1Total'),
              Text('Player 2 Score: $player2Total'),
              SizedBox(height: 16),
              Text(
                player1Total == player2Total
                    ? "It's a tie!"
                    : "$winner wins!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Return to Menu'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to main menu
              },
            ),
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      player1Scores = Map.fromEntries(
          player1Scores.keys.map((key) => MapEntry(key, null))
      );
      player2Scores = Map.fromEntries(
          player2Scores.keys.map((key) => MapEntry(key, null))
      );
      currentPlayer = 1;
      playerTurnText = "Player 1's Turn";
      resetRolls();
      for (int i = 0; i < 5; i++) {
        diceValues[i] = 6;
        heldDice[i] = false;
      }
    });
  }

  int calculateTotalScore(Map<String, int?> scores) {
    int total = 0;
    int upperSectionSum = 0;

    // Sum upper section (ones through sixes)
    upperSectionSum += scores['ones'] ?? 0;
    upperSectionSum += scores['twos'] ?? 0;
    upperSectionSum += scores['threes'] ?? 0;
    upperSectionSum += scores['fours'] ?? 0;
    upperSectionSum += scores['fives'] ?? 0;
    upperSectionSum += scores['sixes'] ?? 0;

    // Add upper section bonus if applicable
    if (upperSectionSum >= 63) {
      total += 35; // Upper section bonus
    }

    // Add all scores
    for (var score in scores.values) {
      total += score ?? 0;
    }

    return total;
  }

  void scoreSelectedCategory(String category) {
    Map<String, int?> currentScores = currentPlayer == 1 ? player1Scores : player2Scores;

    // If category is already filled, don't allow scoring it again
    if (currentScores[category] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This category is already scored!')),
      );
      return;
    }

    int score = calculateScore(category, diceValues);

    setState(() {
      if (currentPlayer == 1) {
        player1Scores[category] = score;
      } else {
        player2Scores[category] = score;
      }

      // Close drawer and end turn
      Navigator.pop(context);
      endTurn();
    });
  }

  int calculateScore(String category, List<int> dice) {
    // Sort dice for easier calculation
    List<int> sortedDice = List.from(dice)..sort();

    // Count occurrences of each die value
    Map<int, int> valueCounts = {};
    for (int die in dice) {
      valueCounts[die] = (valueCounts[die] ?? 0) + 1;
    }

    switch (category) {
      case 'ones':
        return dice.where((die) => die == 1).length * 1;
      case 'twos':
        return dice.where((die) => die == 2).length * 2;
      case 'threes':
        return dice.where((die) => die == 3).length * 3;
      case 'fours':
        return dice.where((die) => die == 4).length * 4;
      case 'fives':
        return dice.where((die) => die == 5).length * 5;
      case 'sixes':
        return dice.where((die) => die == 6).length * 6;
      case 'threeOfKind':
        if (valueCounts.values.any((count) => count >= 3)) {
          return dice.reduce((sum, die) => sum + die);
        }
        return 0;
      case 'fourOfKind':
        if (valueCounts.values.any((count) => count >= 4)) {
          return dice.reduce((sum, die) => sum + die);
        }
        return 0;
      case 'fullHouse':
        if (valueCounts.values.contains(3) && valueCounts.values.contains(2)) {
          return 25;
        }
        return 0;
      case 'smallStraight':
      // Check for 1-2-3-4 or 2-3-4-5 or 3-4-5-6
        if ((sortedDice.contains(1) && sortedDice.contains(2) && sortedDice.contains(3) && sortedDice.contains(4)) ||
            (sortedDice.contains(2) && sortedDice.contains(3) && sortedDice.contains(4) && sortedDice.contains(5)) ||
            (sortedDice.contains(3) && sortedDice.contains(4) && sortedDice.contains(5) && sortedDice.contains(6))) {
          return 30;
        }
        return 0;
      case 'largeStraight':
      // Check for 1-2-3-4-5 or 2-3-4-5-6
        if ((sortedDice[0] == 1 && sortedDice[1] == 2 && sortedDice[2] == 3 && sortedDice[3] == 4 && sortedDice[4] == 5) ||
            (sortedDice[0] == 2 && sortedDice[1] == 3 && sortedDice[2] == 4 && sortedDice[3] == 5 && sortedDice[4] == 6)) {
          return 40;
        }
        return 0;
      case 'highRoll':
        if (valueCounts.values.any((count) => count == 5)) {
          return 50;
        }
        return 0;
      case 'chance':
        return dice.reduce((sum, die) => sum + die);
      default:
        return 0;
    }
  }

  Widget buildDie(int index) {
    // Colors and styling
    Color dieColor = heldDice[index] ? Colors.amber.shade600 : Colors.white;
    Color textColor = heldDice[index] ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () => toggleHold(index),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: dieColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: buildDieFace(diceValues[index], textColor),
        ),
      ),
    );
  }

  Widget buildDieFace(int value, Color dotColor) {
    switch (value) {
      case 1:
        return Center(child: buildDot(dotColor));
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.topRight, child: Padding(padding: EdgeInsets.all(10), child: buildDot(dotColor))),
            Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.all(10), child: buildDot(dotColor))),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.topRight, child: Padding(padding: EdgeInsets.all(10), child: buildDot(dotColor))),
            Center(child: buildDot(dotColor)),
            Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.all(10), child: buildDot(dotColor))),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildDot(dotColor), buildDot(dotColor)],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildDot(dotColor), buildDot(dotColor)],
              ),
            ),
          ],
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildDot(dotColor), buildDot(dotColor)],
              ),
            ),
            Center(child: buildDot(dotColor)),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildDot(dotColor), buildDot(dotColor)],
              ),
            ),
          ],
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildDot(dotColor), buildDot(dotColor)],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildDot(dotColor), buildDot(dotColor)],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildDot(dotColor), buildDot(dotColor)],
              ),
            ),
          ],
        );
      default:
        return Text(value.toString());
    }
  }

  Widget buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: openDrawer,
            child: Text(
              'Scorecard',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.purple.shade900, Colors.black]
                : [Colors.purple.shade200, Colors.deepPurple.shade800],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Player turn indicator
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    playerTurnText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Rolls remaining indicator
                Text(
                  'Rolls Remaining: $_rollsRemaining',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 30),

                // Dice row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) => buildDie(index)),
                  ),
                ),

                SizedBox(height: 20),

                // Hint text
                if (_rollsRemaining < widget.initialRollAmount && _rollsRemaining > 0)
                  Text(
                    'Tap dice to hold them',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),

                SizedBox(height: 40),

                // Roll button
                ElevatedButton(
                  onPressed: _rollsRemaining > 0 ? rollDice : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                  ),
                  child: Text(
                    'ROLL DICE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Score button
                ElevatedButton(
                  onPressed: openDrawer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'VIEW SCORECARD',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      endDrawer: Drawer(
        child: Container(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.deepPurple.shade800,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scorecard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        playerTurnText,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    children: [
                      // Upper section title
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.grey.withOpacity(0.2),
                        child: Text(
                          'Upper Section',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      // Upper section scoring options
                      buildScoreOption('Ones', 'Sum of all ones', 'ones'),
                      buildScoreOption('Twos', 'Sum of all twos', 'twos'),
                      buildScoreOption('Threes', 'Sum of all threes', 'threes'),
                      buildScoreOption('Fours', 'Sum of all fours', 'fours'),
                      buildScoreOption('Fives', 'Sum of all fives', 'fives'),
                      buildScoreOption('Sixes', 'Sum of all sixes', 'sixes'),

                      // Lower section title
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.grey.withOpacity(0.2),
                        child: Text(
                          'Lower Section',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      // Lower section scoring options
                      buildScoreOption('Three of a Kind', 'Sum of all dice', 'threeOfKind'),
                      buildScoreOption('Four of a Kind', 'Sum of all dice', 'fourOfKind'),
                      buildScoreOption('Full House', '25 points', 'fullHouse'),
                      buildScoreOption('Small Straight', '30 points', 'smallStraight'),
                      buildScoreOption('Large Straight', '40 points', 'largeStraight'),
                      buildScoreOption('High Roll', '50 points', 'highRoll'),
                      buildScoreOption('Chance', 'Sum of all dice', 'chance'),

                      // Scoreboard
                      Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.grey.withOpacity(0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Scores',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Player 1',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${calculateTotalScore(player1Scores)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Player 2',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${calculateTotalScore(player2Scores)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildScoreOption(String title, String description, String category) {
    // Get current player's scores
    Map<String, int?> currentScores = currentPlayer == 1 ? player1Scores : player2Scores;

    // Calculate potential score for this category with current dice
    int potentialScore = currentScores[category] ?? calculateScore(category, diceValues);

    // Check if this category is already scored
    bool alreadyScored = currentScores[category] != null;

    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: Text(
        alreadyScored ? '${currentScores[category]}' : '$potentialScore',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: alreadyScored ? Colors.grey : Colors.deepPurple,
        ),
      ),
      enabled: !alreadyScored && _rollsRemaining < widget.initialRollAmount,
      onTap: alreadyScored || _rollsRemaining == widget.initialRollAmount
          ? null
          : () => scoreSelectedCategory(category),
    );
  }
}