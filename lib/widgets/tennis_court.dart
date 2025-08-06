import 'package:flutter/material.dart';

enum CourtSectionType { fault, ace, footFault, successful, selected }

class TennisCourt extends StatefulWidget {
  final Function(String)? onSectionTap;
  final Map<String, CourtSectionType> sectionStates;
  final String? selectedSection;

  const TennisCourt({
    super.key,
    this.onSectionTap,
    this.sectionStates = const {},
    this.selectedSection,
  });

  @override
  State<TennisCourt> createState() => _TennisCourtState();
}

class _TennisCourtState extends State<TennisCourt> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1.2, // More rectangular like a real tennis court
        child: Stack(
          children: [
            // Tennis court layout
            CustomPaint(size: Size.infinite, painter: TennisCourtPainter()),

            // Clickable sections
            _buildCourtSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtSections() {
    return Column(
      children: [
        // Top baseline area - 3 sections
        Expanded(
          flex: 2,
          child: Row(
            children: [
              _buildSection('top-left-baseline', flex: 1),
              _buildSection('top-center-baseline', flex: 1),
              _buildSection('top-right-baseline', flex: 1),
            ],
          ),
        ),

        // Top service boxes - 4 sections
        Expanded(
          flex: 1,
          child: Row(
            children: [
              _buildSection('top-left-service', flex: 1),
              _buildSection('top-center-left-service', flex: 1),
              _buildSection('top-center-right-service', flex: 1),
              _buildSection('top-right-service', flex: 1),
            ],
          ),
        ),

        // Net area - very thin
        Container(
          height: 3,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 1),
        ),

        // Bottom service boxes - 4 sections
        Expanded(
          flex: 1,
          child: Row(
            children: [
              _buildSection('bottom-left-service', flex: 1),
              _buildSection('bottom-center-left-service', flex: 1),
              _buildSection('bottom-center-right-service', flex: 1),
              _buildSection('bottom-right-service', flex: 1),
            ],
          ),
        ),

        // Bottom baseline area - 3 sections
        Expanded(
          flex: 2,
          child: Row(
            children: [
              _buildSection('bottom-left-baseline', flex: 1),
              _buildSection('bottom-center-baseline', flex: 1),
              _buildSection('bottom-right-baseline', flex: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String sectionId, {int flex = 1}) {
    final bool isSelected = widget.selectedSection == sectionId;
    final CourtSectionType? sectionType = widget.sectionStates[sectionId];

    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          if (widget.onSectionTap != null) {
            widget.onSectionTap!(sectionId);
          }
        },
        child: Container(
          margin: const EdgeInsets.all(0.5),
          decoration: BoxDecoration(
            color: _getSectionColor(sectionType, isSelected),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child:
                isSelected
                    ? const Icon(
                      Icons.radio_button_checked,
                      color: Colors.white,
                      size: 20,
                    )
                    : sectionType != null
                    ? Icon(
                      _getSectionIcon(sectionType),
                      color: Colors.white,
                      size: 16,
                    )
                    : null,
          ),
        ),
      ),
    );
  }

  Color _getSectionColor(CourtSectionType? type, bool isSelected) {
    if (isSelected) {
      return const Color(
        0xFF6C5CE7,
      ).withValues(alpha: 0.8); // Purple like in the image
    }

    switch (type) {
      case CourtSectionType.fault:
      case CourtSectionType.footFault:
        return const Color(0xFFE74C3C).withValues(alpha: 0.7); // Red for faults
      case CourtSectionType.ace:
        return const Color(0xFFFFD700).withValues(alpha: 0.7); // Gold for ace
      case CourtSectionType.successful:
        return const Color(
          0xFF00D2FF,
        ).withValues(alpha: 0.7); // Blue for successful
      default:
        return Colors.transparent;
    }
  }

  IconData _getSectionIcon(CourtSectionType type) {
    switch (type) {
      case CourtSectionType.fault:
        return Icons.close;
      case CourtSectionType.ace:
        return Icons.star;
      case CourtSectionType.footFault:
        return Icons.warning;
      case CourtSectionType.successful:
        return Icons.check;
      default:
        return Icons.circle;
    }
  }
}

class TennisCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // Outer court boundaries
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    // Service line (horizontal) - dividing service area from baseline
    final serviceLineY = height * 0.33; // Service line position
    canvas.drawLine(
      Offset(0, serviceLineY),
      Offset(width, serviceLineY),
      paint,
    );

    // Service line bottom
    final serviceLineBottomY = height * 0.67;
    canvas.drawLine(
      Offset(0, serviceLineBottomY),
      Offset(width, serviceLineBottomY),
      paint,
    );

    // Net line (center horizontal)
    canvas.drawLine(
      Offset(0, height * 0.5),
      Offset(width, height * 0.5),
      paint,
    );

    // Center service line (vertical) - divides left and right service boxes
    canvas.drawLine(
      Offset(width * 0.5, serviceLineY),
      Offset(width * 0.5, serviceLineBottomY),
      paint,
    );

    // Baseline divider lines (vertical)
    // Top baseline divisions
    canvas.drawLine(
      Offset(width * 0.33, 0),
      Offset(width * 0.33, serviceLineY),
      paint,
    );

    canvas.drawLine(
      Offset(width * 0.67, 0),
      Offset(width * 0.67, serviceLineY),
      paint,
    );

    // Bottom baseline divisions
    canvas.drawLine(
      Offset(width * 0.33, serviceLineBottomY),
      Offset(width * 0.33, height),
      paint,
    );

    canvas.drawLine(
      Offset(width * 0.67, serviceLineBottomY),
      Offset(width * 0.67, height),
      paint,
    );

    // Service box vertical divisions
    canvas.drawLine(
      Offset(width * 0.25, serviceLineY),
      Offset(width * 0.25, serviceLineBottomY),
      paint,
    );

    canvas.drawLine(
      Offset(width * 0.75, serviceLineY),
      Offset(width * 0.75, serviceLineBottomY),
      paint,
    );

    // Corner circles
    final circlePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    final circleRadius = 8.0;

    // Bottom left circle
    canvas.drawCircle(
      Offset(circleRadius, height - circleRadius),
      circleRadius,
      circlePaint,
    );

    // Bottom right circle
    canvas.drawCircle(
      Offset(width - circleRadius, height - circleRadius),
      circleRadius,
      circlePaint,
    );

    // Top left circle
    canvas.drawCircle(
      Offset(circleRadius, circleRadius),
      circleRadius,
      circlePaint,
    );

    // Top right circle
    canvas.drawCircle(
      Offset(width - circleRadius, circleRadius),
      circleRadius,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
