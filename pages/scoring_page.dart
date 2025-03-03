import 'package:flutter/material.dart';

class ScoringPage extends StatefulWidget {
  @override
  _ScoringPageState createState() => _ScoringPageState();
}

class _ScoringPageState extends State<ScoringPage> {
  int _numEnds = 6; // Default value for number of ends
  int _arrowsPerEnd = 3; // Default value for arrows per end
  List<String> _selectedUsers = []; // List of selected users
  final List<String> _allUsers = ['Alice', 'Bob', 'Charlie']; // Dummy users

  Map<String, List<List<int>>> _scores = {}; // Stores scores per user
  Map<String, int> _totalScores = {}; // Stores total score per user (change to int)
  int _currentUserIndex = 0; // Track the current user for rotation

  @override
  void initState() {
    super.initState();
    _initializeScores();
  }

  void _initializeScores() {
    _scores = {
      for (var user in _allUsers)
        user: List.generate(_numEnds, (_) => List.filled(_arrowsPerEnd, 0))
    };
    _totalScores = {
      for (var user in _allUsers) user: 0, // Initialize total scores as 0
    };
  }

  // Calculate total score for a user
  int _calculateTotalScore(String user) {
    return _scores[user]!.expand((end) => end).fold(0, (sum, score) => sum + score);
  }

  // Update the score for a specific user, end, and arrow
  void _updateScore(String user, int end, int arrow, int score) {
    setState(() {
      // Correctly assign the score to the nested list
      _scores[user]![end][arrow] = score;
      _totalScores[user] = _calculateTotalScore(user); // Update total score
    });
  }

  // Rotate to the next user automatically
  void _nextUser() {
    setState(() {
      _currentUserIndex = (_currentUserIndex + 1) % _selectedUsers.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scoring')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsSection(),
            const SizedBox(height: 16),
            _buildUsersSelection(),
            const SizedBox(height: 16),
            _buildScoringArea(),
          ],
        ),
      ),
    );
  }

  // Section for selecting ends and arrows per end
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Setup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Number of Ends'),
                keyboardType: TextInputType.number,
                initialValue: _numEnds.toString(),
                onChanged: (value) {
                  setState(() {
                    _numEnds = int.tryParse(value) ?? _numEnds;
                    _initializeScores();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Arrows per End'),
                keyboardType: TextInputType.number,
                initialValue: _arrowsPerEnd.toString(),
                onChanged: (value) {
                  setState(() {
                    _arrowsPerEnd = int.tryParse(value) ?? _arrowsPerEnd;
                    _initializeScores();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Section for selecting users
  Widget _buildUsersSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 10,
          children: _allUsers.map((user) {
            final isSelected = _selectedUsers.contains(user);
            return FilterChip(
              label: Text(user),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedUsers.add(user);
                  } else {
                    _selectedUsers.remove(user);
                  }
                  _initializeScores();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Section for scoring input (user scoring areas)
  Widget _buildScoringArea() {
    if (_selectedUsers.isEmpty) {
      return const Center(child: Text('Select at least one user to start scoring.'));
    }

    return Expanded(
      child: ListView(
        children: _selectedUsers.map((user) {
          return _buildUserScoringArea(user);
        }).toList(),
      ),
    );
  }

  // Separate scoring area for each user
  Widget _buildUserScoringArea(String user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Total Score: ${_totalScores[user]}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                // Scores for arrows
                Expanded(
                  child: Column(
                    children: List.generate(_numEnds, (endIndex) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End ${endIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // Adjust as needed
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: _arrowsPerEnd,
                            itemBuilder: (context, arrowIndex) {
                              return _buildScoreButton(user, endIndex, arrowIndex);
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                // Score per end column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_numEnds, (endIndex) {
                    int endScore = _scores[user]![endIndex].fold(0, (sum, score) => sum + score);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('End ${endIndex + 1}: $endScore'),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Button for scoring input
  Widget _buildScoreButton(String user, int end, int arrow) {
    final scoreButtons = [10, 9, 8, 7, -1]; // -1 represents "Miss", which counts as 0

    return ElevatedButton(
      onPressed: () {
        int score = scoreButtons[arrow];
        if (score == -1) score = 0; // Miss counts as 0 points
        _updateScore(user, end, arrow, score);
        _nextUser(); // Automatically move to the next user
      },
      child: Text(
        scoreButtons[arrow] == -1 ? 'Miss' : scoreButtons[arrow].toString(),
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
