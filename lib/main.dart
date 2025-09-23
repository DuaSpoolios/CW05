import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}
class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 100;

  final TextEditingController _nameController = TextEditingController();
  Timer? _hungerTimer;     
  Timer? _winTimer;       
  bool _gameOverShown = false; 

  //Activity selection state
  String _selectedActivity= 'Play';
  final List<String> _activities = ['Play', 'Feed', 'Rest'];

  @override
  void initState() {
    super.initState();

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel += 5;
        if (hungerLevel > 100) {
          hungerLevel = 100;
          happinessLevel -= 20;
          if (happinessLevel < 0) happinessLevel = 0;
        }
        energyLevel -= 2;
        if (energyLevel< 0) energyLevel = 0;

        _checkWinCondition();
        _checkLossCondition();
      });
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Color _getPetColor() {
    if (happinessLevel > 70) return Colors.green;
    if (happinessLevel >= 30) return Colors.yellow;
    return Colors.red;
  }

  Map<String, dynamic> _getMood() {
    if (happinessLevel > 70) {
      return {'label': 'Happy', 'icon': Icons.sentiment_satisfied, 'color': Colors.green};
    } else if (happinessLevel >= 30) {
      return {'label': 'Neutral', 'icon': Icons.sentiment_neutral, 'color': Colors.amber};
    } else {
      return {'label': 'Unhappy', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.red};
    }
  }

  void _setPetName() {
    setState(() {
      if (_nameController.text.trim().isNotEmpty) {
        petName = _nameController.text.trim();
      }
    });
  }

  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      energyLevel -= 5; if (energyLevel < 0) energyLevel = 0;
      _updateHunger();
      _checkWinCondition();
      _checkLossCondition();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 10;
      if (hungerLevel < 0) hungerLevel = 0;
      energyLevel += 5; if (energyLevel > 100) energyLevel = 100;
      _updateHappiness();
      _checkWinCondition();
      _checkLossCondition();
    });
  }

  void _restPet() {
    setState(() {
      energyLevel += 10; if (energyLevel > 100) energyLevel = 100;
      happinessLevel += 5; if (happinessLevel > 100) happinessLevel = 100;
      _checkWinCondition();
      _checkLossCondition();
    });
  }
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel -= 20;
      if (happinessLevel < 0) happinessLevel = 0;
    } else {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
    }
  }

  void _updateHunger() {
    hungerLevel += 5;
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel -= 20;
      if (happinessLevel < 0) happinessLevel = 0;
    }
  }

  //Win lose logic
  void _checkWinCondition() {
    if (happinessLevel > 80 && _winTimer == null) {
      _winTimer = Timer(const Duration(minutes: 3), () {
        if (mounted && happinessLevel > 80) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 You Win! Your pet is super happy!'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      });
    }
    if (happinessLevel <= 80 && _winTimer != null) {
      _winTimer!.cancel();
      _winTimer = null;
    }
  }

  void _checkLossCondition() {
    if (!_gameOverShown && hungerLevel >= 100 && happinessLevel <= 10) {
      _gameOverShown = true;
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: const Text('Your pet is starving and unhappy.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      petName = "Your Pet";
      happinessLevel= 50;
      hungerLevel= 50;
      energyLevel= 100;
      _gameOverShown = false;
      _winTimer?.cancel();
      _winTimer = null;
      _selectedActivity = 'Play';
    });
  }


  void _confirmActivity() {
    if (_selectedActivity == 'Play') {
      _playWithPet();
    } else if (_selectedActivity == 'Feed') {
      _feedPet();
    } else if (_selectedActivity == 'Rest') {
      _restPet();
    }
  }

//UI code
  @override
  Widget build(BuildContext context) {
    final mood = _getMood();

    return Scaffold(
//Gradient background using a Container
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5), 
              Color(0xFFFFB6C1), 
              Color(0xFFFFA6B6), 
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "What's your pet's name?",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _setPetName,
                  child: const Text('Set Pet Name'),
                ),
                const SizedBox(height: 20),

                Text('Name: $petName', style: const TextStyle(fontSize: 20.0)),
                const SizedBox(height: 16.0),
                Text('Happiness Level: $happinessLevel',
                    style: const TextStyle(fontSize: 20.0)),
                const SizedBox(height: 16.0),
                Text('Hunger Level: $hungerLevel',
                    style: const TextStyle(fontSize: 20.0)),
                const SizedBox(height: 16.0),
                Text('Energy Level: $energyLevel%',
                    style: const TextStyle(fontSize: 20.0)),
                const SizedBox(height: 32.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getPetColor(),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/images/cat.png',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        Icon(
                          mood['icon'],
                          color: mood['color'],
                          size: 50,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: mood['color'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                //Activity Selection
                const Text(
                  'Select an activity:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedActivity,
                  items: _activities
                      .map((activity) => DropdownMenuItem<String>(
                            value: activity,
                            child: Text(activity),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivity = value!;
                    });
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _confirmActivity,
                  child: const Text('Do Activity'),
                ),
                const SizedBox(height: 30),

          //Energy Bar
                Column(
                  children: [
                    const Text(
                      'Energy',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: energyLevel/100,
                      minHeight: 20,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height:10),
                    Text(
                      '$energyLevel%',
                      style: const TextStyle(fontSize:16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

