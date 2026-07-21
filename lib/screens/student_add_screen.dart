import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/provider/student_provider.dart';

class AddStudentScreen extends StatefulWidget {
  final StudentModel? student;

  const AddStudentScreen({super.key, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController rollNumberController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController parentsPhoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController totalFeesController = TextEditingController();
  final TextEditingController feesPaidController = TextEditingController();

  Gender selectedGender = Gender.Male;
  StudentStatus studentStatus = StudentStatus.Active;
  FeesStatus feeStatus = FeesStatus.Paid;

  DateTime? dob;
  DateTime? joiningDate;

  BatchTiming selectedBatch = BatchTiming.Morning;

  @override
  void initState() {
    super.initState();

    if (widget.student != null) {
      final student = widget.student!;

      rollNumberController.text = student.rollNumber;
      nameController.text = student.name;
      fatherNameController.text = student.fatherName;
      phoneController.text = student.phone;
      parentsPhoneController.text = student.parentsPhone;
      emailController.text = student.email ?? '';
      addressController.text = student.address;
      courseController.text = student.course;

      totalFeesController.text = student.totalFees.toString();

      feesPaidController.text = student.feesPaid.toString();

      selectedGender = student.gender;
      studentStatus = student.studentStatus;

      selectedBatch = student.batchTime;

      dob = student.dob;
      joiningDate = student.joiningDate;
    }
  }

  @override
  void dispose() {
    rollNumberController.dispose();
    nameController.dispose();
    fatherNameController.dispose();
    phoneController.dispose();
    parentsPhoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    courseController.dispose();
    totalFeesController.dispose();
    feesPaidController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      initialDate: dob ?? DateTime(2010),
    );

    if (picked != null) {
      setState(() => dob = picked);
    }
  }

  Future<void> _pickJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: joiningDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() => joiningDate = picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select date";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
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
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 22),

