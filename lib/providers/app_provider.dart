import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  // User data
  String _userName = '';
  String? _userNickname;
  String _userLevel = 'Beginner';
  
  // Tracking data
  int _totalSessions = 0;
  int _totalHours = 0;
  double _winRate = 0.0;
  
  // Current session data
  bool _isTracking = false;
  DateTime? _sessionStartTime;
  
  // Matches data
  List<Match> _matches = [];
  
  // Settings
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  MatchFormat _defaultMatchFormat = MatchFormat.bestOfThree;
  
  // Data loading state
  bool _isLoading = false;
  bool _hasLoadedData = false;
  
  // Getters
  String get userName => _userName;
  String? get userNickname => _userNickname;
  String get userLevel => _userLevel;
  
  // Get greeting with nickname or default
  String get greeting => _userNickname != null && _userNickname!.isNotEmpty 
      ? 'Hi, $_userNickname' 
      : 'Hi, Player!';
  int get totalSessions => _totalSessions;
  int get totalHours => _totalHours;
  double get winRate => _winRate;
  bool get isTracking => _isTracking;
  DateTime? get sessionStartTime => _sessionStartTime;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  MatchFormat get defaultMatchFormat => _defaultMatchFormat;
  bool get isLoading => _isLoading;
  bool get hasLoadedData => _hasLoadedData;
  
  // Matches getters
  List<Match> get matches => List.unmodifiable(_matches);
  int get totalMatches => _matches.length;
  int get matchesWon => _matches.where((match) => match.result == MatchResult.win).length;
  int get matchesLost => _matches.where((match) => match.result == MatchResult.loss).length;
  double get matchWinRate => totalMatches > 0 ? (matchesWon / totalMatches) * 100 : 0.0;
  
  // Setters and methods
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
    saveData(); // Auto-save when user data changes
  }
  
  void setUserNickname(String? nickname) {
    _userNickname = nickname;
    notifyListeners();
    saveData(); // Auto-save when user data changes
  }
  
  void setUserLevel(String level) {
    _userLevel = level;
    notifyListeners();
    saveData(); // Auto-save when user data changes
  }
  
  void startTracking() {
    _isTracking = true;
    _sessionStartTime = DateTime.now();
    notifyListeners();
  }
  
  void stopTracking() {
    if (_isTracking && _sessionStartTime != null) {
      _isTracking = false;
      _totalSessions++;
      
      // Calculate session duration in hours
      final duration = DateTime.now().difference(_sessionStartTime!);
      _totalHours += duration.inHours;
      
      _sessionStartTime = null;
      notifyListeners();
      saveData(); // Auto-save when session data changes
    }
  }
  
  void updateWinRate(double rate) {
    _winRate = rate;
    notifyListeners();
    saveData(); // Auto-save when win rate changes
  }
  
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    saveData(); // Auto-save when settings change
  }
  
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    saveData(); // Auto-save when settings change
  }
  
  void setDefaultMatchFormat(MatchFormat format) {
    _defaultMatchFormat = format;
    notifyListeners();
    saveData(); // Auto-save when settings change
  }
  
  // Match management methods
  void addMatch(Match match) {
    _matches.add(match);
    notifyListeners();
    saveData(); // Auto-save when matches change
  }
  
  void updateMatch(String matchId, Match updatedMatch) {
    final index = _matches.indexWhere((match) => match.id == matchId);
    if (index != -1) {
      _matches[index] = updatedMatch;
      notifyListeners();
      saveData(); // Auto-save when matches change
    }
  }
  
  void deleteMatch(String matchId) {
    _matches.removeWhere((match) => match.id == matchId);
    notifyListeners();
    saveData(); // Auto-save when matches change
  }
  
  Match? getMatchById(String matchId) {
    try {
      return _matches.firstWhere((match) => match.id == matchId);
    } catch (e) {
      return null;
    }
  }
  
  List<Match> getMatchesByType(MatchType type) {
    return _matches.where((match) => match.type == type).toList();
  }
  
  List<Match> getCompletedMatches() {
    return _matches.where((match) => match.isCompleted).toList();
  }
  
  List<Match> getInProgressMatches() {
    return _matches.where((match) => !match.isCompleted).toList();
  }
  
  // Method to clear all matches
  void clearAllMatches() {
    _matches.clear();
    notifyListeners();
    saveData(); // Auto-save when matches change
  }
  
  // Data persistence methods
  Future<void> loadData() async {
    if (_hasLoadedData) return; // Avoid loading multiple times
    
    _isLoading = true;
    notifyListeners();

    try {
      // Load user preferences
      final userPrefs = await StorageService.instance.loadUserPreferences();
      if (userPrefs != null) {
        _userName = userPrefs['userName'] ?? '';
        _userNickname = userPrefs['userNickname'];
        _userLevel = userPrefs['userLevel'] ?? 'Beginner';
        _totalSessions = userPrefs['totalSessions'] ?? 0;
        _totalHours = userPrefs['totalHours'] ?? 0;
        _winRate = userPrefs['winRate'] ?? 0.0;
        _isDarkMode = userPrefs['isDarkMode'] ?? false;
        _notificationsEnabled = userPrefs['notificationsEnabled'] ?? true;
        
        // Load default match format
        final formatName = userPrefs['defaultMatchFormat'] as String?;
        if (formatName != null) {
          _defaultMatchFormat = MatchFormat.values.firstWhere(
            (format) => format.name == formatName,
            orElse: () => MatchFormat.bestOfThree,
          );
        }
      }

      // Load matches
      _matches = await StorageService.instance.loadMatches();
      
      _hasLoadedData = true;
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveData() async {
    try {
      // Save user preferences
      await StorageService.instance.saveUserPreferences(
        userName: _userName,
        userNickname: _userNickname,
        userLevel: _userLevel,
        totalSessions: _totalSessions,
        totalHours: _totalHours,
        winRate: _winRate,
        isDarkMode: _isDarkMode,
        notificationsEnabled: _notificationsEnabled,
        defaultMatchFormat: _defaultMatchFormat,
      );

      // Save matches
      await StorageService.instance.saveMatches(_matches);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<bool> hasExistingData() async {
    return await StorageService.instance.hasData();
  }

  Future<void> clearAllData() async {
    await StorageService.instance.clearAllData();
    resetData();
  }

  // Method to reset all data
  void resetData() {
    _userName = '';
    _userNickname = null;
    _userLevel = 'Beginner';
    _totalSessions = 0;
    _totalHours = 0;
    _winRate = 0.0;
    _isTracking = false;
    _sessionStartTime = null;
    _matches.clear();
    _isDarkMode = false;
    _notificationsEnabled = true;
    _defaultMatchFormat = MatchFormat.bestOfThree;
    _hasLoadedData = false;
    notifyListeners();
  }
}