import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/match_model.dart';
import 'momentum_screen.dart';
import 'tracking_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(color: Color(0xFF3C3C3C)),
              child: const Text(
                'Rally Statistics',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4CAF50),
          indicatorWeight: 3,
          labelColor: Colors.white,
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
            Tab(text: 'All Sets'),
            Tab(text: 'Set 1'),
            Tab(text: 'Set 2'),
            Tab(text: 'Set 3'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildStatisticsTable('All Sets'),
              _buildStatisticsTable('Set 1'),
              _buildStatisticsTable('Set 2'),
              _buildStatisticsTable('Set 3'),
            ],
          ),
          // Navigation buttons at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 30,
            child: Row(
              children: [
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
                        backgroundColor: const Color(0xFF3C3C3C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MomentumScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTable(String setName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Get the most recent match
          final matches = appProvider.matches;
          Match? currentMatch;
          if (matches.isNotEmpty) {
            currentMatch = matches.reduce(
              (a, b) => a.date.isAfter(b.date) ? a : b,
            );
          }

          // Calculate set-specific data
          final setData = _getSetSpecificData(currentMatch, setName);

          return Column(
            children: [
              // Show info message for individual sets
              if (setName != 'All Sets') _buildSetInfoMessage(setName, setData),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4C4C4C)),
                ),
                child: Column(
                  children: [
                    // Table header
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF3C3C3C),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildHeaderCell('Shot Type'),
                          ),
                          Expanded(flex: 2, child: _buildHeaderCell('Winners')),
                          Expanded(
                            flex: 2,
                            child: _buildHeaderCell('Forced Errors'),
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildHeaderCell('Unforced Errors'),
                          ),
                        ],
                      ),
                    ),
                    // Table rows with set-specific data
                    _buildTableRow(
                      'Approach Shots',
                      setData['approachShotWinners'].toString(),
                      setData['approachShotForcedErrors'].toString(),
                      setData['approachShotUnforcedErrors'].toString(),
                    ),
                    _buildTableRow(
                      'Passing Shots',
                      setData['passingShotWinners'].toString(),
                      setData['passingShotForcedErrors'].toString(),
                      setData['passingShotUnforcedErrors'].toString(),
                    ),
                    _buildTableRow(
                      'Ground Strokes',
                      setData['groundStrokeWinners'].toString(),
                      setData['groundStrokeForcedErrors'].toString(),
                      setData['groundStrokeUnforcedErrors'].toString(),
                    ),
                    _buildTableRow(
                      'Drop Shots',
                      setData['dropShotWinners'].toString(),
                      setData['dropShotForcedErrors'].toString(),
                      setData['dropShotUnforcedErrors'].toString(),
                    ),
                    _buildTableRow(
                      'Volleys',
                      setData['volleyWinners'].toString(),
                      setData['volleyForcedErrors'].toString(),
                      setData['volleyUnforcedErrors'].toString(),
                    ),
                    _buildTableRow(
                      'Overhead',
                      setData['overheadWinners'].toString(),
                      setData['overheadForcedErrors'].toString(),
                      setData['overheadUnforcedErrors'].toString(),
                    ),
                    _buildTableRow(
                      'Lobs',
                      setData['lobWinners'].toString(),
                      setData['lobForcedErrors'].toString(),
                      setData['lobUnforcedErrors'].toString(),
                    ),
                    // Serve statistics section
                    _buildServeStatisticsSection(
                      currentMatch,
                      setName,
                      setData,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String shotType,
    String winners,
    String forcedErrors,
    String unforcedErrors,
  ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF4C4C4C), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildCell(shotType, isLabel: true)),
          Expanded(flex: 2, child: _buildCell(winners)),
          Expanded(flex: 2, child: _buildCell(forcedErrors)),
          Expanded(flex: 2, child: _buildCell(unforcedErrors)),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {bool isLabel = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: isLabel ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          color: isLabel ? Colors.white : const Color(0xFF9C9C9C),
          fontSize: 14,
          fontFamily: 'Roboto',
          fontWeight: isLabel ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildServeStatisticsSection(
    Match? match,
    String setName,
    Map<String, int> setData,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF4C4C4C), width: 2)),
      ),
      child: Column(
        children: [
          // Serve statistics header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFF4C4C4C)),
            child: const Center(
              child: Text(
                'SERVE STATISTICS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Serve statistics rows
          _buildTableRow('Aces', setData['aces'].toString(), '-', '-'),
          _buildTableRow('Faults', setData['faults'].toString(), '-', '-'),
          _buildTableRow(
            'Foot Faults',
            setData['footFaults'].toString(),
            '-',
            '-',
          ),
          _buildTableRow(
            'Successful Serves',
            setData['successfulServes'].toString(),
            '-',
            '-',
          ),
          _buildTableRow(
            'Total Serves',
            setData['totalServes'].toString(),
            '-',
            '-',
          ),
        ],
      ),
    );
  }

  Widget _buildSetInfoMessage(String setName, Map<String, int> setData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              setData['totalServes'] == 0
                  ? '$setName has not been played yet.'
                  : '$setName statistics are tracked from actual match data.',
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getSetSpecificData(Match? match, String setName) {
    if (match == null) {
      return {
        'approachShotWinners': 0,
        'passingShotWinners': 0,
        'groundStrokeWinners': 0,
        'dropShotWinners': 0,
        'volleyWinners': 0,
        'overheadWinners': 0,
        'lobWinners': 0,
        'approachShotForcedErrors': 0,
        'passingShotForcedErrors': 0,
        'groundStrokeForcedErrors': 0,
        'dropShotForcedErrors': 0,
        'volleyForcedErrors': 0,
        'overheadForcedErrors': 0,
        'lobForcedErrors': 0,
        'approachShotUnforcedErrors': 0,
        'passingShotUnforcedErrors': 0,
        'groundStrokeUnforcedErrors': 0,
        'dropShotUnforcedErrors': 0,
        'volleyUnforcedErrors': 0,
        'overheadUnforcedErrors': 0,
        'lobUnforcedErrors': 0,
        'aces': 0,
        'faults': 0,
        'footFaults': 0,
        'successfulServes': 0,
        'totalServes': 0,
      };
    }

    // For "All Sets" tab, return match totals
    if (setName == 'All Sets') {
      return {
        'approachShotWinners': match.approachShotWinners,
        'passingShotWinners': match.passingShotWinners,
        'groundStrokeWinners': match.groundStrokeWinners,
        'dropShotWinners': match.dropShotWinners,
        'volleyWinners': match.volleyWinners,
        'overheadWinners': match.overheadWinners,
        'lobWinners': match.lobWinners,
        'approachShotForcedErrors': match.approachShotForcedErrors,
        'passingShotForcedErrors': match.passingShotForcedErrors,
        'groundStrokeForcedErrors': match.groundStrokeForcedErrors,
        'dropShotForcedErrors': match.dropShotForcedErrors,
        'volleyForcedErrors': match.volleyForcedErrors,
        'overheadForcedErrors': match.overheadForcedErrors,
        'lobForcedErrors': match.lobForcedErrors,
        'approachShotUnforcedErrors': match.approachShotUnforcedErrors,
        'passingShotUnforcedErrors': match.passingShotUnforcedErrors,
        'groundStrokeUnforcedErrors': match.groundStrokeUnforcedErrors,
        'dropShotUnforcedErrors': match.dropShotUnforcedErrors,
        'volleyUnforcedErrors': match.volleyUnforcedErrors,
        'overheadUnforcedErrors': match.overheadUnforcedErrors,
        'lobUnforcedErrors': match.lobUnforcedErrors,
        'aces': match.aces,
        'faults': match.faults,
        'footFaults': match.footFaults,
        'successfulServes': match.successfulServes,
        'totalServes': match.totalServes,
      };
    }

    // For individual sets, use actual set data
    final setIndex = int.tryParse(setName.replaceAll('Set ', '')) ?? 1;

    // Get reference to the tracking screen state if it exists
    final trackingScreen = TrackingScreenState.of(context);

    // Check if this specific set exists
    if (setIndex > match.sets.length) {
      // If this is the current set being played and we have access to the tracking screen
      // The tracking screen's currentSet represents the actual set number (1, 2, 3, etc.)
      // We should show current set data when the requested setIndex matches the current set being played
      if (trackingScreen != null && setIndex == trackingScreen.currentSet) {
        return {
          'approachShotWinners': trackingScreen.currentSetApproachWinners,
          'passingShotWinners': trackingScreen.currentSetPassingWinners,
          'groundStrokeWinners': trackingScreen.currentSetGroundstrokeWinners,
          'dropShotWinners': trackingScreen.currentSetDropshotWinners,
          'volleyWinners': trackingScreen.currentSetVolleyWinners,
          'overheadWinners': trackingScreen.currentSetOverheadWinners,
          'lobWinners': trackingScreen.currentSetLobWinners,
          'approachShotForcedErrors': trackingScreen.currentSetApproachForced,
          'passingShotForcedErrors': trackingScreen.currentSetPassingForced,
          'groundStrokeForcedErrors':
              trackingScreen.currentSetGroundstrokeForced,
          'dropShotForcedErrors': trackingScreen.currentSetDropshotForced,
          'volleyForcedErrors': trackingScreen.currentSetVolleyForced,
          'overheadForcedErrors': trackingScreen.currentSetOverheadForced,
          'lobForcedErrors': trackingScreen.currentSetLobForced,
          'approachShotUnforcedErrors':
              trackingScreen.currentSetApproachUnforced,
          'passingShotUnforcedErrors': trackingScreen.currentSetPassingUnforced,
          'groundStrokeUnforcedErrors':
              trackingScreen.currentSetGroundstrokeUnforced,
          'dropShotUnforcedErrors': trackingScreen.currentSetDropshotUnforced,
          'volleyUnforcedErrors': trackingScreen.currentSetVolleyUnforced,
          'overheadUnforcedErrors': trackingScreen.currentSetOverheadUnforced,
          'lobUnforcedErrors': trackingScreen.currentSetLobUnforced,
          'aces': trackingScreen.currentSetAces,
          'faults': trackingScreen.currentSetFaults,
          'footFaults': trackingScreen.currentSetFootFaults,
          'successfulServes': trackingScreen.currentSetSuccessfulServes,
          'totalServes': trackingScreen.currentSetTotalServes,
        };
      }
      // If set doesn't exist yet, return zeros
      return {
        'approachShotWinners': 0,
        'passingShotWinners': 0,
        'groundStrokeWinners': 0,
        'dropShotWinners': 0,
        'volleyWinners': 0,
        'overheadWinners': 0,
        'lobWinners': 0,
        'approachShotForcedErrors': 0,
        'passingShotForcedErrors': 0,
        'groundStrokeForcedErrors': 0,
        'dropShotForcedErrors': 0,
        'volleyForcedErrors': 0,
        'overheadForcedErrors': 0,
        'lobForcedErrors': 0,
        'approachShotUnforcedErrors': 0,
        'passingShotUnforcedErrors': 0,
        'groundStrokeUnforcedErrors': 0,
        'dropShotUnforcedErrors': 0,
        'volleyUnforcedErrors': 0,
        'overheadUnforcedErrors': 0,
        'lobUnforcedErrors': 0,
        'aces': 0,
        'faults': 0,
        'footFaults': 0,
        'successfulServes': 0,
        'totalServes': 0,
      };
    }

    // Get actual set data
    final setData = match.sets[setIndex - 1]; // setIndex is 1-based
    return {
      'approachShotWinners': setData.approachShotWinners,
      'passingShotWinners': setData.passingShotWinners,
      'groundStrokeWinners': setData.groundStrokeWinners,
      'dropShotWinners': setData.dropShotWinners,
      'volleyWinners': setData.volleyWinners,
      'overheadWinners': setData.overheadWinners,
      'lobWinners': setData.lobWinners,
      'approachShotForcedErrors': setData.approachShotForcedErrors,
      'passingShotForcedErrors': setData.passingShotForcedErrors,
      'groundStrokeForcedErrors': setData.groundStrokeForcedErrors,
      'dropShotForcedErrors': setData.dropShotForcedErrors,
      'volleyForcedErrors': setData.volleyForcedErrors,
      'overheadForcedErrors': setData.overheadForcedErrors,
      'lobForcedErrors': setData.lobForcedErrors,
      'approachShotUnforcedErrors': setData.approachShotUnforcedErrors,
      'passingShotUnforcedErrors': setData.passingShotUnforcedErrors,
      'groundStrokeUnforcedErrors': setData.groundStrokeUnforcedErrors,
      'dropShotUnforcedErrors': setData.dropShotUnforcedErrors,
      'volleyUnforcedErrors': setData.volleyUnforcedErrors,
      'overheadUnforcedErrors': setData.overheadUnforcedErrors,
      'lobUnforcedErrors': setData.lobUnforcedErrors,
      'aces': setData.aces,
      'faults': setData.faults,
      'footFaults': setData.footFaults,
      'successfulServes': setData.successfulServes,
      'totalServes': setData.totalServes,
    };
  }
}
