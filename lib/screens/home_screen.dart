import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/match_card.dart';
import '../models/match_model.dart';
import 'match_setup_screen.dart';
import 'overview_stats_screen.dart';
import 'match_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            return Text(
              appProvider.greeting,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            );
          },
        ),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Stack(
            children: [
              // Main content with ScrollView
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding for button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Last Match Section
                    _buildLastMatchSection(context, appProvider),
                    const SizedBox(height: 32),
                    
                    // Match History Section
                    _buildMatchHistorySection(context, appProvider),
                    const SizedBox(height: 20), // Extra space at bottom
                  ],
                ),
              ),
              
              // Fixed Start New Match button at bottom
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _buildStartNewMatchButton(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLastMatchSection(BuildContext context, AppProvider appProvider) {
    final allMatches = appProvider.matches;
    
    if (allMatches.isEmpty) {
      return EmptyMatchCard(
        title: 'No Matches Yet',
        message: 'Start playing matches to see your latest game here',
        icon: Icons.sports_tennis,
        onTap: () {
          // Navigate to match setup screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MatchSetupScreen(),
            ),
          );
        },
      );
    }
    
    final lastMatch = allMatches.reduce((a, b) => 
        a.date.isAfter(b.date) ? a : b);

    return MatchCard(
      match: lastMatch,
      isLastMatch: true,
      onTap: () {
        // Navigate to overview stats screen for ended matches
        if (lastMatch.isCompleted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OverviewStatsScreen(match: lastMatch),
            ),
          );
        } else {
          // For ongoing matches, show message to user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Match is in progress. Go to Tracking tab to continue.'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      },
    );
  }

  Widget _buildMatchHistorySection(BuildContext context, AppProvider appProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Matches',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MatchHistoryScreen(),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: Color(0xFFFFD54F),
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMatchHistoryList(context, appProvider),
      ],
    );
  }

  Widget _buildMatchHistoryList(BuildContext context, AppProvider appProvider) {
    final allMatches = appProvider.matches;
    
    // Get recent matches excluding the most recent one (which is shown in Last Match section)
    List<Match> recentMatches = [];
    if (allMatches.length > 1) {
      final sortedMatches = List<Match>.from(allMatches)
        ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
      recentMatches = sortedMatches.skip(1).take(3).toList(); // Skip the first (most recent) and take next 3
    }
    
    if (recentMatches.isEmpty) {
      return SizedBox(
        height: 240, // Increased height to match other cards
        child: Center(
          child: SizedBox(
            width: 280,
            child: EmptyHistoryCard(
              onTap: () {
                // Navigate to match setup screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MatchSetupScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    final matchesToShow = recentMatches;

    return SizedBox(
      height: 240, // Increased height to accommodate content
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: matchesToShow.length,
        itemBuilder: (context, index) {
          final match = matchesToShow[index];
          return MatchCard(
            match: match,
            isLastMatch: false,
            onTap: () {
              if (match.isCompleted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OverviewStatsScreen(match: match),
                  ),
                );
              } else {
                // For in-progress matches, show message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Match is in progress. Go to Tracking tab to continue.'),
                    backgroundColor: Color(0xFF4CAF50),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }


  Widget _buildStartNewMatchButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to match setup screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MatchSetupScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: const Text(
            'Start New Match',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

}