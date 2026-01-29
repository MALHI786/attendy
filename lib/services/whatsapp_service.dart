import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  /// Opens WhatsApp with a pre-filled message containing absentee roll numbers
  /// [phoneNumber] - Optional phone number with country code (e.g., +919876543210)
  /// [message] - The message to send
  Future<bool> shareToWhatsApp({
    String? phoneNumber,
    required String message,
  }) async {
    try {
      Uri whatsappUri;
      
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Remove any spaces, dashes, or special characters from phone number
        final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
        // Open WhatsApp with specific number
        whatsappUri = Uri.parse(
          'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}',
        );
      } else {
        // Open WhatsApp without specific number (user can choose)
        whatsappUri = Uri.parse(
          'whatsapp://send?text=${Uri.encodeComponent(message)}',
        );
      }

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Try alternative URL scheme for WhatsApp
        final altUri = Uri.parse(
          'https://api.whatsapp.com/send?text=${Uri.encodeComponent(message)}',
        );
        if (await canLaunchUrl(altUri)) {
          await launchUrl(altUri, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      }
    } catch (e) {
      print('❌ Error opening WhatsApp: $e');
      return false;
    }
  }

  /// Formats absentee list for WhatsApp message
  String formatAbsenteeMessage({
    required String subjectName,
    required DateTime date,
    required List<String> absenteeRollNumbers,
    String? customHeader,
  }) {
    final dateStr = '${date.day}/${date.month}/${date.year}';
    
    final buffer = StringBuffer();
    
    if (customHeader != null && customHeader.isNotEmpty) {
      buffer.writeln(customHeader);
      buffer.writeln();
    } else {
      buffer.writeln('📋 *Attendance Report*');
      buffer.writeln();
    }
    
    buffer.writeln('📚 *Subject:* $subjectName');
    buffer.writeln('📅 *Date:* $dateStr');
    buffer.writeln();
    
    if (absenteeRollNumbers.isEmpty) {
      buffer.writeln('✅ *All students present!*');
    } else {
      buffer.writeln('❌ *Absent Students (${absenteeRollNumbers.length}):*');
      buffer.writeln();
      
      // Format roll numbers nicely
      for (int i = 0; i < absenteeRollNumbers.length; i++) {
        buffer.writeln('${i + 1}. ${absenteeRollNumbers[i]}');
      }
      
      buffer.writeln();
      buffer.writeln('_Total Absent: ${absenteeRollNumbers.length}_');
    }
    
    buffer.writeln();
    buffer.writeln('_Sent via Attendy App_');
    
    return buffer.toString();
  }
}
