enum MatchFormat {
  bestOfThree('🟡 Best of 3', 3),
  bestOfFive('🔵 Best of 5', 5),
  custom('⚪ Custom', 0);

  const MatchFormat(this.displayName, this.sets);
  final String displayName;
  final int sets;
}

enum MatchType {
  friendly('Friendly'),
  practice('Practice'),
  tournament('Tournament');

  const MatchType(this.displayName);
  final String displayName;
}

enum MatchResult {
  win,
  loss,
  inProgress,
  cancelled
}

class Match {
  final String id;
  final String playerName;
  final String opponentName;
  final MatchFormat format;
  final MatchType type;
  final int? customSets; // Only used when format is custom
  final DateTime date; // Date of the match
  final DateTime createdAt;
  final DateTime? completedAt;
  final MatchResult result;
  final List<Set> sets;
  final String? notes;
  final bool isFinished;
  
  // Match statistics
  final int totalServes;
  final int firstServesIn;
  final int aces;
  final int doubleFaults;
  final int faults;
  final int footFaults;
  final int successfulServes;
  
  // Points statistics
  final int pointsWon;
  final int totalPoints;
  final int pointsWonServing;
  final int totalPointsServing;
  final int pointsWonReceiving;
  final int totalPointsReceiving;
  final int breakpointsConverted;
  final int totalBreakpoints;
  
  // Rally statistics - Winners
  final int approachShotWinners;
  final int passingShotWinners;
  final int groundStrokeWinners;
  final int dropShotWinners;
  final int volleyWinners;
  final int overheadWinners;
  final int lobWinners;
  
  // Rally statistics - Forced Errors
  final int approachShotForcedErrors;
  final int passingShotForcedErrors;
  final int groundStrokeForcedErrors;
  final int dropShotForcedErrors;
  final int volleyForcedErrors;
  final int overheadForcedErrors;
  final int lobForcedErrors;
  
  // Rally statistics - Unforced Errors
  final int approachShotUnforcedErrors;
  final int passingShotUnforcedErrors;
  final int groundStrokeUnforcedErrors;
  final int dropShotUnforcedErrors;
  final int volleyUnforcedErrors;
  final int overheadUnforcedErrors;
  final int lobUnforcedErrors;

  Match({
    required this.id,
    required this.playerName,
    required this.opponentName,
    required this.format,
    required this.type,
    this.customSets,
    required this.date,
    required this.createdAt,
    this.completedAt,
    this.result = MatchResult.inProgress,
    this.sets = const [],
    this.notes,
    this.isFinished = false,
    this.totalServes = 0,
    this.firstServesIn = 0,
    this.aces = 0,
    this.doubleFaults = 0,
    this.faults = 0,
    this.footFaults = 0,
    this.successfulServes = 0,
    this.pointsWon = 0,
    this.totalPoints = 0,
    this.pointsWonServing = 0,
    this.totalPointsServing = 0,
    this.pointsWonReceiving = 0,
    this.totalPointsReceiving = 0,
    this.breakpointsConverted = 0,
    this.totalBreakpoints = 0,
    this.approachShotWinners = 0,
    this.passingShotWinners = 0,
    this.groundStrokeWinners = 0,
    this.dropShotWinners = 0,
    this.volleyWinners = 0,
    this.overheadWinners = 0,
    this.lobWinners = 0,
    this.approachShotForcedErrors = 0,
    this.passingShotForcedErrors = 0,
    this.groundStrokeForcedErrors = 0,
    this.dropShotForcedErrors = 0,
    this.volleyForcedErrors = 0,
    this.overheadForcedErrors = 0,
    this.lobForcedErrors = 0,
    this.approachShotUnforcedErrors = 0,
    this.passingShotUnforcedErrors = 0,
    this.groundStrokeUnforcedErrors = 0,
    this.dropShotUnforcedErrors = 0,
    this.volleyUnforcedErrors = 0,
    this.overheadUnforcedErrors = 0,
    this.lobUnforcedErrors = 0,
  });

