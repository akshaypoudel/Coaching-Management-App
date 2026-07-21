import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:provider/provider.dart';
import 'package:stdent_management_system/components/app_currency_formatter.dart';
import 'package:stdent_management_system/components/pagination_helper.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/provider/student_provider.dart';
import 'package:stdent_management_system/screens/student_details_screen.dart';

class FeesManagementScreen extends StatefulWidget {
  const FeesManagementScreen({super.key});

  @override
  State<FeesManagementScreen> createState() => _FeesManagementScreenState();
}

class _FeesManagementScreenState extends State<FeesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedTab = "All Fees";
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Derives a display fee-status from the model's computed properties,
  /// since StudentModel has no direct "Pending/Overdue" field.
  String _feeStatusLabel(StudentModel s) {
    if (s.feesDues <= 0) return "Paid";
    final due = s.nextDueDate;
    if (due != null && due.isBefore(DateTime.now())) return "Overdue";
    return "Pending";
  }

  List<StudentModel> _applyFilters(List<StudentModel> students) {
    var result = students;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.phone.toLowerCase().contains(q) ||
            s.rollNumber.toLowerCase().contains(q) ||
            s.course.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedTab != "All Fees") {
      result = result.where((s) => _feeStatusLabel(s) == _selectedTab).toList();
    }

    return result;
  }

  void _resetToFirstPage() {
    setState(() => _currentPage = 0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final allStudents = provider.students;

    final filtered = _applyFilters(allStudents);

    final paginator = Paginator<StudentModel>(
      items: filtered,
      itemsPerPage: _itemsPerPage,
      currentPage: _currentPage,
    );
    _currentPage = paginator.currentPage; // sync back after clamp
    final pageItems = paginator.pageItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFF8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D5DF6).withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: "fees_add",
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () {},
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "Add Payment",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFF2F5FF), Color(0xFFF8F6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                const Text(
                  "Track student payments, pending dues and overdue collections",
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.9,
                  children: [
                    _feeCard(
                      title: "Total Fees",
                      value: AppFormatter.formatCurrency(provider.totalFees),
                      subtitle: "This session",
                      color: const Color(0xFF6D5DF6),
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                    _feeCard(
                      title: "Collected",
                      value: AppFormatter.formatCurrency(
                        provider.totalFeesPaid,
                      ),
                      subtitle:
                          "${provider.collectionPercentage.toStringAsFixed(1)}% received",
                      color: const Color(0xFF22C55E),
                      icon: Icons.check_circle_rounded,
                    ),
                    _feeCard(
                      title: "Pending",
                      value: AppFormatter.formatCurrency(
                        provider.totalFeesDues,
                      ),
                      subtitle: "Need attention",
                      color: const Color(0xFFF59E0B),
                      icon: Icons.pending_actions_rounded,
                    ),
                    _feeCard(
                      title: "Overdue",
                      value: AppFormatter.formatCurrency(
                        provider.overdueAmount,
                      ),
                      subtitle: "Critical dues",
                      color: const Color(0xFFEF4444),
                      icon: Icons.warning_amber_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFilterTabs(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Recent Fee Records",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6D5DF6).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${filtered.length}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6D5DF6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  filtered.length == allStudents.length
                      ? "Monitor status and collect payments faster"
                      : "Showing ${filtered.length} of ${allStudents.length} records",
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                if (pageItems.isEmpty)
                  _emptyState()
                else
                  ListView.builder(
                    itemCount: pageItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final fee = pageItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _feeStudentCard(fee),
                      );
                    },
                  ),
                if (filtered.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  PaginationBar(
                    currentPage: paginator.currentPage,
                    totalPages: paginator.totalPages,
                    startIndex: paginator.startIndex,
                    endIndex: paginator.endIndex,
                    totalCount: filtered.length,
                    onFirst: () => setState(() => _currentPage = 0),
                    onPrevious: () => setState(() => _currentPage--),
                    onNext: () => setState(() => _currentPage++),
                    onLast: () =>
                        setState(() => _currentPage = paginator.totalPages - 1),
                  ),
                ],
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
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            "No fee records match your filters",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Fee Overview",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _feeStudentCard(StudentModel fee) {
    final Color accent = Colors.deepPurpleAccent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.84),
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
            children: [
              Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accent, accent.withOpacity(0.75)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        fee.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
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
                          fee.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          fee.course,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusWidget(_feeStatusLabel(fee)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _amountBox(
                      "Total",
                      AppFormatter.formatCurrency(fee.totalFees.ceil()),
                      const Color(0xFF6D5DF6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _amountBox(
                      "Paid",
                      AppFormatter.formatCurrency(fee.feesPaid.ceil()),
                      const Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _amountBox(
                      "Pending",
                      AppFormatter.formatCurrency(fee.feesDues.ceil()),
                      const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      title: "View",
                      icon: Icons.remove_red_eye_outlined,
                      color: const Color(0xFF6D5DF6),
                      onTap: () {
                        Get.to(() => StudentDetailsScreen(student: fee));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      title: "Collect",
                      icon: Icons.currency_rupee_rounded,
                      color: const Color(0xFF22C55E),
                      onTap: () {
                        showCollectFeesBottomSheet(
                          context: context,
                          student: fee,
                        );
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

  Future<void> showCollectFeesBottomSheet({
    required BuildContext context,
    required StudentModel student,
  }) async {
    final amountController = TextEditingController();
    final remarksController = TextEditingController();
    final receivedByController = TextEditingController();

    PaymentMethod selectedMethod = PaymentMethod.Cash;

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 55,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Collect Fees",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(.05),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  student.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(student.course),

                                    const SizedBox(height: 4),

                                    Text(
                                      "Pending : ${AppFormatter.formatCurrency(student.feesDues)}",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: "Amount",
                            prefixIcon: const Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter amount";
                            }

                            final amount = double.tryParse(value);

                            if (amount == null) {
                              return "Invalid amount";
                            }

                            if (amount <= 0) {
                              return "Amount must be greater than 0";
                            }

                            if (amount > student.feesDues) {
                              return "Amount cannot exceed pending fees";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        DropdownButtonFormField<PaymentMethod>(
                          value: selectedMethod,
                          decoration: InputDecoration(
                            labelText: "Payment Method",
                            prefixIcon: const Icon(
                              Icons.account_balance_wallet,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          items: PaymentMethod.values.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMethod = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: receivedByController,
                          decoration: InputDecoration(
                            labelText: "Received By",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: remarksController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: "Remarks",
                            prefixIcon: const Icon(Icons.notes),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle),
                            label: const Text(
                              "Collect Fees",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              final payment = FeePayment(
                                rollNumber: student.rollNumber,
                                amount: double.parse(amountController.text),
                                paymentDate: DateTime.now(),
                                paymentMethod: selectedMethod,
                                remarks: remarksController.text.trim(),
                                receivedBy: receivedByController.text.trim(),
                              );

                              await context.read<StudentProvider>().collectFees(
                                payment,
                              );

                              Navigator.pop(context);
                            },
                          ),
                        ),

                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _amountBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.12)),
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

  Widget _statusWidget(String status) {
    Color color = const Color(0xFF16A34A);
    Color bg = const Color(0xFFDCFCE7);

    if (status == "Pending") {
      color = const Color(0xFFEA580C);
      bg = const Color(0xFFFFEDD5);
    } else if (status == "Overdue") {
      color = const Color(0xFFDC2626);
      bg = const Color(0xFFFEE2E2);
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

  Widget _feeCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
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

  Widget _buildFilterTabs() {
    final tabs = ["All Fees", "Pending", "Paid", "Overdue"];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: tabs.map((t) {
          final active = _selectedTab == t;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedTab = t);
              _resetToFirstPage();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFEEF2FF)
                    : Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? const Color(0xFF6D5DF6) : Colors.white,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                t,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: active
                      ? const Color(0xFF5B67F6)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _resetToFirstPage();
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search student, roll no or course...",
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
              child: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF)),
            ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6D5DF6) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: active ? Colors.white : Colors.grey),
    );
  }
}
