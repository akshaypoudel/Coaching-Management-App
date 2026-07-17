import 'dart:ui';
import 'package:flutter/material.dart';

class FeesManagementScreen extends StatelessWidget {
  const FeesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.9,
                  children: [
                    _feeCard(
                      title: "Total Fees",
                      value: "₹2,40,000",
                      subtitle: "This session",
                      color: const Color(0xFF6D5DF6),
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                    _feeCard(
                      title: "Collected",
                      value: "₹1,98,000",
                      subtitle: "82.5% received",
                      color: const Color(0xFF22C55E),
                      icon: Icons.check_circle_rounded,
                    ),
                    _feeCard(
                      title: "Pending",
                      value: "₹42,000",
                      subtitle: "Need attention",
                      color: const Color(0xFFF59E0B),
                      icon: Icons.pending_actions_rounded,
                    ),
                    _feeCard(
                      title: "Overdue",
                      value: "₹18,000",
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
                const Text(
                  "Recent Fee Records",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Monitor status and collect payments faster",
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                ListView.builder(
                  itemCount: feesData.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final fee = feesData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _feeStudentCard(fee),
                    );
                  },
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
        const Expanded(
          child: Text(
            "Fee Overview",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        _iconButton(Icons.search_rounded),
        const SizedBox(width: 10),
        _iconButton(Icons.notifications_none_rounded),
      ],
    );
  }

  Widget _feeStudentCard(Map<String, dynamic> fee) {
    final Color accent = fee["color"] as Color;

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
                        fee["name"][0],
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
                          fee["name"],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          fee["course"],
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusWidget(fee["status"]),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _amountBox(
                      "Total",
                      fee["total"],
                      const Color(0xFF6D5DF6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _amountBox(
                      "Paid",
                      fee["paid"],
                      const Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _amountBox(
                      "Pending",
                      fee["pending"],
                      const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFFDC2626),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fee["dueDate"] == "No Due"
                            ? "No pending due date"
                            : "Due Date: ${fee["dueDate"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      "View",
                      Icons.remove_red_eye_outlined,
                      const Color(0xFF6D5DF6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      "Collect",
                      Icons.currency_rupee_rounded,
                      const Color(0xFF22C55E),
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

  Widget _actionButton(String title, IconData icon, Color color) {
    return Container(
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
      padding: const EdgeInsets.all(16),
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
              fontSize: 22,
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
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _activeTab("All Fees"),
          _tab("Pending"),
          _tab("Paid"),
          _tab("Overdue"),
        ],
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
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search student...",
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Icon(Icons.tune_rounded, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }

  Widget _activeTab(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: const Text(
        "All Fees",
        style: TextStyle(color: Color(0xFF5B67F6), fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _tab(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: Icon(icon, color: const Color(0xFF374151)),
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

List<Map<String, dynamic>> feesData = [
  {
    "name": "Rahul Kumar",
    "course": "JEE Advanced",
    "total": "₹60,000",
    "paid": "₹40,000",
    "pending": "₹20,000",
    "dueDate": "10 Jun 2024",
    "status": "Pending",
    "color": const Color(0xFF6D5DF6),
  },
  {
    "name": "Anjali Sharma",
    "course": "NEET",
    "total": "₹50,000",
    "paid": "₹50,000",
    "pending": "₹0",
    "dueDate": "No Due",
    "status": "Paid",
    "color": const Color(0xFF22C55E),
  },
  {
    "name": "Pooja Yadav",
    "course": "NEET",
    "total": "₹50,000",
    "paid": "₹20,000",
    "pending": "₹30,000",
    "dueDate": "15 Jun 2024",
    "status": "Overdue",
    "color": const Color(0xFFEF4444),
  },
];