  // Get total number of sets for this match
  int get totalSets {
    return format == MatchFormat.custom 
        ? (customSets ?? 3) 
        : format.sets;
  }

  // Get match duration if completed
  Duration? get duration {
    if (completedAt != null) {
      return completedAt!.difference(createdAt);
    }
    return null;
  }

  // Check if match is completed
  bool get isCompleted => result != MatchResult.inProgress;

  // Get player's won sets count
  int get playerSetsWon {
    return sets.where((set) => set.playerWon).length;
  }

  // Get opponent's won sets count
  int get opponentSetsWon {
    return sets.where((set) => !set.playerWon).length;
  }

  // Calculate statistics
  double get firstServePercentage {
    if (totalServes == 0) return 0.0;
    return (firstServesIn / totalServes) * 100;
  }

  double get faultsPercentage {
    if (totalServes == 0) return 0.0;
    return (doubleFaults / totalServes) * 100;
  }
  
  // Points statistics calculations
  double get pointsWonPercentage {
    if (totalPoints == 0) return 0.0;
    return (pointsWon / totalPoints) * 100;
  }
  
  double get pointsWonServingPercentage {
    if (totalPointsServing == 0) return 0.0;
    return (pointsWonServing / totalPointsServing) * 100;
  }
  
  double get pointsWonReceivingPercentage {
    if (totalPointsReceiving == 0) return 0.0;
    return (pointsWonReceiving / totalPointsReceiving) * 100;
  }
  
  double get breakpointsConvertedPercentage {
    if (totalBreakpoints == 0) return 0.0;
    return (breakpointsConverted / totalBreakpoints) * 100;
  }