                        _sectionCard(
                          title: "Personal Details",
                          icon: Icons.person_outline_rounded,
                          child: Column(
                            children: [
                              _modernTextField(
                                controller: rollNumberController,
                                label: "Roll Number",
                                hint: "Enter Roll Number",
                                icon: Icons.badge_outlined,
                              ),
                              _modernTextField(
                                controller: nameController,
                                label: "Student Name",
                                hint: "Enter full name",
                                icon: Icons.badge_outlined,
                              ),
                              _modernTextField(
                                controller: fatherNameController,
                                label: "Father Name",
                                hint: "Enter father name",
                                icon: Icons.family_restroom_outlined,
                              ),
                              _modernTextField(
                                controller: phoneController,
                                label: "Student Phone",
                                hint: "10 digit number",
                                icon: Icons.call_outlined,
                                keyboard: TextInputType.phone,
                              ),

                              _modernTextField(
                                controller: parentsPhoneController,
                                label: "Parent Phone",
                                hint: "10 digit number",
                                icon: Icons.phone_android_outlined,
                                keyboard: TextInputType.phone,
                              ),
                              _modernTextField(
                                controller: emailController,
                                label: "Email Address",
                                hint: "Enter email",
                                icon: Icons.email_outlined,
                                keyboard: TextInputType.emailAddress,
                              ),
                              _modernTextField(
                                controller: addressController,
                                label: "Address",
                                hint: "Enter address",
                                icon: Icons.location_on_outlined,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 4),
                              _modernDropdownField<Gender>(
                                label: "Gender",
                                value: selectedGender,
                                icon: Icons.wc_rounded,
                                entries: Gender.values
                                    .map(
                                      (e) => DropdownMenuEntry<Gender>(
                                        value: e,
                                        label: e.name,
                                      ),
                                    )
                                    .toList(),
                                onSelected: (value) {
                                  if (value != null) {
                                    setState(() => selectedGender = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _datePickerCard(
                                      title: "Date of Birth",
                                      value: _formatDate(dob),
                                      icon: Icons.cake_outlined,
                                      onTap: _pickDob,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _datePickerCard(
                                      title: "Joining Date",
                                      value: _formatDate(joiningDate),
                                      icon: Icons.calendar_month_rounded,
                                      onTap: _pickJoiningDate,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _sectionCard(
                          title: "Academic Details",
                          icon: Icons.school_outlined,
                          child: Column(
                            children: [
                              _modernTextField(
                                controller: courseController,
                                label: "Course Name",
                                hint: "JEE / NEET / Foundation",
                                icon: Icons.menu_book_outlined,
                              ),
                              _modernDropdownField<BatchTiming>(
                                label: "Batch Time",
                                value: selectedBatch,
                                icon: Icons.schedule_rounded,
                                entries: const [
                                  DropdownMenuEntry(
                                    value: BatchTiming.Morning,
                                    label: "Morning",
                                  ),
                                  DropdownMenuEntry(
                                    value: BatchTiming.Evening,
                                    label: "Evening",
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value != null) {
                                    setState(() => selectedBatch = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                              _modernDropdownField<StudentStatus>(
                                label: "Student Status",
                                value: studentStatus,
                                icon: Icons.verified_user_outlined,
                                entries: StudentStatus.values
                                    .map(
                                      (e) => DropdownMenuEntry<StudentStatus>(
                                        value: e,
                                        label: e.name,
                                      ),
                                    )
                                    .toList(),
                                onSelected: (value) {
                                  if (value != null) {
                                    setState(() => studentStatus = value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _sectionCard(
                          title: "Fees Details",
                          icon: Icons.account_balance_wallet_outlined,
                          child: Column(
                            children: [
                              _modernTextField(
                                controller: totalFeesController,
                                label: "Total Fees",
                                hint: "Enter total fees",
                                icon: Icons.currency_rupee_rounded,
                                keyboard: TextInputType.number,
                              ),
                              _modernTextField(
                                controller: feesPaidController,
                                label: "Fees Paid",
                                hint: "Enter paid amount",
                                icon: Icons.payments_outlined,
                                keyboard: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _summaryCard(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF6D5DF6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              if (widget.student == null) {
                                addStudent(provider);
                              } else {
                                updateStudent(provider);
                              }
                            },
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: Text(
                              (widget.student == null)
                                  ? "Add Student"
                                  : "Update Student",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Future<void> addStudent(StudentProvider provider) async {
    if (dob == null || joiningDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all the fields")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final totalFees = double.tryParse(totalFeesController.text.trim()) ?? 0;

      final admissionPayment =
          double.tryParse(feesPaidController.text.trim()) ?? 0;

      List<FeePayment> payments = [];

      if (admissionPayment > 0) {
        payments.add(
          FeePayment(
            rollNumber: rollNumberController.text.trim(),
            amount: admissionPayment,
            paymentDate: DateTime.now(),
            paymentMethod: PaymentMethod.Cash,
            remarks: "Admission Fees",
            receivedBy: "Admin",
          ),
        );
      }

      await provider.addStudent(
        StudentModel(
          rollNumber: rollNumberController.text.trim(),
          name: nameController.text.trim(),
          fatherName: fatherNameController.text.trim(),
          parentsPhone: parentsPhoneController.text.trim(),
          email: emailController.text.trim(),
          gender: selectedGender,
          phone: phoneController.text.trim(),
          dob: dob!,
          address: addressController.text.trim(),
          batchTime: selectedBatch,
          joiningDate: joiningDate!,
          totalFees: totalFees,
          payments: payments,
          studentStatus: studentStatus,
          course: courseController.text.trim(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student added successfully")),
      );

      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateStudent(StudentProvider provider) async {
    if (dob == null || joiningDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all the fields")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      provider.updateStudent(
        rollNumberController.text,
        StudentModel(
          rollNumber: rollNumberController.text.trim(),
          name: nameController.text.trim(),
          fatherName: fatherNameController.text.trim(),
          parentsPhone: parentsPhoneController.text.trim(),
          email: emailController.text.trim(),
          gender: selectedGender,
          phone: phoneController.text.trim(),
          dob: dob!,
          address: addressController.text.trim(),
          batchTime: selectedBatch,
          joiningDate: joiningDate!,
          totalFees: double.tryParse(totalFeesController.text.trim()) ?? 0,
          payments: [],
          studentStatus: studentStatus,
          course: courseController.text.trim(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student updated successfully")),
      );

      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _glassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Student",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          _glassIconButton(icon: Icons.more_horiz_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
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
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Student Admission",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Create a new admission profile",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(28),
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
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF6D5DF6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
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
        ),
      ),
    );
  }

  Widget _modernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Required field";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF6D5DF6), width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _modernDropdownField<T>({
    required String label,
    required T value,
    required IconData icon,
    required List<DropdownMenuEntry<T>> entries,
    required ValueChanged<T?> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownMenu<T>(
        // width: double.infinity,
        initialSelection: value,

        onSelected: onSelected,
        leadingIcon: Icon(icon),
        label: Text(label),
        expandedInsets: EdgeInsets.zero,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF6D5DF6), width: 1.4),
          ),
        ),
        dropdownMenuEntries: entries,
      ),
    );
  }

  Widget _datePickerCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF6D5DF6), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
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

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.verified_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ready to save",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Review details once before creating the student profile.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.70),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 50,
              width: 50,
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
