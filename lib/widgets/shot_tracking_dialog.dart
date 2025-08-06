import 'package:flutter/material.dart';
import '../models/shot_model.dart';

class ShotTrackingDialog extends StatefulWidget {
  final Function(ShotType type, ShotOutcome outcome) onShotRecorded;

  const ShotTrackingDialog({super.key, required this.onShotRecorded});

  @override
  State<ShotTrackingDialog> createState() => _ShotTrackingDialogState();
}

class _ShotTrackingDialogState extends State<ShotTrackingDialog> {
  ShotType? _selectedType;
  ShotOutcome? _selectedOutcome;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: const Text(
        'Record Shot',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Manrope',
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shot type selection
          const Text(
            'Shot Type',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ShotType.values
                    .map(
                      (type) => ChoiceChip(
                        label: Text(
                          type.displayName,
                          style: TextStyle(
                            color:
                                _selectedType == type
                                    ? Colors.white
                                    : Colors.grey,
                          ),
                        ),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                        backgroundColor: const Color(0xFF3C3C3C),
                        selectedColor: const Color(0xFF6B46C1),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),

          // Shot outcome selection
          const Text(
            'Outcome',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ShotOutcome.values
                    .map(
                      (outcome) => ChoiceChip(
                        label: Text(
                          outcome.displayName,
                          style: TextStyle(
                            color:
                                _selectedOutcome == outcome
                                    ? Colors.white
                                    : Colors.grey,
                          ),
                        ),
                        selected: _selectedOutcome == outcome,
                        onSelected: (selected) {
                          setState(() {
                            _selectedOutcome = selected ? outcome : null;
                          });
                        },
                        backgroundColor: const Color(0xFF3C3C3C),
                        selectedColor: _getOutcomeColor(outcome),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed:
              _selectedType != null && _selectedOutcome != null
                  ? () {
                    widget.onShotRecorded(_selectedType!, _selectedOutcome!);
                    Navigator.of(context).pop();
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B46C1),
            disabledBackgroundColor: const Color(0xFF3C3C3C),
          ),
          child: const Text('Record Shot'),
        ),
      ],
    );
  }

  Color _getOutcomeColor(ShotOutcome outcome) {
    switch (outcome) {
      case ShotOutcome.winner:
        return const Color(0xFF4CAF50);
      case ShotOutcome.forcedError:
        return const Color(0xFFFF9800);
      case ShotOutcome.unforcedError:
        return const Color(0xFFE53E3E);
    }
  }
}