  // Copy with method for updating match
  Match copyWith({
    String? id,
    String? playerName,
    String? opponentName,
    MatchFormat? format,
    MatchType? type,
    int? customSets,
    DateTime? date,
    DateTime? createdAt,
    DateTime? completedAt,
    MatchResult? result,
    List<Set>? sets,
    String? notes,
    bool? isFinished,
    int? totalServes,
    int? firstServesIn,
    int? aces,
    int? doubleFaults,
    int? faults,
    int? footFaults,
    int? successfulServes,
    int? pointsWon,
    int? totalPoints,
    int? pointsWonServing,
    int? totalPointsServing,
    int? pointsWonReceiving,
    int? totalPointsReceiving,
    int? breakpointsConverted,
    int? totalBreakpoints,
    int? approachShotWinners,
    int? passingShotWinners,
    int? groundStrokeWinners,
    int? dropShotWinners,
    int? volleyWinners,
    int? overheadWinners,
    int? lobWinners,
    int? approachShotForcedErrors,
    int? passingShotForcedErrors,
    int? groundStrokeForcedErrors,
    int? dropShotForcedErrors,
    int? volleyForcedErrors,
    int? overheadForcedErrors,
    int? lobForcedErrors,
    int? approachShotUnforcedErrors,
    int? passingShotUnforcedErrors,
    int? groundStrokeUnforcedErrors,
    int? dropShotUnforcedErrors,
    int? volleyUnforcedErrors,
    int? overheadUnforcedErrors,
    int? lobUnforcedErrors,
  }) {
    return Match(
      id: id ?? this.id,
      playerName: playerName ?? this.playerName,
      opponentName: opponentName ?? this.opponentName,
      format: format ?? this.format,
      type: type ?? this.type,
      customSets: customSets ?? this.customSets,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      result: result ?? this.result,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      isFinished: isFinished ?? this.isFinished,
      totalServes: totalServes ?? this.totalServes,
      firstServesIn: firstServesIn ?? this.firstServesIn,
      aces: aces ?? this.aces,
      doubleFaults: doubleFaults ?? this.doubleFaults,
      faults: faults ?? this.faults,
      footFaults: footFaults ?? this.footFaults,
      successfulServes: successfulServes ?? this.successfulServes,
      pointsWon: pointsWon ?? this.pointsWon,
      totalPoints: totalPoints ?? this.totalPoints,
      pointsWonServing: pointsWonServing ?? this.pointsWonServing,
      totalPointsServing: totalPointsServing ?? this.totalPointsServing,
      pointsWonReceiving: pointsWonReceiving ?? this.pointsWonReceiving,
      totalPointsReceiving: totalPointsReceiving ?? this.totalPointsReceiving,
      breakpointsConverted: breakpointsConverted ?? this.breakpointsConverted,
      totalBreakpoints: totalBreakpoints ?? this.totalBreakpoints,
      approachShotWinners: approachShotWinners ?? this.approachShotWinners,
      passingShotWinners: passingShotWinners ?? this.passingShotWinners,
      groundStrokeWinners: groundStrokeWinners ?? this.groundStrokeWinners,
      dropShotWinners: dropShotWinners ?? this.dropShotWinners,
      volleyWinners: volleyWinners ?? this.volleyWinners,
      overheadWinners: overheadWinners ?? this.overheadWinners,
      lobWinners: lobWinners ?? this.lobWinners,
      approachShotForcedErrors: approachShotForcedErrors ?? this.approachShotForcedErrors,
      passingShotForcedErrors: passingShotForcedErrors ?? this.passingShotForcedErrors,
      groundStrokeForcedErrors: groundStrokeForcedErrors ?? this.groundStrokeForcedErrors,
      dropShotForcedErrors: dropShotForcedErrors ?? this.dropShotForcedErrors,
      volleyForcedErrors: volleyForcedErrors ?? this.volleyForcedErrors,
      overheadForcedErrors: overheadForcedErrors ?? this.overheadForcedErrors,
      lobForcedErrors: lobForcedErrors ?? this.lobForcedErrors,
      approachShotUnforcedErrors: approachShotUnforcedErrors ?? this.approachShotUnforcedErrors,
      passingShotUnforcedErrors: passingShotUnforcedErrors ?? this.passingShotUnforcedErrors,
      groundStrokeUnforcedErrors: groundStrokeUnforcedErrors ?? this.groundStrokeUnforcedErrors,
      dropShotUnforcedErrors: dropShotUnforcedErrors ?? this.dropShotUnforcedErrors,
      volleyUnforcedErrors: volleyUnforcedErrors ?? this.volleyUnforcedErrors,
      overheadUnforcedErrors: overheadUnforcedErrors ?? this.overheadUnforcedErrors,
      lobUnforcedErrors: lobUnforcedErrors ?? this.lobUnforcedErrors,
    );
  }

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerName': playerName,
      'opponentName': opponentName,
      'format': format.name,
      'type': type.name,
      'customSets': customSets,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'result': result.name,
      'sets': sets.map((set) => set.toJson()).toList(),
      'notes': notes,
      'isFinished': isFinished,
      'totalServes': totalServes,
      'firstServesIn': firstServesIn,
      'aces': aces,
      'doubleFaults': doubleFaults,
      'faults': faults,
      'footFaults': footFaults,
      'successfulServes': successfulServes,
      'pointsWon': pointsWon,
      'totalPoints': totalPoints,
      'pointsWonServing': pointsWonServing,
      'totalPointsServing': totalPointsServing,
      'pointsWonReceiving': pointsWonReceiving,
      'totalPointsReceiving': totalPointsReceiving,
      'breakpointsConverted': breakpointsConverted,
      'totalBreakpoints': totalBreakpoints,
      'approachShotWinners': approachShotWinners,
      'passingShotWinners': passingShotWinners,
      'groundStrokeWinners': groundStrokeWinners,
      'dropShotWinners': dropShotWinners,
      'volleyWinners': volleyWinners,
      'overheadWinners': overheadWinners,
      'lobWinners': lobWinners,
      'approachShotForcedErrors': approachShotForcedErrors,
      'passingShotForcedErrors': passingShotForcedErrors,
      'groundStrokeForcedErrors': groundStrokeForcedErrors,
      'dropShotForcedErrors': dropShotForcedErrors,
      'volleyForcedErrors': volleyForcedErrors,
      'overheadForcedErrors': overheadForcedErrors,
      'lobForcedErrors': lobForcedErrors,
      'approachShotUnforcedErrors': approachShotUnforcedErrors,
      'passingShotUnforcedErrors': passingShotUnforcedErrors,
      'groundStrokeUnforcedErrors': groundStrokeUnforcedErrors,
      'dropShotUnforcedErrors': dropShotUnforcedErrors,
      'volleyUnforcedErrors': volleyUnforcedErrors,
      'overheadUnforcedErrors': overheadUnforcedErrors,
      'lobUnforcedErrors': lobUnforcedErrors,
    };
  }

  static Match fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      playerName: json['playerName'] as String,
      opponentName: json['opponentName'] as String,
      format: MatchFormat.values.firstWhere(
        (format) => format.name == json['format'],
        orElse: () => MatchFormat.bestOfThree,
      ),
      type: MatchType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => MatchType.friendly,
      ),
      customSets: json['customSets'] as int?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      result: MatchResult.values.firstWhere(
        (result) => result.name == json['result'],
        orElse: () => MatchResult.inProgress,
      ),
      sets: (json['sets'] as List<dynamic>?)
          ?.map((setJson) => Set.fromJson(setJson as Map<String, dynamic>))
          .toList() ?? [],
      notes: json['notes'] as String?,
      isFinished: json['isFinished'] as bool? ?? false,
      totalServes: json['totalServes'] as int? ?? 0,
      firstServesIn: json['firstServesIn'] as int? ?? 0,
      aces: json['aces'] as int? ?? 0,
      doubleFaults: json['doubleFaults'] as int? ?? 0,
      faults: json['faults'] as int? ?? 0,
      footFaults: json['footFaults'] as int? ?? 0,
      successfulServes: json['successfulServes'] as int? ?? 0,
      pointsWon: json['pointsWon'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      pointsWonServing: json['pointsWonServing'] as int? ?? 0,
      totalPointsServing: json['totalPointsServing'] as int? ?? 0,
      pointsWonReceiving: json['pointsWonReceiving'] as int? ?? 0,
      totalPointsReceiving: json['totalPointsReceiving'] as int? ?? 0,
      breakpointsConverted: json['breakpointsConverted'] as int? ?? 0,
      totalBreakpoints: json['totalBreakpoints'] as int? ?? 0,
      approachShotWinners: json['approachShotWinners'] as int? ?? 0,
      passingShotWinners: json['passingShotWinners'] as int? ?? 0,
      groundStrokeWinners: json['groundStrokeWinners'] as int? ?? 0,
      dropShotWinners: json['dropShotWinners'] as int? ?? 0,
      volleyWinners: json['volleyWinners'] as int? ?? 0,
      overheadWinners: json['overheadWinners'] as int? ?? 0,
      lobWinners: json['lobWinners'] as int? ?? 0,
      approachShotForcedErrors: json['approachShotForcedErrors'] as int? ?? 0,
      passingShotForcedErrors: json['passingShotForcedErrors'] as int? ?? 0,
      groundStrokeForcedErrors: json['groundStrokeForcedErrors'] as int? ?? 0,
      dropShotForcedErrors: json['dropShotForcedErrors'] as int? ?? 0,
      volleyForcedErrors: json['volleyForcedErrors'] as int? ?? 0,
      overheadForcedErrors: json['overheadForcedErrors'] as int? ?? 0,
      lobForcedErrors: json['lobForcedErrors'] as int? ?? 0,
      approachShotUnforcedErrors: json['approachShotUnforcedErrors'] as int? ?? 0,
      passingShotUnforcedErrors: json['passingShotUnforcedErrors'] as int? ?? 0,
      groundStrokeUnforcedErrors: json['groundStrokeUnforcedErrors'] as int? ?? 0,
      dropShotUnforcedErrors: json['dropShotUnforcedErrors'] as int? ?? 0,
      volleyUnforcedErrors: json['volleyUnforcedErrors'] as int? ?? 0,
      overheadUnforcedErrors: json['overheadUnforcedErrors'] as int? ?? 0,
      lobUnforcedErrors: json['lobUnforcedErrors'] as int? ?? 0,
    );
  }
}

