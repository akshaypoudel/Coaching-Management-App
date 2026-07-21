import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stdent_management_system/components/communication_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stdent_management_system/components/pagination_helper.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/provider/student_provider.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CommunicationMethods communication = CommunicationMethods();
  String _searchQuery = "";
  String _selectedFeeFilter = "All";
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetToFirstPage() {
    setState(() => _currentPage = 0);
  }

  List<StudentModel> _applyFilters(List<StudentModel> students) {
    var result = students;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.course.toLowerCase().contains(q) ||
            s.phone.contains(q);
      }).toList();
    }

    if (_selectedFeeFilter == "Due") {
      result = result.where((s) => s.feesDues > 0).toList();
    } else if (_selectedFeeFilter == "Cleared") {
      result = result.where((s) => s.feesDues <= 0).toList();
    }

    return result;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _FeeFilterSheet(
          initialValue: _selectedFeeFilter,
          onApply: (value) {
            setState(() => _selectedFeeFilter = value);
            _resetToFirstPage();
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // LAUNCH HELPERS (WhatsApp / SMS / Call)
  // ---------------------------------------------------------------------

  // ---------------------------------------------------------------------
  // BROADCAST COMPOSER (Announcement / Fee Reminder / Exam Notice)
  // ---------------------------------------------------------------------

  void _showBroadcastComposer(String type) {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final students = provider.getStudents;

    late String title;
    late String template;
    late List<StudentModel> targets;
    late Color accentColor;

    switch (type) {
      case 'fee_reminder':
        title = 'Fee Reminder';
        accentColor = const Color(0xFFFF8A65);
        template =
            'Dear Parent,\n\nThis is a gentle reminder that the fee payment for your ward is currently pending. Kindly clear the dues at the earliest to avoid any inconvenience.\n\nThank you.';
        targets = students.where((s) => s.feesDues > 0).toList();
        break;
      case 'exam_notice':
        title = 'Exam Notice';
        accentColor = const Color(0xFF14B8A6);
        template =
            'Dear Student,\n\nThis is to notify you that the examination schedule has been released. Please check the notice board / student portal for detailed timing and syllabus.\n\nAll the best!';
        targets = students;
        break;
      case 'announcement':
      default:
        title = 'Announcement';
        accentColor = const Color(0xFF6D5DF6);
        template =
            'Dear Parents/Students,\n\nWe would like to inform you about an important update. Please stay tuned for further details.\n\nRegards,\nSchool Administration';
        targets = students;
        break;
    }

    final controller = TextEditingController(text: template);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _MessageComposerSheet(
          title: title,
          accentColor: accentColor,
          controller: controller,
          recipientCount: targets.length,
          onSend: (message) => _broadcastMessage(message, targets),
        );
      },
    );
  }

  Future<void> _broadcastMessage(
    String message,
    List<StudentModel> targets,
  ) async {
    if (targets.isEmpty) {
      communication.showResultSnack(
        false,
        'Broadcast (no matching students)',
        context,
      );
      return;
    }
    // Note: opening a single SMS composer pre-loaded with every number is
    // supported on most Android devices (comma-separated recipients) but not
    // guaranteed on iOS. For guaranteed delivery at scale, wire this up to a
    // backend SMS/WhatsApp gateway (e.g. Twilio) instead of the device app.
    // final numbers = targets.map((s) => _cleanPhone(s.phone)).join(',');
    // final uri = Uri(
    //   scheme: 'sms',
    //   path: numbers,
    //   queryParameters: {'body': message},
    // );
    // final launched = await _launchUri(uri);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          // launched
          'Opening SMS app for ${targets.length} recipient(s)...',
          // : 'Could not open messaging app.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final allStudents = provider.getStudents;

    final filtered = _applyFilters(allStudents);
    final pendingCount = allStudents.where((s) => s.feesDues > 0).length;

    final paginator = Paginator<StudentModel>(
      items: filtered,
      itemsPerPage: _itemsPerPage,
      currentPage: _currentPage,
    );
    _currentPage = paginator.currentPage;
    final pageItems = paginator.pageItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF4FF), Color(0xFFF9F5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(allStudents.length, pendingCount),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Quick Broadcast"),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 138,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _quickActionCard(
                                icon: Icons.campaign_rounded,
                                title: 'Announcement',
                                subtitle: 'Send updates to all',
                                color: const Color(0xFF6D5DF6),
                                onTap: () =>
                                    _showBroadcastComposer('announcement'),
                              ),
                              const SizedBox(width: 14),
                              _quickActionCard(
                                icon: Icons.payments_rounded,
                                title: 'Fee Reminder',
                                subtitle: 'Notify pending dues',
                                color: const Color(0xFFFF8A65),
                                onTap: () =>
                                    _showBroadcastComposer('fee_reminder'),
                              ),
                              const SizedBox(width: 14),
                              _quickActionCard(
                                icon: Icons.menu_book_rounded,
                                title: 'Exam Notice',
                                subtitle: 'Share schedule fast',
                                color: const Color(0xFF14B8A6),
                                onTap: () =>
                                    _showBroadcastComposer('exam_notice'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Student Contacts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            Text(
                              filtered.length == allStudents.length
                                  ? '${filtered.length} found'
                                  : '${filtered.length} of ${allStudents.length}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (pageItems.isEmpty)
                          _emptyState()
                        else
                          ...pageItems.map((s) => _buildStudentCard(s)),
                        if (filtered.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          PaginationBar(
                            currentPage: paginator.currentPage,
                            totalPages: paginator.totalPages,
                            startIndex: paginator.startIndex,
                            endIndex: paginator.endIndex,
                            totalCount: filtered.length,
                            onFirst: () => setState(() => _currentPage = 0),
                            onPrevious: () => setState(() => _currentPage--),
                            onNext: () => setState(() => _currentPage++),
                            onLast: () => setState(
                              () => _currentPage = paginator.totalPages - 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            const Text(
              "No contacts match your filters",
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int totalCount, int pendingCount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Communication',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D5DF6).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$totalCount",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6D5DF6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                pendingCount > 0
                    ? "$pendingCount students with pending fees"
                    : "Connect with students beautifully and quickly",
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _iconSurface(
          Icons.tune_rounded,
          onTap: _showFilterSheet,
          showBadge: _selectedFeeFilter != "All",
        ),
      ],
    );
  }

  Widget _iconSurface(
    IconData icon, {
    VoidCallback? onTap,
    bool showBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF374151)),
          ),
          if (showBadge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF6D5DF6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _resetToFirstPage();
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search student, course or phone',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = "");
                    _resetToFirstPage();
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.82)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- VIBRANT STUDENT CARD --------------------

  Widget _buildStudentCard(StudentModel student) {
    final bool feesPending = student.feesDues > 0;

    // Vibrant multi-stop gradient per status, instead of a flat tint.
    final List<Color> cardGradient = feesPending
        ? [const Color(0xFFFFF3EC), const Color(0xFFFFE8DC)]
        : [const Color(0xFFF1FBF5), const Color(0xFFE8F9EF)];

    final Color accentColor = feesPending
        ? const Color(0xFFFF7A45)
        : const Color(0xFF22C55E);

    final List<Color> avatarGradient = feesPending
        ? [const Color(0xFFFF8A65), const Color(0xFFFF5E62)]
        : [const Color(0xFF6D5DF6), const Color(0xFF22C1C3)];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentColor.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left accent strip
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: avatarGradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: cardGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: avatarGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: avatarGradient.first.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  student.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    student.course,
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    student.phone,
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _statusChip(feesPending),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _actionButton(
                                icon: const FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                label: 'WhatsApp',
                                color: const Color(0xFF16A34A),
                                onTap: () => communication.openWhatsAppDialog(
                                  student,
                                  context,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _actionButton(
                                icon: const FaIcon(
                                  FontAwesomeIcons.message,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                label: 'SMS',
                                color: const Color(0xFF2563EB),
                                onTap: () => communication.openSmsDialog(
                                  student,
                                  context,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _actionButton(
                                icon: const FaIcon(
                                  FontAwesomeIcons.phone,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                label: 'Call',
                                color: const Color(0xFF7C3AED),
                                onTap: () =>
                                    communication.makeCall(student, context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required Widget icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withOpacity(0.15),
      highlightColor: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Material(
                color: color,
                shape: const CircleBorder(),
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: IconTheme(
                      data: const IconThemeData(color: Colors.white, size: 22),
                      child: icon,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(bool feesPending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: feesPending
              ? [const Color(0xFFFF8A65), const Color(0xFFFF5E62)]
              : [const Color(0xFF34D399), const Color(0xFF22C1C3)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                (feesPending
                        ? const Color(0xFFFF5E62)
                        : const Color(0xFF22C1C3))
                    .withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        feesPending ? 'Fees Due' : 'Cleared',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// BROADCAST MESSAGE COMPOSER SHEET
// ---------------------------------------------------------------------

class _MessageComposerSheet extends StatelessWidget {
  final String title;
  final Color accentColor;
  final TextEditingController controller;
  final int recipientCount;
  final void Function(String message) onSend;

  const _MessageComposerSheet({
    required this.title,
    required this.accentColor,
    required this.controller,
    required this.recipientCount,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Sending to $recipientCount recipient(s)',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: recipientCount == 0
                    ? null
                    : () {
                        final msg = controller.text.trim();
                        Navigator.pop(context);
                        if (msg.isNotEmpty) onSend(msg);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Send Broadcast',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// FEE FILTER SHEET (unchanged)
// ---------------------------------------------------------------------

class _FeeFilterSheet extends StatefulWidget {
  final String initialValue;
  final void Function(String value) onApply;

  const _FeeFilterSheet({required this.initialValue, required this.onApply});

  @override
  State<_FeeFilterSheet> createState() => _FeeFilterSheetState();
}

class _FeeFilterSheetState extends State<_FeeFilterSheet> {
  late String selected = widget.initialValue;

  static const options = ["All", "Due", "Cleared"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Filter Contacts",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          const Text(
            "Fee Status",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((f) {
              final isSelected = f == selected;
              return ChoiceChip(
                label: Text(f == "All" ? "All Status" : f),
                selected: isSelected,
                onSelected: (_) => setState(() => selected = f),
                selectedColor: const Color(0xFF6D5DF6),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                backgroundColor: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(selected);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D5DF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Apply Filter",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
