import 'package:flutter/material.dart';

/// Generic helper that handles page-slicing logic for any list type.
/// Works with students, fee records, messages — anything.
class Paginator<T> {
  final List<T> items;
  final int itemsPerPage;
  int currentPage;

  Paginator({
    required this.items,
    this.itemsPerPage = 10,
    this.currentPage = 0,
  }) {
    _clamp();
  }

  int get totalPages =>
      items.isEmpty ? 1 : (items.length / itemsPerPage).ceil();

  int get startIndex => currentPage * itemsPerPage;

  int get endIndex => (startIndex + itemsPerPage).clamp(0, items.length);

  List<T> get pageItems =>
      items.isEmpty ? <T>[] : items.sublist(startIndex, endIndex);

  bool get hasPrevious => currentPage > 0;

  bool get hasNext => currentPage < totalPages - 1;

  void _clamp() {
    if (currentPage >= totalPages) currentPage = totalPages - 1;
    if (currentPage < 0) currentPage = 0;
  }

  void goToFirst() {
    currentPage = 0;
  }

  void goToLast() {
    currentPage = totalPages - 1;
  }

  void goToPrevious() {
    if (hasPrevious) currentPage--;
  }

  void goToNext() {
    if (hasNext) currentPage++;
  }

  void reset() {
    currentPage = 0;
  }
}

/// Reusable pagination bar UI — used across Students, Fees Management,
/// and Messages screens.
class PaginationBar extends StatelessWidget {
  final int currentPage; // 0-indexed
  final int totalPages;
  final int startIndex; // 0-indexed
  final int endIndex; // exclusive
  final int totalCount;
  final VoidCallback onFirst;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onLast;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.startIndex,
    required this.endIndex,
    required this.totalCount,
    required this.onFirst,
    required this.onPrevious,
    required this.onNext,
    required this.onLast,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrevious = currentPage > 0;
    final hasNext = currentPage < totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${startIndex + 1}-$endIndex of $totalCount",
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
          _pageArrow(
            icon: Icons.first_page_rounded,
            enabled: hasPrevious,
            onTap: onFirst,
          ),
          const SizedBox(width: 6),
          _pageArrow(
            icon: Icons.chevron_left_rounded,
            enabled: hasPrevious,
            onTap: onPrevious,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6D5DF6).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${currentPage + 1} / $totalPages",
              style: const TextStyle(
                color: Color(0xFF6D5DF6),
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _pageArrow(
            icon: Icons.chevron_right_rounded,
            enabled: hasNext,
            onTap: onNext,
          ),
          const SizedBox(width: 6),
          _pageArrow(
            icon: Icons.last_page_rounded,
            enabled: hasNext,
            onTap: onLast,
          ),
        ],
      ),
    );
  }

  Widget _pageArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }
}
