import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:stdent_management_system/components/communication_widget.dart';
import 'package:stdent_management_system/components/pagination_helper.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/provider/student_provider.dart';
import 'package:provider/provider.dart';
import 'package:stdent_management_system/screens/student_add_screen.dart';
import 'package:stdent_management_system/screens/student_details_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CommunicationMethods communication = CommunicationMethods();
  String _searchQuery = "";
  String _selectedCourse = "All Courses";
  FeesStatus _selectedFeeStatus = FeesStatus.None;

  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> _applyFilters(List<StudentModel> students) {
    var result = students;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.phone.toLowerCase().contains(q) ||
            s.rollNumber.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedCourse != "All Courses") {
      result = result.where((s) => s.course == _selectedCourse).toList();
    }

    if (_selectedFeeStatus != FeesStatus.None) {
      result = result.where((s) => s.feeStatus == _selectedFeeStatus).toList();
    }

    return result;
  }

  void _resetToFirstPage() {
    setState(() => _currentPage = 0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final allStudents = provider.getStudents;

    final filtered = _applyFilters(allStudents);
    final totalPages = filtered.isEmpty
        ? 1
        : (filtered.length / _itemsPerPage).ceil();

    final paginator = Paginator<StudentModel>(
      items: filtered,
      itemsPerPage: _itemsPerPage,
      currentPage: _currentPage,
    );
    _currentPage = paginator.currentPage;

    final pageItems = paginator.pageItems;

    // Clamp current page if filters shrank the result set
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }
    if (_currentPage < 0) _currentPage = 0;

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);

    // Distinct course list for the filter sheet
    final courseOptions = <String>{
      "All Courses",
      ...allStudents.map((s) => s.course),
    }.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B67F6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: "student_add",
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () {
            Get.to(() => AddStudentScreen());
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "Add Student",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFF2F6FF), Color(0xFFF8F4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(filtered.length, allStudents.length),
                      const SizedBox(height: 16),
                      _buildSearchBar(),
                      const SizedBox(height: 14),
                      _buildFilterSection(courseOptions),
                      const SizedBox(height: 18),
                      _buildFeatureBanner(
                        provider.totalStudents.toString(),
                        provider.studentThisMonth.toString(),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              title: "Total Students",
                              value: provider.getStudents.length.toString(),
                              subtitle: "Active enrolments",
                              color: const Color(0xFF6D5DF6),
                              icon: Icons.groups_2_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              title: "Pending Fees",
                              value: provider.studentsWithPendingFees
                                  .toString(),
                              subtitle: "Need follow-up",
                              color: const Color(0xFFFF8A65),
                              icon: Icons.account_balance_wallet_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Student Directory",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        filtered.length == allStudents.length
                            ? "Manage profiles, fees and quick actions"
                            : "Showing ${filtered.length} of ${allStudents.length} students",
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              if (pageItems.isEmpty)
                SliverToBoxAdapter(child: _emptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList.builder(
                    itemCount: pageItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _studentCard(pageItems[index]),
                      );
                    },
                  ),
                ),
              if (filtered.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    child: PaginationBar(
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int filteredCount, int totalCount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Students",
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
                "Track admissions, fees and student activity",
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
          onTap: () => _showFilterSheet(context, "course", []),
          showBadge:
              _selectedCourse != "All Courses" ||
              _selectedFeeStatus != FeesStatus.None,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _resetToFirstPage();
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search by name, phone or ID",
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(List<String> courseOptions) {
    final feeStatusOptions = ["All Status", "Paid", "Pending", "Partial"];

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(
            _selectedCourse,
            active: _selectedCourse != "All Courses",
            onTap: () => _showFilterSheet(context, "course", courseOptions),
          ),
          const SizedBox(width: 10),
          _filterChip(
            _selectedFeeStatus == FeesStatus.None
                ? "All Status"
                : _selectedFeeStatus.name,
            active: _selectedFeeStatus != FeesStatus.None,
            onTap: () => _showFilterSheet(context, "fee", feeStatusOptions),
          ),
          if (_selectedCourse != "All Courses" ||
              _selectedFeeStatus != FeesStatus.None) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCourse = "All Courses";
                  _selectedFeeStatus = FeesStatus.None;
                });
                _resetToFirstPage();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Clear",
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    String type,
    List<String> options,
  ) {
    // "course" chip / tune icon opens course+fee combined sheet when options empty
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _FilterSheet(
          initialCourse: _selectedCourse,
          initialFeeStatus: _selectedFeeStatus,
          courseOptions: options.isNotEmpty && type == "course"
              ? options
              : <String>{
                  "All Courses",
                  ...Provider.of<StudentProvider>(
                    context,
                    listen: false,
                  ).getStudents.map((s) => s.course),
                }.toList(),
          feeStatusOptions: [
            FeesStatus.None.name,
            FeesStatus.Paid.name,
            FeesStatus.Due.name,
          ],
          onApply: (course, feeStatus) {
            setState(() {
              _selectedCourse = course;
              _selectedFeeStatus = feeStatus;
            });
            _resetToFirstPage();
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            "No students match your filters",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBanner(String totalStudents, String studentThisMonth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF8B5CF6), Color(0xFF4F8DFD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DF6).withValues(alpha: 0.30),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bannerTag("Overview"),
                const SizedBox(height: 14),
                Text(
                  "$totalStudents students across all courses",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$studentThisMonth new admissions this month",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCard(StudentModel student) {
    final Color accent = Colors.orangeAccent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 62,
                    width: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.75)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.24),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        student.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
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
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
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
                  _feeStatus(student.feeStatus.name),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _metaTile(
                      icon: Icons.badge_outlined,
                      label: "Roll No.",
                      value: student.rollNumber,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: _metaTile(
                      icon: Icons.call_outlined,
                      label: "Phone",
                      value: student.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      "View",
                      Icons.remove_red_eye_outlined,
                      const Color(0xFF6D5DF6),
                      onTap: () {
                        Get.to(() => StudentDetailsScreen(student: student));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      "Edit",
                      Icons.edit_outlined,
                      const Color(0xFFFF8A65),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      "Call",
                      Icons.call_outlined,
                      const Color(0xFF22C55E),
                      onTap: () {
                        communication.makeCall(student, context);
                      },
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

  Widget _actionButton(
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(128, 239, 243, 247),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF5B67F6)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeStatus(String status) {
    Color color = const Color(0xFF16A34A);
    Color bg = const Color(0xFFDCFCE7);

    if (status == "Pending") {
      color = const Color(0xFFEA580C);
      bg = const Color(0xFFFFEDD5);
    } else if (status == "Partial") {
      color = const Color(0xFF2563EB);
      bg = const Color(0xFFDBEAFE);
    }

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

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
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
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.75)],
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
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
          const SizedBox(height: 4),
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
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
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

  Widget _bannerTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _filterChip(
    String text, {
    bool active = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFF6D5DF6), Color(0xFF8B5CF6)],
                )
              : null,
          color: active ? null : Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? Colors.transparent : Colors.white),
          boxShadow: [
            BoxShadow(
              color: active
                  ? const Color(0xFF6D5DF6).withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF374151),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: active ? Colors.white : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String initialCourse;
  final FeesStatus initialFeeStatus;
  final List<String> courseOptions;
  final List<String> feeStatusOptions;
  final void Function(String course, FeesStatus feeStatus) onApply;

  const _FilterSheet({
    required this.initialCourse,
    required this.initialFeeStatus,
    required this.courseOptions,
    required this.feeStatusOptions,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String course = widget.initialCourse;
  late FeesStatus feeStatus = widget.initialFeeStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
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
              "Filter Students",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            const Text(
              "Course",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.courseOptions.map((c) {
                final selected = c == course;
                return ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => setState(() => course = c),
                  selectedColor: const Color(0xFF6D5DF6),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF374151),
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
            const SizedBox(height: 20),
            const Text(
              "Fee Status",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.feeStatusOptions.map((f) {
                final selected = f == feeStatus.name;
                return ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => feeStatus = FeesStatus.values.byName(f)),
                  selectedColor: const Color(0xFF6D5DF6),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF374151),
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
                  widget.onApply(course, feeStatus);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D5DF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Apply Filters",
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

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final bool active;

  const BottomNavItem({super.key, required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF5B67F6)],
              )
            : null,
        color: active ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Icon(icon, color: active ? Colors.white : Colors.grey),
    );
  }
}