class Set {
  final int playerGames;
  final int opponentGames;
  final bool playerWon;
  final bool isTiebreak;
  final int? tiebreakPlayerScore;
  final int? tiebreakOpponentScore;
  
  // Per-set serve statistics
  final int aces;
  final int faults;
  final int footFaults;
  final int successfulServes;
  final int totalServes;
  
  // Per-set rally statistics - Winners
  final int approachShotWinners;
  final int passingShotWinners;
  final int groundStrokeWinners;
  final int dropShotWinners;
  final int volleyWinners;
  final int overheadWinners;
  final int lobWinners;
  
  // Per-set rally statistics - Forced Errors
  final int approachShotForcedErrors;
  final int passingShotForcedErrors;
  final int groundStrokeForcedErrors;
  final int dropShotForcedErrors;
  final int volleyForcedErrors;
  final int overheadForcedErrors;
  final int lobForcedErrors;
  
  // Per-set rally statistics - Unforced Errors
  final int approachShotUnforcedErrors;
  final int passingShotUnforcedErrors;
  final int groundStrokeUnforcedErrors;
  final int dropShotUnforcedErrors;
  final int volleyUnforcedErrors;
  final int overheadUnforcedErrors;
  final int lobUnforcedErrors;

  Set({
    required this.playerGames,
    required this.opponentGames,
    required this.playerWon,
    this.isTiebreak = false,
    this.tiebreakPlayerScore,
    this.tiebreakOpponentScore,
    this.aces = 0,
    this.faults = 0,
    this.footFaults = 0,
    this.successfulServes = 0,
    this.totalServes = 0,
    this.approachShotWinners = 0,
    this.passingShotWinners = 0,
    this.groundStrokeWinners = 0,
    this.dropShotWinners = 0,
    this.volleyWinners = 0,
    this.overheadWinners = 0,
    this.lobWinners = 0,
    this.approachShotForcedErrors = 0,
    this.passingShotForcedErrors = 0,
    this.groundStrokeForcedErrors = 0,
    this.dropShotForcedErrors = 0,
    this.volleyForcedErrors = 0,
    this.overheadForcedErrors = 0,
    this.lobForcedErrors = 0,
    this.approachShotUnforcedErrors = 0,
    this.passingShotUnforcedErrors = 0,
    this.groundStrokeUnforcedErrors = 0,
    this.dropShotUnforcedErrors = 0,
    this.volleyUnforcedErrors = 0,
    this.overheadUnforcedErrors = 0,
    this.lobUnforcedErrors = 0,
  });

