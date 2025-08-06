import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/match_model.dart';
import 'overview_stats_screen.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text(
          'Match History',
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
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1C1C1C),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9C9C9C),
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF9C9C9C),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),

          // Filter tabs
          Container(
            color: const Color(0xFF1C1C1C),
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
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'All Time'),
                Tab(text: 'Last 7 days'),
                Tab(text: 'Last 30 days'),
              ],
            ),
          ),

          // Match list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMatchList(MatchFilter.allTime),
                _buildMatchList(MatchFilter.last7Days),
                _buildMatchList(MatchFilter.last30Days),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(MatchFilter filter) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        List<Match> matches = _getFilteredMatches(appProvider.matches, filter);

        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: const Color(0xFF6C6C6C)),
                const SizedBox(height: 20),
                Text(
                  'No matches found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyMessage(filter),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9C9C9C),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _buildMatchCard(match);
          },
        );
      },
    );
  }

  Widget _buildMatchCard(Match match) {
    Color resultColor;
    String resultText;

    if (match.isCompleted) {
      final isWinner = match.result == MatchResult.win;
      resultColor =
          isWinner ? const Color(0xFF4CAF50) : const Color(0xFFE53E3E);
      resultText = isWinner ? 'Winner' : 'Defeat';
    } else {
      resultColor = Colors.orange; // Yellow for pending
      resultText = 'In Progress';
    }

    return GestureDetector(
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
              content: Text(
                'Match is in progress. Go to Tracking tab to continue.',
              ),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4C4C4C)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Opponent name
                Text(
                  match.opponentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Date
                Text(
                  _formatDate(match.date),
                  style: const TextStyle(
                    color: Color(0xFF9C9C9C),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Score
            Text(
              'Score: ${_getMatchScore(match)}',
              style: const TextStyle(
                color: Color(0xFF9C9C9C),
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),

            // Result and View button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Result badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: resultColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    resultText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // View button
                TextButton(
                  onPressed: () {
                    if (match.isCompleted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => OverviewStatsScreen(match: match),
                        ),
                      );
                    } else {
                      // For in-progress matches, show message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Match is in progress. Go to Tracking tab to continue.',
                          ),
                          backgroundColor: Color(0xFF4CAF50),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          color: const Color(0xFFFFD54F),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFFFD54F),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Match> _getFilteredMatches(List<Match> matches, MatchFilter filter) {
    List<Match> filteredMatches = List.from(matches);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredMatches =
          filteredMatches.where((match) {
            return match.opponentName.toLowerCase().contains(_searchQuery) ||
                match.playerName.toLowerCase().contains(_searchQuery);
          }).toList();
    }

    // Apply date filter
    final now = DateTime.now();
    switch (filter) {
      case MatchFilter.last7Days:
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        filteredMatches =
            filteredMatches
                .where((match) => match.date.isAfter(sevenDaysAgo))
                .toList();
        break;
      case MatchFilter.last30Days:
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        filteredMatches =
            filteredMatches
                .where((match) => match.date.isAfter(thirtyDaysAgo))
                .toList();
        break;
      case MatchFilter.allTime:
        // No additional filtering
        break;
    }

    // Sort by date (most recent first)
    filteredMatches.sort((a, b) => b.date.compareTo(a.date));

    return filteredMatches;
  }

  String _getEmptyMessage(MatchFilter filter) {
    switch (filter) {
      case MatchFilter.allTime:
        return 'Start playing matches to see your history here';
      case MatchFilter.last7Days:
        return 'No matches played in the last 7 days';
      case MatchFilter.last30Days:
        return 'No matches played in the last 30 days';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getMatchScore(Match match) {
    if (match.sets.isEmpty) {
      return 'No sets recorded';
    }
    return match.sets
        .map((set) => '${set.playerGames}-${set.opponentGames}')
        .join(' / ');
  }
}

enum MatchFilter { allTime, last7Days, last30Days }
