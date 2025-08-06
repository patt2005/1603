import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/match_model.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerNameController = TextEditingController();
  final _opponentNameController = TextEditingController();
  
  MatchFormat _selectedFormat = MatchFormat.bestOfThree;
  MatchType _selectedType = MatchType.friendly;
  int? _customSets;

  @override
  void initState() {
    super.initState();
    // Pre-fill player name and default format from app provider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (appProvider.userNickname != null && appProvider.userNickname!.isNotEmpty) {
      _playerNameController.text = appProvider.userNickname!;
    }
    // Set default match format from user preferences
    _selectedFormat = appProvider.defaultMatchFormat;
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _opponentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text(
          'Match Setup Screen',
          style: TextStyle(
            color: Color(0xFF9C9C9C),
            fontSize: 16,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3C3C3C),
                    ),
                    child: const Text(
                      'Match Setup',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Player name field
                  _buildTextField(
                    controller: _playerNameController,
                    hintText: 'Player name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter player name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Opponent name field
                  _buildTextField(
                    controller: _opponentNameController,
                    hintText: 'Opponent\'s name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter opponent\'s name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Match format dropdown
                  _buildDropdown<MatchFormat>(
                    value: _selectedFormat,
                    hintText: 'Match format',
                    items: MatchFormat.values,
                    itemBuilder: (format) => format.displayName,
                    onChanged: (format) {
                      setState(() {
                        _selectedFormat = format!;
                        if (format != MatchFormat.custom) {
                          _customSets = null;
                        }
                      });
                    },
                  ),
                  
                  // Custom sets input (only show if custom format selected)
                  if (_selectedFormat == MatchFormat.custom) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      hintText: 'Number of sets',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter number of sets';
                        }
                        final sets = int.tryParse(value.trim());
                        if (sets == null || sets < 1 || sets > 7) {
                          return 'Please enter a valid number (1-7)';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _customSets = int.tryParse(value.trim());
                      },
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Match type dropdown
                  _buildDropdown<MatchType>(
                    value: _selectedType,
                    hintText: 'Match type',
                    items: MatchType.values,
                    itemBuilder: (type) => type.displayName,
                    onChanged: (type) {
                      setState(() {
                        _selectedType = type!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Back button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C3C3C),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF5C5C5C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Start Match button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _startMatch,
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: const Text(
                        'Start Match',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4C4C4C)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Roboto',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9C9C9C),
            fontSize: 16,
            fontFamily: 'Roboto',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String hintText,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4C4C4C)),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9C9C9C),
            fontSize: 16,
            fontFamily: 'Roboto',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Roboto',
        ),
        dropdownColor: const Color(0xFF2C2C2C),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF9C9C9C),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemBuilder(item),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _startMatch() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFormat == MatchFormat.custom && (_customSets == null || _customSets! < 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of sets for custom format'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
      return;
    }

    // Create new match
    final match = Match(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerName: _playerNameController.text.trim(),
      opponentName: _opponentNameController.text.trim(),
      format: _selectedFormat,
      type: _selectedType,
      customSets: _selectedFormat == MatchFormat.custom ? _customSets : null,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      result: MatchResult.inProgress,
      sets: [],
    );

    // Add match to app provider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.addMatch(match);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Match started: ${match.playerName} vs ${match.opponentName}'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );

    // Navigate back
    Navigator.of(context).pop();
  }
}