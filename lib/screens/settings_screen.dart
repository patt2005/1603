import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../models/match_model.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  
  const SettingsScreen({super.key, this.onBackToHome});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF3C3C3C),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Default Match Format Section
            Row(
              children: [
                const Icon(
                  Icons.sports_tennis,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Default Match Format:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Format buttons
            Row(
              children: [
                _buildFormatButton('Best of 3', MatchFormat.bestOfThree, appProvider),
                const SizedBox(width: 12),
                _buildFormatButton('Best of 5', MatchFormat.bestOfFive, appProvider),
                const SizedBox(width: 12),
                _buildFormatButton('Custom', MatchFormat.custom, appProvider),
              ],
            ),
            const SizedBox(height: 32),
            
            // Clear All Data Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _showClearDataDialog,
                icon: const Icon(
                  Icons.delete_sweep,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Clear All Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Contact Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _openContactEmail,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Contact',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Feedback Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _showFeedbackDialog,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Feedback',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Back Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  }
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormatButton(String label, MatchFormat format, AppProvider appProvider) {
    final isSelected = appProvider.defaultMatchFormat == format;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          appProvider.setDefaultMatchFormat(format);
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFD54F) : const Color(0xFF3C3C3C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFD54F) : const Color(0xFF5C5C5C),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFF9C9C9C),
                fontSize: 14,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Clear All Data',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to clear all match data? This action cannot be undone.',
          style: TextStyle(
            color: Color(0xFF9C9C9C),
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9C9C9C)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _clearAllData();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.clearAllData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All data has been cleared'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _openContactEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@tennisinsights.app',
      query: 'subject=Tennis Insights App - Contact&body=Hello Tennis Insights Team,\n\n',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email app. Please contact support@tennisinsights.app'),
              backgroundColor: Color(0xFFE53E3E),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email app. Please contact support@tennisinsights.app'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    }
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFFFD54F), size: 24),
            const SizedBox(width: 8),
            const Text(
              'Rate Tennis Insights',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enjoying Tennis Insights? Please take a moment to rate us!',
              style: TextStyle(
                color: Color(0xFF9C9C9C),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showThankYouMessage(index + 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star,
                      color: const Color(0xFFFFD54F),
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: Color(0xFF9C9C9C)),
            ),
          ),
        ],
      ),
    );
  }

  void _showThankYouMessage(int rating) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thank you for rating us $rating star${rating != 1 ? 's' : ''}! ⭐',
          style: const TextStyle(fontFamily: 'Roboto'),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}