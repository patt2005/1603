import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/tennis_court.dart';
import '../widgets/serve_tracking_buttons.dart';
import '../widgets/shot_tracking_dialog.dart';
import '../models/match_model.dart' as match_model;
import '../models/shot_model.dart';
import 'statistics_screen.dart';
import 'match_setup_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => TrackingScreenState();
}

// Make the state class public so statistics screen can access current set data
class TrackingScreenState extends State<TrackingScreen> {
  static TrackingScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<TrackingScreenState>();
  }

  ServeType _selectedServeType = ServeType.first;
  ServeResult? _selectedResult;
  String? _selectedSection;
  final Map<String, CourtSectionType> _sectionStates = {};
  final List<ServeData> _serveHistory = [];
  bool _actionTaken = false;
  bool _pointCompleted = false;
  int _servesInPoint = 0; // Track number of serves in current point
  int _currentServiceGame = 1; // Track current service game number
  int _pointsInCurrentGame = 0; // Track points in current service game
  int _currentSet = 1; // Track current set number
  int _playerGamesInCurrentSet = 0; // Track player games in current set
  int _opponentGamesInCurrentSet = 0; // Track opponent games in current set

  // Getter to expose current set number for statistics screen
  int get currentSet => _currentSet;

  // Track current set serve statistics
  int currentSetAces = 0;
  int currentSetFaults = 0;
  int currentSetFootFaults = 0;
  int currentSetSuccessfulServes = 0;
  int currentSetTotalServes = 0;

  // Track current set winners
  int currentSetApproachWinners = 0;
  int currentSetPassingWinners = 0;
  int currentSetGroundstrokeWinners = 0;
  int currentSetDropshotWinners = 0;
  int currentSetVolleyWinners = 0;
  int currentSetOverheadWinners = 0;
  int currentSetLobWinners = 0;

  // Track current set forced errors
  int currentSetApproachForced = 0;
  int currentSetPassingForced = 0;
  int currentSetGroundstrokeForced = 0;
  int currentSetDropshotForced = 0;
  int currentSetVolleyForced = 0;
  int currentSetOverheadForced = 0;
  int currentSetLobForced = 0;

  // Track current set unforced errors
  int currentSetApproachUnforced = 0;
  int currentSetPassingUnforced = 0;
  int currentSetGroundstrokeUnforced = 0;
  int currentSetDropshotUnforced = 0;
  int currentSetVolleyUnforced = 0;
  int currentSetOverheadUnforced = 0;
  int currentSetLobUnforced = 0;
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
                'Serve Tracking',
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
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Check if there are any matches
          if (appProvider.matches.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                // Statistics cards at the top
                _buildStatsCards(appProvider),

                // Point status and instructional text
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // Set and game status
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3C3C3C),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Set $_currentSet • Games: $_playerGamesInCurrentSet-$_opponentGamesInCurrentSet',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontSize: 14,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Service game status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Service Game $_currentServiceGame • Point ${_pointsInCurrentGame + 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF9C9C9C),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Serve status
                      if (_servesInPoint > 0 && !_pointCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _selectedServeType == ServeType.first
                                    ? const Color(
                                      0xFF4CAF50,
                                    ).withValues(alpha: 0.2)
                                    : const Color(
                                      0xFFFF9800,
                                    ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedServeType == ServeType.first
                                ? 'First Serve'
                                : 'Second Serve (after fault)',
                            style: TextStyle(
                              color:
                                  _selectedServeType == ServeType.first
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF9800),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (_pointCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2196F3,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Point Complete - Press Next',
                            style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Instructional text
                      const Text(
                        'Tap to indicate where\nPlayer\'s serve landed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tennis court
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: TennisCourt(
                    onSectionTap: _handleCourtSectionTap,
                    sectionStates: _sectionStates,
                    selectedSection: _selectedSection,
                  ),
                ),

                // Serve tracking buttons
                Column(
                  children: [
                    ServeTrackingButtons(
                      selectedServeType: _selectedServeType,
                      selectedResult: _selectedResult,
                      onServeTypeChanged: (type) {
                        setState(() {
                          _selectedServeType = type;
                        });
                      },
                      onResultSelected: (result) {
                        if (!_actionTaken) {
                          setState(() {
                            _selectedResult = result;
                          });
                        }
                      },
                      onUndo: _handleUndo,
                      onNext: _handleNext,
                      actionTaken: _actionTaken,
                      pointCompleted: _pointCompleted,
                    ),
                    if (!_pointCompleted) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showShotTrackingDialog,
                            icon: const Icon(
                              Icons.sports_tennis,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Record Shot',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Set and game management buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      const Divider(color: Color(0xFF4C4C4C)),
                      const SizedBox(height: 8),
                      const Text(
                        'Game & Set Management',
                        style: TextStyle(
                          color: Color(0xFF9C9C9C),
                          fontSize: 14,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_shouldShowCompleteSetButton())
                        ElevatedButton(
                          onPressed: () {
                            _handleSetComplete();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Complete Set'),
                        ),
                    ],
                  ),
                ),

                // Statistics button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const StatisticsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: const Text(
                        'Rally Statistics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF6B46C1,
                        ), // Purple color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
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
    // Get the most recent match (current match)
    final matches = appProvider.matches;
    if (matches.isEmpty) {
      // Show default stats when no matches
      return StatsCardsRow(
        firstServePercentage: 0.0,
        aces: 0,
        faultsPercentage: 0.0,
      );
    }

    // Get the most recent match
    final currentMatch = matches.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );

    // Calculate double fault percentage properly
    double doubleFaultPercentage = 0.0;
    if (currentMatch.totalServes > 0) {
      doubleFaultPercentage =
          (currentMatch.doubleFaults / currentMatch.totalServes) * 100;
    }

    return StatsCardsRow(
      firstServePercentage: currentMatch.firstServePercentage,
      aces: currentMatch.aces,
      faultsPercentage: doubleFaultPercentage,
    );
  }

  void _handleCourtSectionTap(String section) {
    setState(() {
      _selectedSection = section;
    });

    // If we have both a section selected and a result, record the serve
    if (_selectedResult != null) {
      _recordServe(section, _selectedResult!);
    }
  }

  void _recordServe(String section, ServeResult result) {
    final serveData = ServeData(
      sectionId: section,
      serveType: _selectedServeType,
      result: result,
      timestamp: DateTime.now(),
    );

    setState(() {
      _serveHistory.add(serveData);
      _sectionStates[section] = _convertResultToSectionType(result);
      _selectedSection = null;
      _selectedResult = null;
      _actionTaken = true;
      _servesInPoint++;

      // Check if point is complete
      bool isPointComplete = false;
      if (result == ServeResult.ace) {
        // Ace ends the point immediately
        isPointComplete = true;
      } else if (result == ServeResult.successful) {
        // Successful serve continues the rally, point completes when rally ends
        isPointComplete =
            true; // For now, we assume point ends after successful serve
      } else if (_selectedServeType == ServeType.second &&
          (result == ServeResult.fault || result == ServeResult.footFault)) {
        // Double fault (fault on second serve)
        isPointComplete = true;
      } else if (result == ServeResult.fault ||
          result == ServeResult.footFault) {
        // First serve fault - move to second serve
        _selectedServeType = ServeType.second;
        isPointComplete = false;
      }

      if (isPointComplete) {
        _pointCompleted = true;
        _pointsInCurrentGame++;

        // Determine if player won the point
        bool playerWonPoint =
            (result == ServeResult.ace || result == ServeResult.successful);
        _recordPointOutcome(playerWonPoint);

        // Check if service game is complete (typically 4 points, but can be more in deuce)
        // For simplicity, we'll track each point but could extend this for full game logic
      }
    });

    // Update match statistics only when point is complete
    if (_pointCompleted) {
      _updateMatchStatistics(result);
    }

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedServeType.name.toUpperCase()} ${result.name.toUpperCase()} recorded in $section',
          style: const TextStyle(fontFamily: 'Roboto'),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _updateMatchStatistics(ServeResult finalPointResult) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final matches = appProvider.matches;

    if (matches.isEmpty) return;

    // Get the current match (most recent)
    final currentMatch = matches.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );

    // Calculate updated statistics based on the completed point
    int newAces = currentMatch.aces;
    int newDoubleFaults = currentMatch.doubleFaults;
    int newSuccessfulServes = currentMatch.successfulServes;
    int newTotalServes =
        currentMatch.totalServes +
        1; // Count this as one service attempt (point)
    int newFirstServesIn = currentMatch.firstServesIn;

    // Count first serves made in this point
    int firstServesInThisPoint = 0;

    // Check serves in current point from history
    for (
      int i = _serveHistory.length - _servesInPoint;
      i < _serveHistory.length;
      i++
    ) {
      final serve = _serveHistory[i];
      if (serve.serveType == ServeType.first) {
        if (serve.result == ServeResult.successful ||
            serve.result == ServeResult.ace) {
          firstServesInThisPoint = 1;
          break; // First serve was in
        }
      }
    }

    // Update statistics based on point outcome
    switch (finalPointResult) {
      case ServeResult.ace:
        newAces++;
        newSuccessfulServes++;
        newFirstServesIn += firstServesInThisPoint;
        // Update current set statistics
        currentSetAces++;
        currentSetSuccessfulServes++;
        currentSetTotalServes++;
        break;
      case ServeResult.successful:
        newSuccessfulServes++;
        newFirstServesIn += firstServesInThisPoint;
        // Update current set statistics
        currentSetSuccessfulServes++;
        currentSetTotalServes++;
        break;
      case ServeResult.fault:
      case ServeResult.footFault:
        // This was a double fault (fault on second serve)
        if (_selectedServeType == ServeType.second) {
          newDoubleFaults++;
        }
        // Update current set statistics
        if (finalPointResult == ServeResult.fault) {
          currentSetFaults++;
        } else {
          currentSetFootFaults++;
        }
        currentSetTotalServes++;
        break;
    }

    // Create updated match with new statistics
    final updatedMatch = currentMatch.copyWith(
      aces: newAces,
      doubleFaults: newDoubleFaults,
      successfulServes: newSuccessfulServes,
      totalServes: newTotalServes,
      firstServesIn: newFirstServesIn,
    );

    // Update the match in the provider
    appProvider.updateMatch(currentMatch.id, updatedMatch);
  }

  void _revertCurrentSetStatistics(ServeResult result) {
    setState(() {
      switch (result) {
        case ServeResult.ace:
          currentSetAces =
              (currentSetAces - 1).clamp(0, double.infinity).toInt();
          currentSetSuccessfulServes =
              (currentSetSuccessfulServes - 1)
                  .clamp(0, double.infinity)
                  .toInt();
          currentSetTotalServes =
              (currentSetTotalServes - 1).clamp(0, double.infinity).toInt();
          break;
        case ServeResult.successful:
          currentSetSuccessfulServes =
              (currentSetSuccessfulServes - 1)
                  .clamp(0, double.infinity)
                  .toInt();
          currentSetTotalServes =
              (currentSetTotalServes - 1).clamp(0, double.infinity).toInt();
          break;
        case ServeResult.fault:
          currentSetFaults =
              (currentSetFaults - 1).clamp(0, double.infinity).toInt();
          currentSetTotalServes =
              (currentSetTotalServes - 1).clamp(0, double.infinity).toInt();
          break;
        case ServeResult.footFault:
          currentSetFootFaults =
              (currentSetFootFaults - 1).clamp(0, double.infinity).toInt();
          currentSetTotalServes =
              (currentSetTotalServes - 1).clamp(0, double.infinity).toInt();
          break;
      }
    });
  }

  void _recordPointOutcome(bool playerWonPoint) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final matches = appProvider.matches;

    if (matches.isEmpty) return;

    // Get the current match (most recent)
    final currentMatch = matches.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );

    // Update point statistics
    final newPointsWon =
        playerWonPoint ? currentMatch.pointsWon + 1 : currentMatch.pointsWon;
    final newTotalPoints = currentMatch.totalPoints + 1;
    final newPointsWonServing =
        playerWonPoint
            ? currentMatch.pointsWonServing + 1
            : currentMatch.pointsWonServing;
    final newTotalPointsServing = currentMatch.totalPointsServing + 1;

    // Create updated match with new point statistics
    final updatedMatch = currentMatch.copyWith(
      pointsWon: newPointsWon,
      totalPoints: newTotalPoints,
      pointsWonServing: newPointsWonServing,
      totalPointsServing: newTotalPointsServing,
    );

    // Update the match in the provider
    appProvider.updateMatch(currentMatch.id, updatedMatch);
  }

  CourtSectionType _convertResultToSectionType(ServeResult result) {
    switch (result) {
      case ServeResult.fault:
        return CourtSectionType.fault;
      case ServeResult.ace:
        return CourtSectionType.ace;
      case ServeResult.footFault:
        return CourtSectionType.footFault;
      case ServeResult.successful:
        return CourtSectionType.successful;
    }
  }

  void _revertMatchStatistics(ServeResult result, ServeType serveType) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final matches = appProvider.matches;

    if (matches.isEmpty) return;

    // Get the current match (most recent)
    final currentMatch = matches.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );

    // Calculate reverted statistics
    int newAces = currentMatch.aces;
    int newFaults = currentMatch.faults;
    int newFootFaults = currentMatch.footFaults;
    int newSuccessfulServes = currentMatch.successfulServes;
    int newTotalServes =
        (currentMatch.totalServes - 1).clamp(0, double.infinity).toInt();
    int newFirstServesIn = currentMatch.firstServesIn;

    switch (result) {
      case ServeResult.ace:
        newAces = (newAces - 1).clamp(0, double.infinity).toInt();
        newSuccessfulServes =
            (newSuccessfulServes - 1).clamp(0, double.infinity).toInt();
        if (serveType == ServeType.first) {
          newFirstServesIn =
              (newFirstServesIn - 1).clamp(0, double.infinity).toInt();
        }
        break;
      case ServeResult.successful:
        newSuccessfulServes =
            (newSuccessfulServes - 1).clamp(0, double.infinity).toInt();
        if (serveType == ServeType.first) {
          newFirstServesIn =
              (newFirstServesIn - 1).clamp(0, double.infinity).toInt();
        }
        break;
      case ServeResult.fault:
        newFaults = (newFaults - 1).clamp(0, double.infinity).toInt();
        break;
      case ServeResult.footFault:
        newFootFaults = (newFootFaults - 1).clamp(0, double.infinity).toInt();
        break;
    }

    // Create updated match with reverted statistics
    final updatedMatch = currentMatch.copyWith(
      aces: newAces,
      faults: newFaults,
      footFaults: newFootFaults,
      successfulServes: newSuccessfulServes,
      totalServes: newTotalServes,
      firstServesIn: newFirstServesIn,
    );

    // Update the match in the provider
    appProvider.updateMatch(currentMatch.id, updatedMatch);
  }

  void _revertPointOutcome(bool playerHadWonPoint) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final matches = appProvider.matches;

    if (matches.isEmpty) return;

    // Get the current match (most recent)
    final currentMatch = matches.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );

    // Revert point statistics
    final newPointsWon =
        playerHadWonPoint
            ? (currentMatch.pointsWon - 1).clamp(0, double.infinity).toInt()
            : currentMatch.pointsWon;
    final newTotalPoints =
        (currentMatch.totalPoints - 1).clamp(0, double.infinity).toInt();
    final newPointsWonServing =
        playerHadWonPoint
            ? (currentMatch.pointsWonServing - 1)
                .clamp(0, double.infinity)
                .toInt()
            : currentMatch.pointsWonServing;
    final newTotalPointsServing =
        (currentMatch.totalPointsServing - 1).clamp(0, double.infinity).toInt();

    // Create updated match with reverted point statistics
    final updatedMatch = currentMatch.copyWith(
      pointsWon: newPointsWon,
      totalPoints: newTotalPoints,
      pointsWonServing: newPointsWonServing,
      totalPointsServing: newTotalPointsServing,
    );

    // Update the match in the provider
    appProvider.updateMatch(currentMatch.id, updatedMatch);
  }

  void _handleUndo() {
    if (_serveHistory.isNotEmpty) {
      final lastServe = _serveHistory.last;
      bool wasPointJustCompleted = _pointCompleted;

      setState(() {
        _serveHistory.removeLast();
        _sectionStates.remove(lastServe.sectionId);
        _actionTaken = false;
        _servesInPoint--;

        // If we're undoing a completed point, reset point completion state
        if (wasPointJustCompleted) {
          _pointCompleted = false;
          _pointsInCurrentGame--;
        }

        // Reset serve type logic
        if (_servesInPoint <= 0) {
          _selectedServeType = ServeType.first;
          _servesInPoint = 0;
        } else {
          // If we still have serves in the point, figure out what serve type we should be on
          bool foundFirstServe = false;
          for (
            int i = _serveHistory.length - _servesInPoint;
            i < _serveHistory.length;
            i++
          ) {
            if (_serveHistory[i].serveType == ServeType.first) {
              foundFirstServe = true;
              if (_serveHistory[i].result == ServeResult.fault ||
                  _serveHistory[i].result == ServeResult.footFault) {
                _selectedServeType = ServeType.second;
              } else {
                _selectedServeType = ServeType.first;
              }
              break;
            }
          }
          if (!foundFirstServe) {
            _selectedServeType = ServeType.first;
          }
        }
      });

      // Revert match statistics only if point was completed
      if (wasPointJustCompleted) {
        _revertMatchStatistics(lastServe.result, lastServe.serveType);
        _revertCurrentSetStatistics(lastServe.result);

        // Revert point statistics
        final playerWonPoint =
            lastServe.result == ServeResult.ace ||
            lastServe.result == ServeResult.successful;
        _revertPointOutcome(playerWonPoint);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Last serve undone'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _recordShot(ShotType type, ShotOutcome outcome) {
    // Update current set statistics based on shot type and outcome
    switch (outcome) {
      case ShotOutcome.winner:
        switch (type) {
          case ShotType.approachShot:
            currentSetApproachWinners++;
            break;
          case ShotType.passingShot:
            currentSetPassingWinners++;
            break;
          case ShotType.groundStroke:
            currentSetGroundstrokeWinners++;
            break;
          case ShotType.dropShot:
            currentSetDropshotWinners++;
            break;
          case ShotType.volley:
            currentSetVolleyWinners++;
            break;
          case ShotType.overhead:
            currentSetOverheadWinners++;
            break;
          case ShotType.lob:
            currentSetLobWinners++;
            break;
        }
        break;
      case ShotOutcome.forcedError:
        switch (type) {
          case ShotType.approachShot:
            currentSetApproachForced++;
            break;
          case ShotType.passingShot:
            currentSetPassingForced++;
            break;
          case ShotType.groundStroke:
            currentSetGroundstrokeForced++;
            break;
          case ShotType.dropShot:
            currentSetDropshotForced++;
            break;
          case ShotType.volley:
            currentSetVolleyForced++;
            break;
          case ShotType.overhead:
            currentSetOverheadForced++;
            break;
          case ShotType.lob:
            currentSetLobForced++;
            break;
        }
        break;
      case ShotOutcome.unforcedError:
        switch (type) {
          case ShotType.approachShot:
            currentSetApproachUnforced++;
            break;
          case ShotType.passingShot:
            currentSetPassingUnforced++;
            break;
          case ShotType.groundStroke:
            currentSetGroundstrokeUnforced++;
            break;
          case ShotType.dropShot:
            currentSetDropshotUnforced++;
            break;
          case ShotType.volley:
            currentSetVolleyUnforced++;
            break;
          case ShotType.overhead:
            currentSetOverheadUnforced++;
            break;
          case ShotType.lob:
            currentSetLobUnforced++;
            break;
        }
        break;
    }

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${type.displayName} ${outcome.displayName} recorded',
          style: const TextStyle(fontFamily: 'Roboto'),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showShotTrackingDialog() {
    showDialog(
      context: context,
      builder: (context) => ShotTrackingDialog(onShotRecorded: _recordShot),
    );
  }

  void _handleNext() {
    if (_pointCompleted) {
      // Reset for next point
      setState(() {
        _selectedSection = null;
        _selectedResult = null;
        _actionTaken = false;
        _pointCompleted = false;
        _servesInPoint = 0;
        _selectedServeType =
            ServeType.first; // Always start new point with first serve
        _sectionStates.clear(); // Clear court visual feedback
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Point completed! Ready for next point.'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Reset for next serve in same point
      setState(() {
        _selectedSection = null;
        _selectedResult = null;
        _actionTaken = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ready for next serve'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleSetComplete() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final matches = appProvider.matches;

    if (matches.isEmpty) return;

    // Get the current match
    final currentMatch = matches.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );

    // Check if we've reached the maximum number of sets for this match
    if (currentMatch.sets.length >= currentMatch.totalSets) {
      // Determine match result based on sets won
      final playerSetsWon =
          currentMatch.sets.where((set) => set.playerWon).length;
      final opponentSetsWon =
          currentMatch.sets.where((set) => !set.playerWon).length;

      final result =
          playerSetsWon > opponentSetsWon
              ? match_model.MatchResult.win
              : match_model.MatchResult.loss;

      // Update match as completed
      final completedMatch = currentMatch.copyWith(
        result: result,
        completedAt: DateTime.now(),
        isFinished: true,
      );

      appProvider.updateMatch(currentMatch.id, completedMatch);

      // Show match completion message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Match completed! Result: ${result == match_model.MatchResult.win ? "Win" : "Loss"}',
          ),
          backgroundColor:
              result == match_model.MatchResult.win
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53E3E),
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to home screen
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    // Create new set with accumulated statistics
    final newSet = match_model.Set(
      playerGames: _playerGamesInCurrentSet,
      opponentGames: _opponentGamesInCurrentSet,
      playerWon: _playerGamesInCurrentSet > _opponentGamesInCurrentSet,
      // Serve statistics
      aces: currentSetAces,
      faults: currentSetFaults,
      footFaults: currentSetFootFaults,
      successfulServes: currentSetSuccessfulServes,
      totalServes: currentSetTotalServes,
      // Winners
      approachShotWinners: currentSetApproachWinners,
      passingShotWinners: currentSetPassingWinners,
      groundStrokeWinners: currentSetGroundstrokeWinners,
      dropShotWinners: currentSetDropshotWinners,
      volleyWinners: currentSetVolleyWinners,
      overheadWinners: currentSetOverheadWinners,
      lobWinners: currentSetLobWinners,
      // Forced Errors
      approachShotForcedErrors: currentSetApproachForced,
      passingShotForcedErrors: currentSetPassingForced,
      groundStrokeForcedErrors: currentSetGroundstrokeForced,
      dropShotForcedErrors: currentSetDropshotForced,
      volleyForcedErrors: currentSetVolleyForced,
      overheadForcedErrors: currentSetOverheadForced,
      lobForcedErrors: currentSetLobForced,
      // Unforced Errors
      approachShotUnforcedErrors: currentSetApproachUnforced,
      passingShotUnforcedErrors: currentSetPassingUnforced,
      groundStrokeUnforcedErrors: currentSetGroundstrokeUnforced,
      dropShotUnforcedErrors: currentSetDropshotUnforced,
      volleyUnforcedErrors: currentSetVolleyUnforced,
      overheadUnforcedErrors: currentSetOverheadUnforced,
      lobUnforcedErrors: currentSetLobUnforced,
    );

    final updatedSets = List<match_model.Set>.from(currentMatch.sets)
      ..add(newSet);

    // After adding the new set, check if the match should end
    final finalPlayerSetsWon = updatedSets.where((set) => set.playerWon).length;
    final finalOpponentSetsWon =
        updatedSets.where((set) => !set.playerWon).length;

    // Calculate updated match statistics including shot data
    int newApproachWinners =
        currentMatch.approachShotWinners + currentSetApproachWinners;
    int newPassingWinners =
        currentMatch.passingShotWinners + currentSetPassingWinners;
    int newGroundstrokeWinners =
        currentMatch.groundStrokeWinners + currentSetGroundstrokeWinners;
    int newDropshotWinners =
        currentMatch.dropShotWinners + currentSetDropshotWinners;
    int newVolleyWinners = currentMatch.volleyWinners + currentSetVolleyWinners;
    int newOverheadWinners =
        currentMatch.overheadWinners + currentSetOverheadWinners;
    int newLobWinners = currentMatch.lobWinners + currentSetLobWinners;

    int newApproachForced =
        currentMatch.approachShotForcedErrors + currentSetApproachForced;
    int newPassingForced =
        currentMatch.passingShotForcedErrors + currentSetPassingForced;
    int newGroundstrokeForced =
        currentMatch.groundStrokeForcedErrors + currentSetGroundstrokeForced;
    int newDropshotForced =
        currentMatch.dropShotForcedErrors + currentSetDropshotForced;
    int newVolleyForced =
        currentMatch.volleyForcedErrors + currentSetVolleyForced;
    int newOverheadForced =
        currentMatch.overheadForcedErrors + currentSetOverheadForced;
    int newLobForced = currentMatch.lobForcedErrors + currentSetLobForced;

    int newApproachUnforced =
        currentMatch.approachShotUnforcedErrors + currentSetApproachUnforced;
    int newPassingUnforced =
        currentMatch.passingShotUnforcedErrors + currentSetPassingUnforced;
    int newGroundstrokeUnforced =
        currentMatch.groundStrokeUnforcedErrors +
        currentSetGroundstrokeUnforced;
    int newDropshotUnforced =
        currentMatch.dropShotUnforcedErrors + currentSetDropshotUnforced;
    int newVolleyUnforced =
        currentMatch.volleyUnforcedErrors + currentSetVolleyUnforced;
    int newOverheadUnforced =
        currentMatch.overheadUnforcedErrors + currentSetOverheadUnforced;
    int newLobUnforced = currentMatch.lobUnforcedErrors + currentSetLobUnforced;

    final updatedMatch = currentMatch.copyWith(
      sets: updatedSets,
      // Update match-level shot statistics
      approachShotWinners: newApproachWinners,
      passingShotWinners: newPassingWinners,
      groundStrokeWinners: newGroundstrokeWinners,
      dropShotWinners: newDropshotWinners,
      volleyWinners: newVolleyWinners,
      overheadWinners: newOverheadWinners,
      lobWinners: newLobWinners,

      approachShotForcedErrors: newApproachForced,
      passingShotForcedErrors: newPassingForced,
      groundStrokeForcedErrors: newGroundstrokeForced,
      dropShotForcedErrors: newDropshotForced,
      volleyForcedErrors: newVolleyForced,
      overheadForcedErrors: newOverheadForced,
      lobForcedErrors: newLobForced,

      approachShotUnforcedErrors: newApproachUnforced,
      passingShotUnforcedErrors: newPassingUnforced,
      groundStrokeUnforcedErrors: newGroundstrokeUnforced,
      dropShotUnforcedErrors: newDropshotUnforced,
      volleyUnforcedErrors: newVolleyUnforced,
      overheadUnforcedErrors: newOverheadUnforced,
      lobUnforcedErrors: newLobUnforced,
    );

    // Update the match in the provider
    appProvider.updateMatch(currentMatch.id, updatedMatch);

    // Check if we've now reached the maximum number of sets after adding this set
    if (updatedSets.length >= currentMatch.totalSets) {
      // Match is complete after playing all sets, determine result
      final matchResult =
          finalPlayerSetsWon > finalOpponentSetsWon
              ? match_model.MatchResult.win
              : match_model.MatchResult.loss;

      // Update match as completed
      final completedMatch = updatedMatch.copyWith(
        result: matchResult,
        completedAt: DateTime.now(),
        isFinished: true,
      );

      appProvider.updateMatch(currentMatch.id, completedMatch);

      // Show match completion message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Match completed! Final score: $finalPlayerSetsWon-$finalOpponentSetsWon. Result: ${matchResult == match_model.MatchResult.win ? "Win" : "Loss"}',
          ),
          backgroundColor:
              matchResult == match_model.MatchResult.win
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53E3E),
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to home screen
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _currentSet++;
      _playerGamesInCurrentSet = 0;
      _opponentGamesInCurrentSet = 0;
      _currentServiceGame = 1;
      _pointsInCurrentGame = 0;
      // Reset current set statistics
      // Serve statistics
      currentSetAces = 0;
      currentSetFaults = 0;
      currentSetFootFaults = 0;
      currentSetSuccessfulServes = 0;
      currentSetTotalServes = 0;
      // Winners
      currentSetApproachWinners = 0;
      currentSetPassingWinners = 0;
      currentSetGroundstrokeWinners = 0;
      currentSetDropshotWinners = 0;
      currentSetVolleyWinners = 0;
      currentSetOverheadWinners = 0;
      currentSetLobWinners = 0;
      // Forced Errors
      currentSetApproachForced = 0;
      currentSetPassingForced = 0;
      currentSetGroundstrokeForced = 0;
      currentSetDropshotForced = 0;
      currentSetVolleyForced = 0;
      currentSetOverheadForced = 0;
      currentSetLobForced = 0;
      // Unforced Errors
      currentSetApproachUnforced = 0;
      currentSetPassingUnforced = 0;
      currentSetGroundstrokeUnforced = 0;
      currentSetDropshotUnforced = 0;
      currentSetVolleyUnforced = 0;
      currentSetOverheadUnforced = 0;
      currentSetLobUnforced = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Set ${_currentSet - 1} completed! Starting Set $_currentSet',
        ),
        backgroundColor: const Color(0xFF6B46C1),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _shouldShowCompleteSetButton() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final matches = appProvider.matches;

    if (matches.isEmpty) return false;

    // Get the current match
    final currentMatch = matches.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );

    // Only hide button if we've already played all sets in the match format
    if (currentMatch.sets.length >= currentMatch.totalSets) {
      return false;
    }

    return true;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_tennis,
              color: const Color(0xFF6C6C6C),
              size: 120,
            ),
            const SizedBox(height: 32),
            const Text(
              'No Active Match',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You need to create a match first\\nbefore you can start tracking serves',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9C9C9C),
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MatchSetupScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                label: const Text(
                  'Create New Match',
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
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Navigate to home screen to see existing matches
                DefaultTabController.of(context).animateTo(0);
              },
              child: const Text(
                'Or go to Home to see existing matches',
                style: TextStyle(
                  color: Color(0xFF9C9C9C),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
