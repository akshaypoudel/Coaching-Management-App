import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stdent_management_system/screens/communication_screen.dart';
import 'package:stdent_management_system/screens/fees_management_screen.dart';
import 'package:stdent_management_system/screens/student_dashboard_screen.dart';
import 'package:stdent_management_system/screens/student_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  static const double _navVisualHeight = 78;
  static const double _navBottomGap = 14;
  static const double _pageBottomInset = _navBottomGap * 2 + 20;

  final List<Widget> _pages = const [
    StudentDashboardScreen(),
    StudentsScreen(),
    FeesManagementScreen(),
    CommunicationScreen(),
  ];

  final List<_NavItemData> _items = [
    _NavItemData(label: 'Dashboard', icon: FontAwesomeIcons.chartSimple.data),
    _NavItemData(label: 'Students', icon: FontAwesomeIcons.userGraduate.data),
    _NavItemData(label: 'Fees', icon: FontAwesomeIcons.wallet.data),
    _NavItemData(label: 'Messages', icon: FontAwesomeIcons.comments.data),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: _pageBottomInset),
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages
                    .map(
                      (page) => _PageBottomSafeWrapper(
                        child: page,
                        bottomInset: _pageBottomInset,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: _navBottomGap,
            child: SafeArea(top: false, child: _buildBottomBar()),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: _navVisualHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = _selectedIndex == index;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => _selectedIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOutCubicEmphasized,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEEF2FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FaIconData(item.icon),
                          size: 18,
                          color: isSelected
                              ? const Color(0xFF5B67F6)
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF5B67F6)
                                  : const Color(0xFF6B7280),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PageBottomSafeWrapper extends StatelessWidget {
  final Widget child;
  final double bottomInset;

  const _PageBottomSafeWrapper({
    required this.child,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeBottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: child,
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;

  const _NavItemData({required this.label, required this.icon});
}
