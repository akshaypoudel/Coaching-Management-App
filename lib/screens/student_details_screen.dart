import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/screens/student_add_screen.dart';

class StudentDetailsScreen extends StatelessWidget {
  final StudentModel student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final months = const [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    String formatDate(DateTime date) {
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    }

    final bool isFeePaid = student.feeStatus == FeesStatus.Paid;
    final bool isActive = student.studentStatus == StudentStatus.Active;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            child: Column(
              children: [
                _buildTopBar(context),
                const SizedBox(height: 20),

                _buildProfileHero(
                  student: student,
                  isActive: isActive,
                  isFeePaid: isFeePaid,
                ),

                const SizedBox(height: 18),

                _buildQuickActions(),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        title: "Total Fees",
                        value: "₹${student.totalFees.toInt()}",
                        subtitle: "Course amount",
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color(0xFF6D5DF6),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _metricCard(
                        title: "Paid",
                        value: "₹${student.feesPaid.toInt()}",
                        subtitle: "Received",
                        icon: Icons.payments_rounded,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        title: "Due",
                        value: "₹${student.feesDues.toInt()}",
                        subtitle: "Remaining",
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFFF8A65),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _metricCard(
                        title: "Batch",
                        value: student.batchTime.name,
                        subtitle: "Class timing",
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _sectionCard(
                  title: "Contact Information",
                  icon: Icons.contact_page_outlined,
                  child: Column(
                    children: [
                      _infoTile(
                        icon: Icons.call_outlined,
                        title: "Phone",
                        value: student.phone,
                      ),
                      _infoTile(
                        icon: Icons.phone_android_rounded,
                        title: "Parent Phone",
                        value: student.parentsPhone,
                      ),
                      _infoTile(
                        icon: Icons.email_outlined,
                        title: "Email",
                        value: student.email ?? '',
                      ),
                      _infoTile(
                        icon: Icons.location_on_outlined,
                        title: "Address",
                        value: student.address,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _sectionCard(
                  title: "Academic Information",
                  icon: Icons.school_outlined,
                  child: Column(
                    children: [
                      _infoTile(
                        icon: Icons.badge_outlined,
                        title: "Roll Number",
                        value: student.rollNumber,
                      ),
                      _infoTile(
                        icon: Icons.menu_book_outlined,
                        title: "Course",
                        value: student.course,
                      ),
                      _infoTile(
                        icon: Icons.person_outline_rounded,
                        title: "Father Name",
                        value: student.fatherName,
                      ),
                      _infoTile(
                        icon: Icons.wc_rounded,
                        title: "Gender",
                        value: student.gender.name,
                      ),
                      _infoTile(
                        icon: Icons.calendar_month_rounded,
                        title: "Joining Date",
                        value: formatDate(student.joiningDate),
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _sectionCard(
                  title: "Personal Information",
                  icon: Icons.perm_identity_outlined,
                  child: Column(
                    children: [
                      _infoTile(
                        icon: Icons.cake_outlined,
                        title: "Date of Birth",
                        value: formatDate(student.dob),
                      ),
                      _infoTile(
                        icon: Icons.verified_user_outlined,
                        title: "Student Status",
                        value: student.studentStatus.name,
                      ),
                      _infoTile(
                        icon: Icons.receipt_long_outlined,
                        title: "Fee Status",
                        value: student.feeStatus.name,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        _glassButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Student Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        _glassButton(
          icon: Icons.edit_rounded,
          onTap: () {
            Get.to(() => AddStudentScreen(student: student));
          },
        ),
      ],
    );
  }

  Widget _buildProfileHero({
    required StudentModel student,
    required bool isActive,
    required bool isFeePaid,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              colors: [Color(0xFF6D5DF6), Color(0xFF8B5CF6), Color(0xFF4F8CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6D5DF6).withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _heroTag("Student Profile"),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 104,
                width: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    student.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                student.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                student.course,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.84),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _statusChip(
                    text: isActive
                        ? "Active Student"
                        : student.studentStatus.name,
                    color: isActive
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFFF8A65),
                  ),
                  _statusChip(
                    text: isFeePaid
                        ? "Fees Paid"
                        : 'Fees ${student.feeStatus.name}',
                    color: isFeePaid
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFFFA726),
                  ),
                  _statusChip(
                    text: '${student.batchTime} Batch',
                    color: const Color(0xFF60A5FA),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _heroMiniTile(
                      title: "Roll No",
                      value: student.rollNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _heroMiniTile(
                      title: "Parent",
                      value: student.fatherName,
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

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionTile(
            icon: Icons.call_rounded,
            label: "Call",
            color: const Color(0xFF16A34A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionTile(
            icon: Icons.sms_rounded,
            label: "Message",
            color: const Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF6D5DF6)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF6D5DF6), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              borderRadius: BorderRadius.circular(16),
              color: color.withOpacity(0.12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _heroTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
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

  Widget _heroMiniTile({required String title, required String value}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.72),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 52,
              width: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white),
              ),
              child: Icon(icon, color: const Color(0xFF111827)),
            ),
          ),
        ),
      ),
    );
  }
}
