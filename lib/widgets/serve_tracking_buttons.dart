import 'package:flutter/material.dart';

enum ServeType { first, second }
enum ServeResult { fault, ace, footFault, successful }

class ServeTrackingButtons extends StatelessWidget {
  final ServeType selectedServeType;
  final ServeResult? selectedResult;
  final Function(ServeType) onServeTypeChanged;
  final Function(ServeResult) onResultSelected;
  final VoidCallback onUndo;
  final VoidCallback onNext;
  final bool actionTaken;
  final bool pointCompleted;

  const ServeTrackingButtons({
    super.key,
    required this.selectedServeType,
    this.selectedResult,
    required this.onServeTypeChanged,
    required this.onResultSelected,
    required this.onUndo,
    required this.onNext,
    this.actionTaken = false,
    this.pointCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Serve type buttons (1st Serve, 2nd Serve)
          Row(
            children: [
              Expanded(
                child: _buildServeTypeButton(
                  '1st Serve',
                  ServeType.first,
                  selectedServeType == ServeType.first,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServeTypeButton(
                  '2nd Serve',
                  ServeType.second,
                  selectedServeType == ServeType.second,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Action buttons (Fault, Ace, Foot Fault)
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  '🔴 Fault',
                  ServeResult.fault,
                  const Color(0xFF8B4513), // Brown
                  selectedResult == ServeResult.fault,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  '✅ Ace',
                  ServeResult.ace,
                  const Color(0xFFFFD54F), // Yellow
                  selectedResult == ServeResult.ace,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  '❌ Foot Fault',
                  ServeResult.footFault,
                  const Color(0xFF8B4513), // Brown
                  selectedResult == ServeResult.footFault,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Control buttons (Undo, Next)
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  '↶ Undo',
                  Colors.grey[700]!,
                  onUndo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildControlButton(
                  'Next →',
                  Colors.white,
                  onNext,
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServeTypeButton(String text, ServeType type, bool isSelected) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () => onServeTypeChanged(type),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected 
              ? const Color(0xFF4CAF50) 
              : const Color(0xFF5C5C5C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: isSelected ? 4 : 1,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, ServeResult result, Color color, bool isSelected, {bool enabled = true}) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: enabled ? () => onResultSelected(result) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? (isSelected ? color : const Color(0xFF5C5C5C)) : const Color(0xFF3C3C3C),
          foregroundColor: enabled ? Colors.white : const Color(0xFF7C7C7C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: isSelected ? 4 : 1,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Roboto',
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildControlButton(String text, Color color, VoidCallback onPressed, {Color? textColor}) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}

class ServeData {
  final String sectionId;
  final ServeType serveType;
  final ServeResult result;
  final DateTime timestamp;

  ServeData({
    required this.sectionId,
    required this.serveType,
    required this.result,
    required this.timestamp,
  });
}