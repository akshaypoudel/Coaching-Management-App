import 'package:flutter/material.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunicationMethods {
  void makeCall(StudentModel student, BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: cleanPhone(student.phone));
    final ok = await launchUri(uri);
    if (!ok) showResultSnack(false, 'Call', context);
  }

  void openWhatsAppDialog(StudentModel student, BuildContext context) {
    showPersonalMessageDialog(
      context: context,
      student: student,
      channel: 'WhatsApp',
      accentColor: const Color(0xFF16A34A),
      icon: Icons.chat_bubble_rounded,
      defaultMessage: student.feesDues > 0
          ? 'Hi ${student.name}, this is a reminder that your fee dues are pending. Kindly clear them at the earliest. Thank you!'
          : 'Hi ${student.name}, hope you are doing well!',
      onSend: (msg) async {
        final phone = cleanPhone(student.phone);
        final uri = Uri.parse(
          'https://wa.me/+91$phone?text=${Uri.encodeComponent(msg)}',
        );
        final ok = await launchUri(uri);
        showResultSnack(ok, 'WhatsApp', context);
      },
    );
  }

  void openSmsDialog(StudentModel student, BuildContext context) {
    showPersonalMessageDialog(
      context: context,
      student: student,
      channel: 'SMS',
      accentColor: const Color(0xFF2563EB),
      icon: Icons.sms_rounded,
      defaultMessage: student.feesDues > 0
          ? 'Dear ${student.name}, your fee payment is pending. Please clear it soon.'
          : 'Dear ${student.name}, hope you are doing well.',
      onSend: (msg) async {
        final uri = Uri(
          scheme: 'sms',
          path: cleanPhone(student.phone),
          queryParameters: {'body': msg},
        );
        final ok = await launchUri(uri);
        showResultSnack(ok, 'SMS', context);
      },
    );
  }

  void showPersonalMessageDialog({
    required BuildContext context,
    required StudentModel student,
    required String channel,
    required Color accentColor,
    required IconData icon,
    required String defaultMessage,
    required Future<void> Function(String message) onSend,
  }) {
    final controller = TextEditingController(text: defaultMessage);
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accentColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Send $channel',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'To ${student.name} • ${student.phone}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final msg = controller.text.trim();
                          Navigator.pop(ctx);
                          if (msg.isNotEmpty) onSend(msg);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> launchUri(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  void showResultSnack(bool ok, String channel, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? '$channel opened successfully.' : 'Could not open $channel.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String cleanPhone(String phone) => phone.replaceAll(RegExp(r'[^0-9+]'), '');
}
