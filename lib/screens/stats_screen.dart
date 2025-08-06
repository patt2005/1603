import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/match_model.dart';

class StatsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  
  const StatsScreen({super.key, this.onBackToHome});

  @override
  State<StatsScreen> createState() => StatsScreenState();
}

class StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  // Method to trigger back navigation from external sources
  void triggerBackNavigation() {
    if (widget.onBackToHome != null) {
      widget.onBackToHome!();
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text(
          'Player Stats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF3C3C3C),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final playerName = appProvider.matches.isNotEmpty 
              ? appProvider.matches.first.playerName 
              : 'Player';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player name
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      playerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Time filter tabs
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFFFFD54F),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFFFFD54F),
                    unselectedLabelColor: const Color(0xFF9C9C9C),
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'All Time'),
                      Tab(text: 'Last 30d'),
                      Tab(text: 'This Season'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Statistics cards
                _buildStatsCards(appProvider),
                const SizedBox(height: 32),
                
                // Charts section
                const Text(
                  'Charts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Win Rate chart
                _buildWinRateChart(appProvider),
                const SizedBox(height: 24),
                
                // Serve vs Return efficiency
                _buildServeEfficiencyChart(appProvider),
                const SizedBox(height: 32),
                
                // Heatmap section
                _buildHeatmapSection(appProvider),
                const SizedBox(height: 24),
                
                // Back button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.onBackToHome != null) {
                        widget.onBackToHome!();
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'Back',
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(AppProvider appProvider) {
    final matches = _getFilteredMatches(appProvider.matches);
    final stats = _calculateStats(matches);
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          '${stats['winPercentage']}%',
          '${stats['wins']}-${stats['losses']}',
          'Win/Loss Record',
          color: const Color(0xFF4CAF50),
        ),
        _buildStatCard(
          '${stats['breakPointsPercentage']}%',
          '${stats['breakPointsSaved']}-${stats['totalBreakPoints']}',
          'Break Points Saved',
          color: const Color(0xFF4CAF50),
        ),
        _buildStatCard(
          '${stats['firstServePercentage']}%',
          '',
          'First Serve In',
          color: const Color(0xFFFFD54F),
        ),
        _buildStatCard(
          '${stats['aces']} / ${stats['doubleFaults']}',
          '',
          'Aces / Double Faults',
          color: const Color(0xFFFFD54F),
        ),
        _buildStatCard(
          '${stats['rallyLength']} strokes',
          '',
          'Rally Length Avg',
          color: const Color(0xFF9C9C9C),
        ),
        _buildStatCard(
          'Backhand',
          'unforced',
          'Most common error',
          color: const Color(0xFF9C9C9C),
        ),
      ],
    );
  }

  Widget _buildStatCard(String mainValue, String subValue, String label, {required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C4C4C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mainValue,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subValue.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subValue,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9C9C9C),
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinRateChart(AppProvider appProvider) {
    final matches = _getFilteredMatches(appProvider.matches);
    final winRateData = _calculateWinRateProgression(matches);
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C4C4C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Win Rate',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: winRateData.isEmpty ? _buildEmptyChart() : LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  verticalInterval: 1,
                  horizontalInterval: 20,
                  getDrawingVerticalLine: (value) {
                    return const FlLine(color: Color(0xFF4C4C4C), strokeWidth: 1);
                  },
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(color: Color(0xFF4C4C4C), strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        if (value.toInt() >= 0 && value.toInt() < winRateData.length) {
                          final date = winRateData[value.toInt()].date;
                          return Text(
                            months[date.month - 1],
                            style: const TextStyle(
                              color: Color(0xFF9C9C9C),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFF9C9C9C),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xFF4C4C4C)),
                ),
                minX: 0,
                maxX: (winRateData.length - 1).toDouble().clamp(0, double.infinity),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: winRateData.asMap().entries.map((entry) => 
                        FlSpot(entry.key.toDouble(), entry.value.winRate)
                    ).toList(),
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
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
          ),
        ],
      ),
    );
  }
  
  List<WinRatePoint> _calculateWinRateProgression(List<Match> matches) {
    if (matches.isEmpty) return [];
    
    // Sort matches by date
    final sortedMatches = List<Match>.from(matches)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    List<WinRatePoint> winRatePoints = [];
    int totalWins = 0;
    int totalPlayed = 0;
    
    for (var match in sortedMatches) {
      if (match.isCompleted) {
        totalPlayed++;
        if (match.result == MatchResult.win) {
          totalWins++;
        }
        final winRate = totalPlayed > 0 ? (totalWins / totalPlayed * 100) : 0.0;
        winRatePoints.add(WinRatePoint(match.date, winRate));
      }
    }
    
    return winRatePoints;
  }
  
  Widget _buildEmptyChart() {
    return const Center(
      child: Text(
        'No match data available',
        style: TextStyle(
          color: Color(0xFF9C9C9C),
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildServeEfficiencyChart(AppProvider appProvider) {
    final matches = _getFilteredMatches(appProvider.matches);
    final serveStats = _calculateServeEfficiency(matches);
    
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C4C4C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Serve vs Return efficiency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(color: Color(0xFF4C4C4C), strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text(
                              'First Serve\nPoints Won',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9C9C9C),
                                fontSize: 10,
                                fontFamily: 'Roboto',
                              ),
                            );
                          case 1:
                            return const Text(
                              'Second Serve\nPoints Won',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9C9C9C),
                                fontSize: 10,
                                fontFamily: 'Roboto',
                              ),
                            );
                          case 2:
                            return const Text(
                              'Return Points\nWon',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9C9C9C),
                                fontSize: 10,
                                fontFamily: 'Roboto',
                              ),
                            );
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFF9C9C9C),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xFF4C4C4C)),
                ),
                minY: 0,
                maxY: 100,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: (serveStats['firstServePointsWon'] ?? 0).toDouble(),
                        color: const Color(0xFFFFD54F),
                        width: 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: (serveStats['secondServePointsWon'] ?? 0).toDouble(),
                        color: const Color(0xFF4CAF50),
                        width: 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: (serveStats['returnPointsWon'] ?? 0).toDouble(),
                        color: const Color(0xFFE53E3E),
                        width: 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, int> _calculateServeEfficiency(List<Match> matches) {
    if (matches.isEmpty) {
      return {
        'firstServePointsWon': 0,
        'secondServePointsWon': 0,
        'returnPointsWon': 0,
      };
    }
    
    // Calculate from actual match data
    final totalPointsServing = matches.fold<int>(0, (sum, m) => sum + m.totalPointsServing);
    final totalPointsWonServing = matches.fold<int>(0, (sum, m) => sum + m.pointsWonServing);
    final totalPointsReceiving = matches.fold<int>(0, (sum, m) => sum + m.totalPointsReceiving);
    final totalPointsWonReceiving = matches.fold<int>(0, (sum, m) => sum + m.pointsWonReceiving);
    
    // For now, estimate first/second serve splits
    final firstServePointsWon = totalPointsServing > 0 
        ? ((totalPointsWonServing * 0.7 / totalPointsServing) * 100).round() // Estimate 70% of serve points won are on first serve
        : 0;
    final secondServePointsWon = totalPointsServing > 0 
        ? ((totalPointsWonServing * 0.3 / totalPointsServing) * 100).round() // Estimate 30% on second serve
        : 0;
    final returnPointsWon = totalPointsReceiving > 0 
        ? ((totalPointsWonReceiving / totalPointsReceiving) * 100).round()
        : 0;
    
    return {
      'firstServePointsWon': firstServePointsWon.clamp(0, 100),
      'secondServePointsWon': secondServePointsWon.clamp(0, 100),
      'returnPointsWon': returnPointsWon.clamp(0, 100),
    };
  }

  Widget _buildHeatmapSection(AppProvider appProvider) {
    final matches = _getFilteredMatches(appProvider.matches);
    final heatmapData = _calculateHeatmapData(matches);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Heatmap',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildHeatmapCard('Ad Side', [
              ('Wide-Ad', heatmapData['wideAd'] ?? 0, const Color(0xFF4CAF50)),
              ('Body-Ad', heatmapData['bodyAd'] ?? 0, const Color(0xFF4CAF50)),
              ('T-Ad', heatmapData['tAd'] ?? 0, const Color(0xFF4CAF50)),
            ])),
            const SizedBox(width: 12),
            Expanded(child: _buildHeatmapCard('Deuce Side', [
              ('T-Deuce', heatmapData['tDeuce'] ?? 0, const Color(0xFF4CAF50)),
              ('Body-Deuce', heatmapData['bodyDeuce'] ?? 0, const Color(0xFF4CAF50)),
              ('Wide-Deuce', heatmapData['wideDeuce'] ?? 0, const Color(0xFF4CAF50)),
            ])),
          ],
        ),
      ],
    );
  }
  
  Map<String, int> _calculateHeatmapData(List<Match> matches) {
    // For now, distribute serves based on total serves
    final totalServes = matches.fold<int>(0, (sum, m) => sum + m.totalServes);
    
    // Rough distribution estimation (would need actual tracking)
    return {
      'wideAd': (totalServes * 0.18).round(),
      'bodyAd': (totalServes * 0.12).round(),
      'tAd': (totalServes * 0.06).round(),
      'tDeuce': (totalServes * 0.04).round(),
      'bodyDeuce': (totalServes * 0.08).round(),
      'wideDeuce': (totalServes * 0.14).round(),
    };
  }

  Widget _buildHeatmapCard(String title, List<(String, int, Color)> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C4C4C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...data.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  style: const TextStyle(
                    color: Color(0xFF9C9C9C),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.$2} serves',
                  style: TextStyle(
                    color: item.$3,
                    fontSize: 16,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<Match> _getFilteredMatches(List<Match> matches) {
    final now = DateTime.now();
    switch (_selectedTab) {
      case 1: // Last 30d
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        return matches.where((match) => match.date.isAfter(thirtyDaysAgo)).toList();
      case 2: // This Season (assuming season starts in January)
        final seasonStart = DateTime(now.year, 1, 1);
        return matches.where((match) => match.date.isAfter(seasonStart)).toList();
      default: // All Time
        return matches;
    }
  }

  Map<String, dynamic> _calculateStats(List<Match> matches) {
    // Always calculate from real data, even if empty
    final completedMatches = matches.where((m) => m.isCompleted).toList();
    final wins = completedMatches.where((m) => m.result == MatchResult.win).length;
    final losses = completedMatches.where((m) => m.result == MatchResult.loss).length;
    final totalMatches = completedMatches.length;
    
    // Aggregate statistics from all matches
    final totalServes = matches.fold<int>(0, (sum, m) => sum + m.totalServes);
    final totalFirstServesIn = matches.fold<int>(0, (sum, m) => sum + m.firstServesIn);
    final totalAces = matches.fold<int>(0, (sum, m) => sum + m.aces);
    final totalDoubleFaults = matches.fold<int>(0, (sum, m) => sum + m.doubleFaults);
    
    // Calculate break points from matches
    final totalBreakpointsSaved = matches.fold<int>(0, (sum, m) => sum + m.breakpointsConverted);
    final totalBreakpointsTotal = matches.fold<int>(0, (sum, m) => sum + m.totalBreakpoints);
    
    // Calculate points statistics
    final totalPointsPlayed = matches.fold<int>(0, (sum, m) => sum + m.totalPoints);
    
    // Calculate rally length (estimate based on points and serves)
    final rallyLength = totalPointsPlayed > 0 
        ? ((totalPointsPlayed * 1.2) / totalPointsPlayed).toStringAsFixed(1)
        : '0.0';

    return {
      'wins': wins,
      'losses': losses,
      'winPercentage': totalMatches > 0 ? ((wins / totalMatches) * 100).round() : 0,
      'breakPointsSaved': totalBreakpointsSaved,
      'totalBreakPoints': totalBreakpointsTotal,
      'breakPointsPercentage': totalBreakpointsTotal > 0 
          ? ((totalBreakpointsSaved / totalBreakpointsTotal) * 100).round() 
          : 0,
      'firstServePercentage': totalServes > 0 
          ? ((totalFirstServesIn / totalServes) * 100).round() 
          : 0,
      'aces': totalAces,
      'doubleFaults': totalDoubleFaults,
      'rallyLength': rallyLength,
    };
  }
}

class WinRatePoint {
  final DateTime date;
  final double winRate;
  
  WinRatePoint(this.date, this.winRate);
}