  // Get set score as string (e.g., "6-4", "7-6(5)")
  String get scoreString {
    if (isTiebreak && tiebreakPlayerScore != null && tiebreakOpponentScore != null) {
      return '$playerGames-$opponentGames(${playerWon ? tiebreakPlayerScore : tiebreakOpponentScore})';
    }
    return '$playerGames-$opponentGames';
  }

  // JSON serialization methods for Set
  Map<String, dynamic> toJson() {
    return {
      'playerGames': playerGames,
      'opponentGames': opponentGames,
      'playerWon': playerWon,
      'isTiebreak': isTiebreak,
      'tiebreakPlayerScore': tiebreakPlayerScore,
      'tiebreakOpponentScore': tiebreakOpponentScore,
      'aces': aces,
      'faults': faults,
      'footFaults': footFaults,
      'successfulServes': successfulServes,
      'totalServes': totalServes,
      'approachShotWinners': approachShotWinners,
      'passingShotWinners': passingShotWinners,
      'groundStrokeWinners': groundStrokeWinners,
      'dropShotWinners': dropShotWinners,
      'volleyWinners': volleyWinners,
      'overheadWinners': overheadWinners,
      'lobWinners': lobWinners,
      'approachShotForcedErrors': approachShotForcedErrors,
      'passingShotForcedErrors': passingShotForcedErrors,
      'groundStrokeForcedErrors': groundStrokeForcedErrors,
      'dropShotForcedErrors': dropShotForcedErrors,
      'volleyForcedErrors': volleyForcedErrors,
      'overheadForcedErrors': overheadForcedErrors,
      'lobForcedErrors': lobForcedErrors,
      'approachShotUnforcedErrors': approachShotUnforcedErrors,
      'passingShotUnforcedErrors': passingShotUnforcedErrors,
      'groundStrokeUnforcedErrors': groundStrokeUnforcedErrors,
      'dropShotUnforcedErrors': dropShotUnforcedErrors,
      'volleyUnforcedErrors': volleyUnforcedErrors,
      'overheadUnforcedErrors': overheadUnforcedErrors,
      'lobUnforcedErrors': lobUnforcedErrors,
    };
  }

