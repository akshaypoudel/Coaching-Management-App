import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/provider/student_provider.dart';
import 'package:stdent_management_system/screens/student_add_screen.dart';
import 'package:stdent_management_system/screens/student_details_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final months = [
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<StudentProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F7FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F9FC), Color(0xFFEEF3FF), Color(0xFFF9F7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                _buildSectionHeader("Overview"),
                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.88,
                  children: [
                    _buildStatCard(
                      title: "Students",
                      value: provider.totalStudents.toString(),
                      subtitle: "Total Students",
                      icon: Icons.groups_rounded,
                      color: Colors.deepPurple,
                    ),

                    _buildStatCard(
                      title: "Fees Due",
                      value: "₹${formatAmount(provider.totalFeesDues)}",
                      subtitle: "Pending Collection",
                      icon: Icons.account_balance_wallet,
                      color: Colors.orange,
                    ),

                    _buildStatCard(
                      title: "Admissions",
                      value: provider.recentAdmissions.length.toString(),
                      subtitle: "Recent Joins",
                      icon: Icons.person_add_alt_1,
                      color: Colors.blue,
                    ),

                    _buildStatCard(
                      title: "Active",
                      value: provider.activeStudents.toString(),
                      subtitle: "Currently Active",
                      icon: Icons.verified_rounded,
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _buildFeesCard(size),
                const SizedBox(height: 20),
                _buildSectionHeader("Recent Admissions"),
                const SizedBox(height: 14),
                ...([...provider.getStudents]
                      ..sort((a, b) => b.joiningDate.compareTo(a.joiningDate)))
                    .map((student) => _recentStudentTile(student))
                    .take(3),
                const SizedBox(height: 20),
                _buildSectionHeader("Quick Actions"),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        title: "Add Student",
                        subtitle: "New admission",
                        icon: Icons.person_add_alt_1_rounded,
                        color: const Color(0xFF6C63FF),
                        onTap: () {
                          Get.to(() => AddStudentScreen());
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        title: "Attendance",
                        subtitle: "Mark daily status",
                        icon: Icons.fact_check_rounded,
                        color: const Color(0xFF22C55E),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatAmount(double amount) {
    if (amount >= 10000000) {
      return "${(amount / 10000000).toStringAsFixed(1)}Cr";
    }

    if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(1)}L";
    }

    if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K";
    }

    return amount.toStringAsFixed(0);
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        // _glassIconButton(
        //   icon: Icons.menu_rounded,
        //   onTap: () => _scaffoldKey.currentState?.openDrawer(),
        // ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Institute",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Student Management",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search students, batches, courses...",
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeesCard(Size size) {
    final provider = Provider.of<StudentProvider>(context);

    return _glassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Fees Collection",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _tag("This Month", light: true),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            "₹${formatAmount(provider.totalFeesPaid)}",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF16A34A),
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                "+18% from last month",
                style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Container(
          //   height: 130,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(20),
          //     gradient: LinearGradient(
          //       colors: [
          //         const Color(0xFF6C63FF).withValues(alpha: 0.10),
          //         const Color(0xFF60A5FA).withValues(alpha: 0.06),
          //       ],
          //     ),
          //   ),
          // child: CustomPaint(
          //   size: Size(size.width, 130),
          //   painter: LinePainter(values: provider.monthlyFeesCollection),
          // ),
          // ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return _glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.75)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentStudentTile(StudentModel student) {
    return GestureDetector(
      onTap: () {
        Get.to(StudentDetailsScreen(student: student));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
              ),
              child: Center(
                child: Text(
                  student.name[0].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
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
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.course,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${months[student.joiningDate.month - 1]} ${student.joiningDate.day}, ${student.joiningDate.year}",
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "New",
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.80)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _tag(String text, {bool light = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: light
            ? const Color(0xFFF1F5F9)
            : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: light
              ? const Color(0xFFE5E7EB)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: light ? const Color(0xFF475569) : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> sendBulkSMS(List<String> phoneNumbers, String message) async {
    try {
      final result = await sendSMS(message: message, recipients: phoneNumbers);
      log('SMS result: $result');
    } catch (error) {
      log('SMS error: $error');
    }
  }
}
