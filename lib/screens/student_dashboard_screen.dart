import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:stdent_management_system/components/app_currency_formatter.dart';
import 'package:stdent_management_system/components/custom_drawer.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/provider/student_provider.dart';
import 'package:stdent_management_system/screens/student_add_screen.dart';
import 'package:stdent_management_system/screens/student_details_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final VoidCallback onDrawerOpened;
  const StudentDashboardScreen({super.key, required this.onDrawerOpened});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();

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
                // const SizedBox(height: 20),
                // _buildSearchBar(context),
                const SizedBox(height: 20),
                // const SizedBox(height: 16),
                _buildSectionDivider(),
                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
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
                      value: (formatAmount(provider.totalFeesDues)),
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
                          Get.to(() => AddStudentScreen(isEditing: false));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        title: "Add Payment",
                        subtitle: "Fees",
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

  Widget _buildSectionDivider() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insights_rounded,
                size: 13,
                color: const Color(0xFF6C63FF).withValues(alpha: 0.85),
              ),
              const SizedBox(width: 5),
              Text(
                "OVERVIEW",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE5E7EB),
                  const Color(0xFFE5E7EB).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getDayName(int day) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return days[day - 1];
  }

  Widget _buildTopBar() {
    final hour = DateTime.now().hour;
    final now = DateTime.now();
    final date =
        "${_getDayName(now.weekday)}, ${now.day} ${months[now.month - 1]}";

    String greeting = "Good Morning";
    if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17) {
      greeting = "Good Evening";
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: widget.onDrawerOpened,
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "DeityCoach",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "$greeting · $date",
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _topBarButton(Icons.notifications_none_rounded, showDot: true),
        const SizedBox(width: 8),
        _profileButton(),
      ],
    );
  }

  Widget _topBarButton(IconData icon, {bool showDot = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF374151), size: 21),
        ),
        if (showDot)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _profileButton() {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "A",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  String formatAmount(double amount) {
    // if (amount >= 10000000) {
    //   return "${(amount / 10000000).toStringAsFixed(1)}Cr";
    // }

    // if (amount >= 100000) {
    //   return "${(amount / 100000).toStringAsFixed(1)}L";
    // }

    // if (amount >= 1000) {
    //   return "${(amount / 1000).toStringAsFixed(1)}K";
    // }

    return AppFormatter.formatCurrency(amount);
  }

  Widget _buildSearchBar(BuildContext context) {
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
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                context.read<StudentProvider>().searchStudents(value);
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search students, batches, courses...",
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
    final growth = provider.collectionGrowthPercentage;
    final isGrowing = provider.isCollectionGrowing;
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
            AppFormatter.formatCurrency(provider.totalFeesPaid),
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isGrowing
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isGrowing ? Colors.green : Colors.red,
                size: 18,
              ),

              const SizedBox(width: 6),

              Text(
                "${growth.abs().toStringAsFixed(1)}% from last month",
                style: TextStyle(
                  color: isGrowing ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
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
      padding: const EdgeInsets.only(left: 10, top: 16, bottom: 16, right: 16),
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
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
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
