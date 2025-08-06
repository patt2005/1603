import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title row
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: _getTextColor(),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Value
            Text(
              value,
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 28,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTextColor() {
    // Return appropriate text color based on background
    if (backgroundColor == const Color(0xFF4CAF50) || // Green
        backgroundColor == const Color(0xFFB71C1C)) { // Dark red
      return Colors.white;
    }
    return Colors.black;
  }
}

class StatsCardsRow extends StatelessWidget {
  final double firstServePercentage;
  final int aces;
  final double faultsPercentage;

  const StatsCardsRow({
    super.key,
    required this.firstServePercentage,
    required this.aces,
    required this.faultsPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // 1st Serve In %
          StatsCard(
            title: '1st Serve In %',
            value: '${firstServePercentage.toInt()}%',
            icon: Icons.gps_fixed,
            backgroundColor: const Color(0xFF4CAF50), // Green
            iconColor: Colors.white,
          ),
          
          // Aces
          StatsCard(
            title: 'Aces',
            value: aces.toString(),
            icon: Icons.star,
            backgroundColor: const Color(0xFFFFD54F), // Yellow
            iconColor: Colors.orange,
          ),
          
          // Double Faults %
          StatsCard(
            title: 'Double Faults %',
            value: '${faultsPercentage.toInt()}%',
            icon: Icons.error,
            backgroundColor: const Color(0xFFB71C1C), // Dark red
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }
}