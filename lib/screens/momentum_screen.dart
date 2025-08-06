import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../models/match_model.dart';
import 'overview_stats_screen.dart';

class MomentumScreen extends StatefulWidget {
  const MomentumScreen({super.key});

  @override
  State<MomentumScreen> createState() => _MomentumScreenState();
}

class _MomentumScreenState extends State<MomentumScreen> {
  int _currentSet = 1; // Default to Set 1
  List<FlSpot> _momentumData = [];
  List<MomentumPoint> _pointHistory = [];
  Match? _currentMatch;
  
  // Store momentum data per set
  Map<int, List<MomentumPoint>> _setPointHistory = {
    1: [],
    2: [],
    3: [],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentMatch();
    });
  }

  void _loadCurrentMatch() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (appProvider.matches.isNotEmpty) {
      setState(() {
        _currentMatch = appProvider.matches.reduce(
          (a, b) => a.date.isAfter(b.date) ? a : b,
        );
        _generateMomentumData();
      });
    } else {
      // Create a sample match for demonstration when no match data is available
      setState(() {
        _currentMatch = Match(
          id: 'sample-match',
          playerName: 'You',
          opponentName: 'Opponent',
          format: MatchFormat.bestOfThree,
          type: MatchType.friendly,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          result: MatchResult.inProgress,
          sets: [
            Set(
              playerGames: 4,
              opponentGames: 3,
              playerWon: false,
            ),
            Set(
              playerGames: 2,
              opponentGames: 4,
              playerWon: false,
            ),
          ],
        );
        _generateMomentumData();
      });
    }
  }

  void _generateMomentumData() {
    // Generate initial momentum data based on match statistics only if no manual points added
    if (_currentMatch != null && _setPointHistory[_currentSet]?.isEmpty != false) {
      final initialPoints = _generatePointHistory();
      _setPointHistory[_currentSet] = initialPoints;
    }
    
    // Load current set's data
    _pointHistory = _setPointHistory[_currentSet] ?? [];
    _momentumData = _pointHistory.map((point) => FlSpot(point.x, point.y)).toList();
  }

  List<MomentumPoint> _generatePointHistory() {
    // Generate momentum points based on match statistics
    List<MomentumPoint> points = [];
    final aces = _currentMatch?.aces ?? 0;
    final faults = _currentMatch?.faults ?? 0;
    final successful = _currentMatch?.successfulServes ?? 0;

    // Create momentum based on serve performance
    double momentum = 0;
    for (int i = 0; i < (aces + faults + successful).clamp(1, 20); i++) {
      bool isWon =
          i < aces || (i >= aces + faults && i < aces + faults + successful);
      momentum += isWon ? 20 : -15;
      momentum = momentum.clamp(-100.0, 100.0);

      points.add(
        MomentumPoint(
          x: i.toDouble(),
          y: momentum,
          isPointWon: isWon,
          isBreakpoint: i % 7 == 0 && i > 0, // Every 7th point as breakpoint
        ),
      );
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(color: Color(0xFF3C3C3C)),
              child: const Text(
                'Momentum Chart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
        child: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            return Column(
              children: [
                // Set selector
                _buildSetSelector(),
                const SizedBox(height: 20),

                // Momentum chart
                _buildMomentumChart(),
                const SizedBox(height: 20),

                // Action buttons
                _buildActionButtons(),
                const SizedBox(height: 20),

                // Current account section
                _buildCurrentAccount(),
                const SizedBox(height: 20),

                // Share Chart button
                _buildShareButton(),
              ],
            );
          },
        ),
      ),
      // Bottom buttons
      bottomSheet: Container(
        color: const Color(0xFF1C1C1C),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C3C3C),
                        side: const BorderSide(color: Color(0xFF5C5C5C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12, height: 65),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _endMatch,
                      icon: const Icon(Icons.stop, color: Colors.white),
                      label: const Text(
                        'End Match',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E3E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed:
                _currentSet > 1 ? () => _changeSet(_currentSet - 1) : null,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'SET $_currentSet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed:
                _currentSet < 2 ? () => _changeSet(_currentSet + 1) : null,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentumChart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C4C4C)),
      ),
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            verticalInterval: 1,
            horizontalInterval: 50,
            getDrawingVerticalLine: (value) {
              return const FlLine(color: Color(0xFF4C4C4C), strokeWidth: 1);
            },
            getDrawingHorizontalLine: (value) {
              return const FlLine(color: Color(0xFF4C4C4C), strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF9C9C9C),
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 50,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 100)
                    return const Text(
                      '+100',
                      style: TextStyle(color: Color(0xFF9C9C9C), fontSize: 12),
                    );
                  if (value == 0)
                    return const Text(
                      '0',
                      style: TextStyle(color: Color(0xFF9C9C9C), fontSize: 12),
                    );
                  if (value == -100)
                    return const Text(
                      '-100',
                      style: TextStyle(color: Color(0xFF9C9C9C), fontSize: 12),
                    );
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xFF4C4C4C)),
          ),
          minX: 0,
          maxX: _pointHistory.isNotEmpty ? (_pointHistory.length - 1).toDouble().clamp(10.0, double.infinity) : 10,
          minY: -100,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: _momentumData,
              isCurved: false,
              color: const Color(0xFF4CAF50),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final point = _pointHistory.firstWhere((p) => p.x == spot.x);
                  if (point.isBreakpoint) {
                    return FlDotSquarePainter(
                      color: const Color(0xFFE53E3E),
                      size: 8,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF4CAF50),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _addPointWon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '+ Point Won',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _addPointLost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '+ Point Lost',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _undoLast,
            icon: const Icon(Icons.undo, color: Colors.black),
            label: const Text(
              'Undo Last',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentAccount() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C4C4C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description, color: Color(0xFF9C9C9C), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Current account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFFFD54F), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Scores estimated from momentum data',
                      style: TextStyle(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.8),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score table
          Table(
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF3C3C3C)),
                children: [
                  _buildTableCell('Game', isHeader: true),
                  _buildTableCell('Set 1', isHeader: true),
                  _buildTableCell('Set 2', isHeader: true),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell(_currentMatch?.playerName ?? 'Player'),
                  _buildTableCell(_getSetScore(0, true)),
                  _buildTableCell(_getSetScore(1, true)),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF4C4C4C), width: 0.5),
                  ),
                ),
                children: [
                  _buildTableCell(_currentMatch?.opponentName ?? 'Opponent'),
                  _buildTableCell(_getSetScore(0, false)),
                  _buildTableCell(_getSetScore(1, false)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isHeader ? Colors.white : const Color(0xFF9C9C9C),
          fontSize: 14,
          fontFamily: isHeader ? 'Manrope' : 'Roboto',
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _shareChart,
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text(
          'Share Chart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _changeSet(int newSet) {
    setState(() {
      _currentSet = newSet;
      // Switch to the current set's point history
      _pointHistory = _setPointHistory[_currentSet] ?? [];
      _momentumData = _pointHistory.map((point) => FlSpot(point.x, point.y)).toList();
    });
  }

  String _getSetScore(int setIndex, bool isPlayer) {
    if (_currentMatch == null) {
      return '-';
    }
    
    // Check if we have actual set data
    if (_currentMatch!.sets.length > setIndex) {
      final set = _currentMatch!.sets[setIndex];
      if (isPlayer) {
        return set.playerGames.toString();
      } else {
        return set.opponentGames.toString();
      }
    }
    
    // Since we don't have real set data, create estimated scores based on momentum and match statistics
    return _getEstimatedSetScore(setIndex, isPlayer);
  }
  
  String _getEstimatedSetScore(int setIndex, bool isPlayer) {
    // Get current set's momentum data
    final setMomentumData = _setPointHistory[setIndex + 1] ?? [];
    
    if (setMomentumData.isEmpty) {
      // No momentum data for this set, show basic scores based on set status
      if (setIndex == 0) {
        // For Set 1, show example scores since match is in progress
        return isPlayer ? '4' : '3';
      } else if (setIndex == 1) {
        // For Set 2, show different example scores
        return isPlayer ? '2' : '4';  
      }
      
      return '0';
    }
    
    // Calculate score based on momentum data
    final pointsWon = setMomentumData.where((p) => p.isPointWon).length;
    final totalPoints = setMomentumData.length;
    final currentMomentum = setMomentumData.isNotEmpty ? setMomentumData.last.y : 0.0;
    
    if (totalPoints < 3) {
      // Not enough data, show current momentum-based estimate
      return _getScoreFromMomentum(currentMomentum, isPlayer);
    }
    
    // Calculate win percentage for this set
    final winRate = totalPoints > 0 ? (pointsWon / totalPoints) : 0.5;
    
    if (isPlayer) {
      // Player score based on momentum and win rate
      if (currentMomentum > 50 && winRate > 0.6) return '6';
      if (currentMomentum > 20 && winRate > 0.5) return '5';
      if (currentMomentum > 0 && winRate >= 0.5) return '4';
      if (currentMomentum > -20) return '3';
      if (currentMomentum > -50) return '2';
      return '1';
    } else {
      // Opponent score (inverse calculation)
      if (currentMomentum < -50 && winRate < 0.4) return '6';
      if (currentMomentum < -20 && winRate < 0.5) return '5';
      if (currentMomentum < 0 && winRate <= 0.5) return '4';
      if (currentMomentum < 20) return '3';
      if (currentMomentum < 50) return '2';
      return '1';
    }
  }
  
  String _getScoreFromMomentum(double momentum, bool isPlayer) {
    if (isPlayer) {
      if (momentum > 75) return '6';
      if (momentum > 50) return '5';
      if (momentum > 25) return '4';
      if (momentum > 0) return '3';
      if (momentum > -25) return '2';
      if (momentum > -50) return '1';
      return '0';
    } else {
      if (momentum < -75) return '6';
      if (momentum < -50) return '5';
      if (momentum < -25) return '4';
      if (momentum < 0) return '3';
      if (momentum < 25) return '2';
      if (momentum < 50) return '1';
      return '0';
    }
  }

  void _addPointWon() {
    setState(() {
      // Get current set's point history
      final currentSetPoints = _setPointHistory[_currentSet] ?? [];
      final lastPoint = currentSetPoints.isNotEmpty
          ? currentSetPoints.last
          : MomentumPoint(x: -1, y: 0, isPointWon: true);
      final newPoint = MomentumPoint(
        x: lastPoint.x + 1,
        y: (lastPoint.y + 25).clamp(-100.0, 100.0),
        isPointWon: true,
      );
      
      // Add to current set's history
      currentSetPoints.add(newPoint);
      _setPointHistory[_currentSet] = currentSetPoints;
      
      // Update display data
      _pointHistory = currentSetPoints;
      _momentumData = _pointHistory.map((point) => FlSpot(point.x, point.y)).toList();
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Point won added to momentum'),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addPointLost() {
    setState(() {
      // Get current set's point history
      final currentSetPoints = _setPointHistory[_currentSet] ?? [];
      final lastPoint = currentSetPoints.isNotEmpty
          ? currentSetPoints.last
          : MomentumPoint(x: -1, y: 0, isPointWon: false);
      final newPoint = MomentumPoint(
        x: lastPoint.x + 1,
        y: (lastPoint.y - 25).clamp(-100.0, 100.0),
        isPointWon: false,
      );
      
      // Add to current set's history
      currentSetPoints.add(newPoint);
      _setPointHistory[_currentSet] = currentSetPoints;
      
      // Update display data
      _pointHistory = currentSetPoints;
      _momentumData = _pointHistory.map((point) => FlSpot(point.x, point.y)).toList();
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Point lost added to momentum'),
        backgroundColor: Color(0xFFE53E3E),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _undoLast() {
    final currentSetPoints = _setPointHistory[_currentSet] ?? [];
    if (currentSetPoints.isNotEmpty) {
      setState(() {
        // Remove from current set's history
        currentSetPoints.removeLast();
        _setPointHistory[_currentSet] = currentSetPoints;
        
        // Update display data
        _pointHistory = currentSetPoints;
        _momentumData = _pointHistory.map((point) => FlSpot(point.x, point.y)).toList();
      });
      
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Last point removed from momentum'),
          backgroundColor: Color(0xFFFFD54F),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Show message when no points to undo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No points to undo'),
          backgroundColor: Color(0xFF9C9C9C),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _shareChart() {
    if (_currentMatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No match data to share'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
      return;
    }

    // Create a text summary of the momentum chart
    final StringBuffer shareText = StringBuffer();
    shareText.writeln('🎾 Tennis Match Momentum Chart');
    shareText.writeln('');
    shareText.writeln('Match: ${_currentMatch!.playerName} vs ${_currentMatch!.opponentName}');
    final date = _currentMatch!.date;
    shareText.writeln('Date: ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}');
    shareText.writeln('Set: $_currentSet');
    shareText.writeln('');
    
    if (_pointHistory.isNotEmpty) {
      shareText.writeln('📊 Momentum Points: ${_pointHistory.length}');
      final currentMomentum = _pointHistory.last.y;
      if (currentMomentum > 0) {
        shareText.writeln('🔥 Current Momentum: +${currentMomentum.toInt()}% (Positive)');
      } else if (currentMomentum < 0) {
        shareText.writeln('📉 Current Momentum: ${currentMomentum.toInt()}% (Negative)');
      } else {
        shareText.writeln('⚖️ Current Momentum: Neutral');
      }
      
      final pointsWon = _pointHistory.where((p) => p.isPointWon).length;
      final pointsLost = _pointHistory.length - pointsWon;
      shareText.writeln('');
      shareText.writeln('Points Won: $pointsWon');
      shareText.writeln('Points Lost: $pointsLost');
    } else {
      shareText.writeln('📊 No momentum data recorded yet');
    }
    
    shareText.writeln('');
    shareText.writeln('Shared from Tennis Insights App 🎾');

    Share.share(
      shareText.toString(),
      subject: 'Tennis Match Momentum - ${_currentMatch!.playerName} vs ${_currentMatch!.opponentName}',
    );
  }

  void _completeMatch() {
    if (_currentMatch != null) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      // Calculate point statistics from momentum data
      final pointStats = _calculatePointStatistics();
      
      final updatedMatch = _currentMatch!.copyWith(
        result: MatchResult.win, // You may want to ask user for win/loss
        completedAt: DateTime.now(),
        pointsWon: pointStats['pointsWon'],
        totalPoints: pointStats['totalPoints'],
        pointsWonServing: pointStats['pointsWonServing'],
        totalPointsServing: pointStats['totalPointsServing'],
        pointsWonReceiving: pointStats['pointsWonReceiving'],
        totalPointsReceiving: pointStats['totalPointsReceiving'],
        breakpointsConverted: pointStats['breakpointsConverted'],
        totalBreakpoints: pointStats['totalBreakpoints'],
      );
      appProvider.updateMatch(_currentMatch!.id, updatedMatch);
    }
  }
  
  Map<String, int> _calculatePointStatistics() {
    if (_pointHistory.isEmpty) {
      // If no momentum data, calculate based on serve statistics
      final totalServes = _currentMatch?.totalServes ?? 0;
      final aces = _currentMatch?.aces ?? 0;
      final successfulServes = _currentMatch?.successfulServes ?? 0;
      
      // Estimate points based on serves (rough calculation)
      final estimatedPointsWon = aces + (successfulServes * 0.7).round(); // Assume 70% win rate on successful serves
      final estimatedTotalPoints = (totalServes * 0.8).round(); // Rough estimate
      
      return {
        'pointsWon': estimatedPointsWon,
        'totalPoints': estimatedTotalPoints,
        'pointsWonServing': estimatedPointsWon,
        'totalPointsServing': estimatedTotalPoints,
        'pointsWonReceiving': 0,
        'totalPointsReceiving': 0,
        'breakpointsConverted': 2, // Placeholder
        'totalBreakpoints': 5, // Placeholder
      };
    }
    
    // Calculate from actual momentum data
    final pointsWon = _pointHistory.where((point) => point.isPointWon).length;
    final totalPoints = _pointHistory.length;
    
    // For now, assume all points are serving points (would need more tracking for receiving)
    return {
      'pointsWon': pointsWon,
      'totalPoints': totalPoints,
      'pointsWonServing': pointsWon,
      'totalPointsServing': totalPoints,
      'pointsWonReceiving': 0,
      'totalPointsReceiving': 0,
      'breakpointsConverted': (pointsWon * 0.2).round(), // Rough estimate
      'totalBreakpoints': (totalPoints * 0.3).round(), // Rough estimate
    };
  }

  void _endMatch() {
    if (_currentMatch == null) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'End Match',
          style: TextStyle(color: Colors.white, fontFamily: 'Manrope'),
        ),
        content: const Text(
          'Are you sure you want to end this match? You\'ll be taken to the match results.',
          style: TextStyle(color: Color(0xFF9C9C9C), fontFamily: 'Roboto'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9C9C9C)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              
              // Complete the match
              _completeMatch();
              
              // Navigate to Overview Stats Screen with the completed match
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => OverviewStatsScreen(match: _currentMatch!),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text(
              'End & View Results',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class MomentumPoint {
  final double x;
  final double y;
  final bool isPointWon;
  final bool isBreakpoint;

  MomentumPoint({
    required this.x,
    required this.y,
    required this.isPointWon,
    this.isBreakpoint = false,
  });
}