  static Set fromJson(Map<String, dynamic> json) {
    return Set(
      playerGames: json['playerGames'] as int,
      opponentGames: json['opponentGames'] as int,
      playerWon: json['playerWon'] as bool,
      isTiebreak: json['isTiebreak'] as bool? ?? false,
      tiebreakPlayerScore: json['tiebreakPlayerScore'] as int?,
      tiebreakOpponentScore: json['tiebreakOpponentScore'] as int?,
      aces: json['aces'] as int? ?? 0,
      faults: json['faults'] as int? ?? 0,
      footFaults: json['footFaults'] as int? ?? 0,
      successfulServes: json['successfulServes'] as int? ?? 0,
      totalServes: json['totalServes'] as int? ?? 0,
      approachShotWinners: json['approachShotWinners'] as int? ?? 0,
      passingShotWinners: json['passingShotWinners'] as int? ?? 0,
      groundStrokeWinners: json['groundStrokeWinners'] as int? ?? 0,
      dropShotWinners: json['dropShotWinners'] as int? ?? 0,
      volleyWinners: json['volleyWinners'] as int? ?? 0,
      overheadWinners: json['overheadWinners'] as int? ?? 0,
      lobWinners: json['lobWinners'] as int? ?? 0,
      approachShotForcedErrors: json['approachShotForcedErrors'] as int? ?? 0,
      passingShotForcedErrors: json['passingShotForcedErrors'] as int? ?? 0,
      groundStrokeForcedErrors: json['groundStrokeForcedErrors'] as int? ?? 0,
      dropShotForcedErrors: json['dropShotForcedErrors'] as int? ?? 0,
      volleyForcedErrors: json['volleyForcedErrors'] as int? ?? 0,
      overheadForcedErrors: json['overheadForcedErrors'] as int? ?? 0,
      lobForcedErrors: json['lobForcedErrors'] as int? ?? 0,
      approachShotUnforcedErrors: json['approachShotUnforcedErrors'] as int? ?? 0,
      passingShotUnforcedErrors: json['passingShotUnforcedErrors'] as int? ?? 0,
      groundStrokeUnforcedErrors: json['groundStrokeUnforcedErrors'] as int? ?? 0,
      dropShotUnforcedErrors: json['dropShotUnforcedErrors'] as int? ?? 0,
      volleyUnforcedErrors: json['volleyUnforcedErrors'] as int? ?? 0,
      overheadUnforcedErrors: json['overheadUnforcedErrors'] as int? ?? 0,
      lobUnforcedErrors: json['lobUnforcedErrors'] as int? ?? 0,
    );
  }
}