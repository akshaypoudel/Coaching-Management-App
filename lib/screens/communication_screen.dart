import 'dart:ui';
import 'package:flutter/material.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> students = [
    {
      'name': 'Rahul Sharma',
      'class': 'Class 10',
      'phone': '9876543210',
      'feesPending': true,
    },
    {
      'name': 'Priya Singh',
      'class': 'NEET Batch',
      'phone': '9876543211',
      'feesPending': false,
    },
    {
      'name': 'Aman Verma',
      'class': 'JEE Batch',
      'phone': '9876543212',
      'feesPending': true,
    },
    {
      'name': 'Sneha Gupta',
      'class': 'Class 12',
      'phone': '9876543213',
      'feesPending': false,
    },
  ];

  List<Map<String, dynamic>> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    filteredStudents = students;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterStudents(String query) {
    setState(() {
      filteredStudents = students.where((student) {
        return student['name'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            student['class'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            student['phone'].toString().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = students.where((s) => s['feesPending'] == true).length;

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
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 18),
                // _buildHeroCard(
                //   totalStudents: students.length,
                //   pendingFees: pendingCount,
                // ),
                const SizedBox(height: 20),
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
                      ),
                      const SizedBox(width: 14),
                      _quickActionCard(
                        icon: Icons.payments_rounded,
                        title: 'Fee Reminder',
                        subtitle: 'Notify pending dues',
                        color: const Color(0xFFFF8A65),
                      ),
                      const SizedBox(width: 14),
                      _quickActionCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Exam Notice',
                        subtitle: 'Share schedule fast',
                        color: const Color(0xFF14B8A6),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    Text(
                      '${filteredStudents.length} found',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      return _buildStudentCard(filteredStudents[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Communication',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Connect with students beautifully and quickly',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
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
        onChanged: filterStudents,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search student, class or phone',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF6B7280)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({
    required int totalStudents,
    required int pendingFees,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF8B5CF6), Color(0xFF4F8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DF6).withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _capsuleTag('Live Connect'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.forum_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Reach students faster\nwith smart communication.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _heroStatTile(
                  title: 'Contacts',
                  value: '$totalStudents',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _heroStatTile(title: 'Fees Due', value: '$pendingFees'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
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
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
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
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final bool feesPending = student['feesPending'] == true;
    final Color avatarColor = feesPending
        ? const Color(0xFFFF8A65)
        : const Color(0xFF6D5DF6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          avatarColor,
                          avatarColor.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        student['name'][0],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student['class'],
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          student['phone'],
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(feesPending),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.chat_bubble_rounded,
                      label: 'WhatsApp',
                      color: const Color(0xFF16A34A),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.sms_rounded,
                      label: 'SMS',
                      color: const Color(0xFF2563EB),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.call_rounded,
                      label: 'Call',
                      color: const Color(0xFF7C3AED),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  Widget _statusChip(bool feesPending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: feesPending ? const Color(0xFFFFF1E8) : const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        feesPending ? 'Fees Due' : 'Active',
        style: TextStyle(
          color: feesPending
              ? const Color(0xFFEA580C)
              : const Color(0xFF15803D),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _capsuleTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _heroStatTile({required String title, required String value}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
