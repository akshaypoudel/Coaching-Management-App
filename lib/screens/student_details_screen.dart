import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stdent_management_system/components/app_currency_formatter.dart';
import 'package:stdent_management_system/components/communication_widget.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/screens/student_add_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final StudentModel student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  bool _showPayments = false;
  final CommunicationMethods communication = CommunicationMethods();

  StudentModel get student => widget.student;

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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8FAFF),
                  Color(0xFFEEF4FF),
                  Color(0xFFF9F5FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Abstract decorative blobs
          Positioned(
            top: -70,
            right: -50,
            child: _blob(190, const Color(0xFF6D5DF6).withValues(alpha: 0.10)),
          ),
          Positioned(
            top: 240,
            left: -80,
            child: _blob(170, const Color(0xFF4F8CFF).withValues(alpha: 0.09)),
          ),
          Positioned(
            bottom: -90,
            right: -60,
            child: _blob(210, const Color(0xFF8B5CF6).withValues(alpha: 0.07)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 18),

                  _buildProfileHero(
                    student: student,
                    isActive: isActive,
                    isFeePaid: isFeePaid,
                  ),

                  const SizedBox(height: 16),

                  _buildQuickActions(),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          title: "Total Fees",
                          value: AppFormatter.formatCurrency(
                            student.totalFees.toInt(),
                          ),
                          subtitle: "Course amount",
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF6D5DF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _metricCard(
                          title: "Paid",
                          value: AppFormatter.formatCurrency(
                            student.feesPaid.toInt(),
                          ),
                          subtitle: "Received",
                          icon: Icons.payments_rounded,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          title: "Due",
                          value: AppFormatter.formatCurrency(
                            student.feesDues.toInt(),
                          ),
                          subtitle: "Remaining",
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFFF8A65),
                        ),
                      ),
                      const SizedBox(width: 12),
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

                  const SizedBox(height: 16),

                  _paymentHistorySection(),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 14),

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

                  const SizedBox(height: 14),

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
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
          child: Text(
            "Student Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        _glassButton(
          icon: Icons.edit_rounded,
          onTap: () {
            Get.to(() => AddStudentScreen(student: student, isEditing: true));
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
    final List<Color> heroGradient = isFeePaid
        ? [const Color(0xFF34D399), const Color(0xFF22C55E)]
        : [const Color(0xFFFFA477), const Color(0xFFFF7A45)];

    final Color glowColor = isFeePaid
        ? const Color(0xFF22C55E)
        : const Color(0xFFFF7A45);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: _blob(110, Colors.white.withValues(alpha: 0.06)),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      _heroTag("Student Profile"),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 92,
                    width: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        student.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    student.course,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _statusChip(
                        text: isActive
                            ? "Active Student"
                            : student.studentStatus.name,
                        color: isActive
                            ? const Color(
                                0xFF22C55E,
                              ) // green = active, matches your app's "positive" color
                            : const Color(
                                0xFFFF8A65,
                              ), // coral = inactive, matches your app's "attention" color
                      ),
                      _statusChip(
                        text: isFeePaid
                            ? "Fees Paid"
                            : 'Fees ${student.feeStatus.name}',
                        color: isFeePaid
                            ? const Color(
                                0xFF22C55E,
                              ) // green = paid, consistent with Active chip above
                            : const Color(
                                0xFFFF8A65,
                              ), // coral = due, consistent with Inactive chip above
                      ),
                      _statusChip(
                        text: '${student.batchTime.name} Batch',
                        color: const Color(
                          0xFF60A5FA,
                        ), // soft blue, neutral info tag — matches your metric card "Batch" icon color
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _heroMiniTile(
                          title: "Roll No",
                          value: student.rollNumber,
                        ),
                      ),
                      const SizedBox(width: 10),
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
            onTap: () {
              communication.makeCall(student, context);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionTile(
            icon: Icons.sms_rounded,
            label: "Message",
            color: const Color(0xFF2563EB),
            onTap: () {
              communication.openSmsDialog(student, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.14),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget feeStatus(String status) {
    final bool pending = status == "Due";
    final Color color = pending
        ? const Color(0xFFFF7A45)
        : const Color(0xFF22C55E);
    final Color bg = pending
        ? const Color(0xFFFFE8DC)
        : const Color(0xFFE8F9EF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  // ---------- Payment history (collapsible) ----------

  Widget _paymentHistorySection() {
    final payments = student.payments;
    final hasPayments = payments.isNotEmpty;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Abstract accent blob tucked behind the header
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16A34A).withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () => setState(() => _showPayments = !_showPayments),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF22C55E), Color(0xFF15803D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF16A34A,
                                ).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Payment History",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasPayments
                                    ? "${payments.length} transaction${payments.length == 1 ? '' : 's'}"
                                    : "No transactions yet",
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _showPayments ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _showPayments
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF3F4F6),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _showPayments
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF6B7280),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                sizeCurve: Curves.easeInOut,
                crossFadeState: _showPayments
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: hasPayments
                      ? Column(
                          children: student.paymentHistory
                              .map((p) => _paymentTile(p))
                              .toList(),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                color: Colors.grey.shade400,
                                size: 26,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "No payments recorded",
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(FeePayment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Abstract gradient accent bar
            Container(
              width: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF4F8CFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF22C55E).withValues(alpha: 0.16),
                            const Color(0xFF16A34A).withValues(alpha: 0.22),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: Color(0xFF16A34A),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppFormatter.formatCurrency(
                                  payment.amount.toInt(),
                                ),
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  payment.paymentMethod.name,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                formatWithOrdinal(payment.paymentDate),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  payment.receivedBy ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (payment.remarks != null &&
                              payment.remarks!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                payment.remarks!,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatWithOrdinal(DateTime date) {
    // 1. Get the day number
    int day = date.day;
    String suffix = 'th';

    // 2. Determine the correct ordinal suffix
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
      }
    }

    // 3. Map the month names manually to avoid heavy package dependencies
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    String monthName = months[date.month - 1];

    // 4. Return the fully assembled string
    return '$day$suffix $monthName, ${date.year}';
  }

  // ---------- Shared building blocks ----------

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: const Color(0xFF6D5DF6), size: 19),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF6D5DF6), size: 19),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13.5,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 7,
            width: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
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
          fontSize: 11,
          shadows: [
            Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
      ),
    );
  }

  Widget _heroMiniTile({required String title, required String value}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
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
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.72),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 46,
              width: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
              ),
              child: Icon(icon, color: const Color(0xFF111827), size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
