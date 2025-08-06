import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../models/match_model.dart';
import 'statistics_screen.dart';

class OverviewStatsScreen extends StatelessWidget {
  final Match match;

  const OverviewStatsScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Overview & Stats Screen',
              style: TextStyle(
                color: Color(0xFF9C9C9C),
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(color: Color(0xFF3C3C3C)),
              child: const Text(
                'Overview & Stats',
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
                // Match header card
                _buildMatchHeader(),
                const SizedBox(height: 24),

                // Statistics sections
                _buildStatisticsSection(),
                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(context),
              ],
            );
          },
        ),
      ),
      // Bottom buttons
      bottomSheet: Container(
        color: const Color(0xFF1C1C1C),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _shareMatchSummary();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Color(0xFF5C5C5C)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.share, color: Colors.black),
                  label: const Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4C4C4C)),
      ),
      child: Column(
        children: [
          // Match type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              match.type.displayName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Players vs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  match.playerName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: Color(0xFFE53E3E),
                    fontSize: 24,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  match.opponentName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date and time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatMatchDate(match.date),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      children: [
        _buildStatRow(
          'Points Won',
          match.pointsWonPercentage,
          '${match.pointsWon} of ${match.totalPoints}',
          const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 20),
        _buildStatRow(
          'Points Won Serving',
          match.pointsWonServingPercentage,
          'Of all the points submitted',
          const Color(0xFFFFD54F),
        ),
        const SizedBox(height: 20),
        _buildStatRow(
          'Points Won Receiving',
          match.pointsWonReceivingPercentage,
          'From the glasses at the reception',
          const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 20),
        _buildStatRow(
          'Breakpoints Converted',
          match.breakpointsConvertedPercentage,
          '${match.breakpointsConverted} of ${match.totalBreakpoints}',
          const Color(0xFFFFD54F),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String title,
    double percentage,
    String subtitle,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF9C9C9C),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF3C3C3C),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (percentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF3C3C3C),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF9C9C9C),
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const StatisticsScreen()),
          );
        },
        icon: const Icon(Icons.analytics, color: Colors.white),
        label: const Text(
          'Set Breakdown',
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

  String _formatMatchDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day.$month.$year - $hour:$minute';
  }

  void _shareMatchSummary() {
    final shareText = _formatMatchForSharing();
    
    Share.share(
      shareText,
      subject: '🎾 Tennis Match Results - ${match.playerName} vs ${match.opponentName}',
    );
  }

  String _formatMatchForSharing() {
    final result = match.result == MatchResult.win ? '🏆 WON' : 
                   match.result == MatchResult.loss ? '😔 LOST' : 
                   '⚡ IN PROGRESS';
    
    final duration = match.duration != null 
        ? '${match.duration!.inHours}h ${match.duration!.inMinutes % 60}m'
        : 'Duration not available';

    return '''
🎾 TENNIS MATCH RESULTS 🎾

🏆 MATCH RESULT: $result
📅 Date: ${_formatMatchDate(match.date)}
⏱️ Duration: $duration
🏟️ Match Type: ${match.type.displayName}
📊 Format: ${match.format.displayName}

👤 PLAYERS:
• ${match.playerName} vs ${match.opponentName}

📈 PERFORMANCE STATS:
• Points Won: ${match.pointsWon}/${match.totalPoints} (${match.pointsWonPercentage.toStringAsFixed(1)}%)
• Points Won Serving: ${match.pointsWonServing}/${match.totalPointsServing} (${match.pointsWonServingPercentage.toStringAsFixed(1)}%)
• Points Won Receiving: ${match.pointsWonReceiving}/${match.totalPointsReceiving} (${match.pointsWonReceivingPercentage.toStringAsFixed(1)}%)
• Breakpoints Converted: ${match.breakpointsConverted}/${match.totalBreakpoints} (${match.breakpointsConvertedPercentage.toStringAsFixed(1)}%)

🎯 SERVE STATISTICS:
• Total Service Games: ${match.totalServes}
• Aces: ${match.aces}
• Double Faults: ${match.doubleFaults}
• First Serve Success: ${match.firstServesIn}/${match.totalServes} (${match.firstServePercentage.toStringAsFixed(1)}%)
• Successful Serves: ${match.successfulServes}

${match.sets.isNotEmpty ? '''
📋 SET BREAKDOWN:
${match.sets.asMap().entries.map((entry) {
  final index = entry.key + 1;
  final set = entry.value;
  final winner = set.playerWon ? match.playerName : match.opponentName;
  return 'Set $index: ${set.scoreString} (Won by $winner)';
}).join('\n')}
''' : ''}
${match.notes != null && match.notes!.isNotEmpty ? '''
📝 NOTES:
${match.notes}
''' : ''}
---
🚀 Shared from Tennis Insights Tracker
Track your tennis performance like a pro! 🎾
    ''';
  }
}
