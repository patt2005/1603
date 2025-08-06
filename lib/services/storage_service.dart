import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/match_model.dart';

class StorageService {
  static const String _userPrefsFileName = 'user_prefs.json';
  static const String _matchesFileName = 'matches.json';
  
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _userPrefsFile async {
    final path = await _localPath;
    return File('$path/$_userPrefsFileName');
  }

  Future<File> get _matchesFile async {
    final path = await _localPath;
    return File('$path/$_matchesFileName');
  }

  Future<void> saveUserPreferences({
    required String userName,
    String? userNickname,
    required String userLevel,
    required int totalSessions,
    required int totalHours,
    required double winRate,
    required bool isDarkMode,
    required bool notificationsEnabled,
    required MatchFormat defaultMatchFormat,
  }) async {
    try {
      final file = await _userPrefsFile;
      final userPrefs = {
        'userName': userName,
        'userNickname': userNickname,
        'userLevel': userLevel,
        'totalSessions': totalSessions,
        'totalHours': totalHours,
        'winRate': winRate,
        'isDarkMode': isDarkMode,
        'notificationsEnabled': notificationsEnabled,
        'defaultMatchFormat': defaultMatchFormat.name,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(userPrefs));
    } catch (e) {
      print('Error saving user preferences: $e');
    }
  }

  Future<Map<String, dynamic>?> loadUserPreferences() async {
    try {
      final file = await _userPrefsFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        return json.decode(contents) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading user preferences: $e');
    }
    return null;
  }

  Future<void> saveMatches(List<Match> matches) async {
    try {
      final file = await _matchesFile;
      final matchesJson = {
        'matches': matches.map((match) => match.toJson()).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(matchesJson));
    } catch (e) {
      print('Error saving matches: $e');
    }
  }

  Future<List<Match>> loadMatches() async {
    try {
      final file = await _matchesFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = json.decode(contents) as Map<String, dynamic>;
        final matchesData = data['matches'] as List<dynamic>;
        
        return matchesData
            .map((matchJson) => Match.fromJson(matchJson as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading matches: $e');
    }
    return [];
  }

  Future<void> clearAllData() async {
    try {
      final userPrefsFile = await _userPrefsFile;
      final matchesFile = await _matchesFile;
      
      if (await userPrefsFile.exists()) {
        await userPrefsFile.delete();
      }
      
      if (await matchesFile.exists()) {
        await matchesFile.delete();
      }
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  Future<bool> hasData() async {
    try {
      final userPrefsFile = await _userPrefsFile;
      final matchesFile = await _matchesFile;
      
      return await userPrefsFile.exists() || await matchesFile.exists();
    } catch (e) {
      print('Error checking for existing data: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getAppStats() async {
    try {
      final userPrefs = await loadUserPreferences();
      final matches = await loadMatches();
      
      return {
        'hasUserData': userPrefs != null,
        'totalMatches': matches.length,
        'completedMatches': matches.where((m) => m.isCompleted).length,
        'inProgressMatches': matches.where((m) => !m.isCompleted).length,
        'totalSessions': userPrefs?['totalSessions'] ?? 0,
        'totalHours': userPrefs?['totalHours'] ?? 0,
        'lastUpdated': userPrefs?['lastUpdated'],
      };
    } catch (e) {
      print('Error getting app stats: $e');
      return {};
    }
  }
}