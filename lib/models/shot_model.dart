enum ShotType {
  approachShot('Approach Shot'),
  passingShot('Passing Shot'),
  groundStroke('Ground Stroke'),
  dropShot('Drop Shot'),
  volley('Volley'),
  overhead('Overhead'),
  lob('Lob');

  const ShotType(this.displayName);
  final String displayName;
}

enum ShotOutcome {
  winner('Winner'),
  forcedError('Forced Error'),
  unforcedError('Unforced Error');

  const ShotOutcome(this.displayName);
  final String displayName;
}

class ShotData {
  final ShotType type;
  final ShotOutcome outcome;
  final DateTime timestamp;

  ShotData({
    required this.type,
    required this.outcome,
    required this.timestamp,
  });
}
