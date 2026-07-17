enum Gender { Male, Female, Others }

enum StudentStatus { Active, Completed, Droped }

enum FeesStatus { Paid, Due }

enum BatchTiming { Morning, Evening }

enum PaymentMethod { Cash, UPI, Card }

class StudentModel {
  String rollNumber;
  String name;
  String fatherName;
  String parentsPhone;
  String? email;
  Gender gender;
  String phone;
  DateTime dob;
  String address;
  BatchTiming batchTime;
  DateTime joiningDate;

  double totalFees;

  List<FeePayment> payments;

  StudentStatus studentStatus;
  String course;

  StudentModel({
    required this.rollNumber,
    required this.name,
    required this.fatherName,
    required this.parentsPhone,
    this.email,
    required this.gender,
    required this.phone,
    required this.dob,
    required this.address,
    required this.batchTime,
    required this.joiningDate,
    required this.totalFees,
    this.payments = const [],
    required this.studentStatus,
    required this.course,
  });

  /// --------------------------
  /// Calculated Properties
  /// --------------------------

  double get feesPaid =>
      payments.fold(0, (sum, payment) => sum + payment.amount);

  double get feesDues {
    final due = totalFees - feesPaid;
    return due < 0 ? 0 : due;
  }

  FeesStatus get feeStatus => feesDues <= 0 ? FeesStatus.Paid : FeesStatus.Due;

  /// --------------------------
  /// TO JSON
  /// --------------------------

  Map<String, dynamic> toJson() {
    return {
      "roll_number": rollNumber,
      "name": name,
      "father_name": fatherName,
      "parents_phone": parentsPhone,
      "email": email,
      "gender": gender.name,
      "phone": phone,
      "dob": dob.toIso8601String().split('T').first,
      "address": address,
      "batch_time": batchTime.name,
      "joining_date": joiningDate.toIso8601String().split('T').first,
      "total_fees": totalFees,
      "student_status": studentStatus.name,
      "course": course,
      "payments": payments.map((e) => e.toJson()).toList(),
    };
  }

  /// --------------------------
  /// FROM JSON
  /// --------------------------

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      rollNumber: json["roll_number"] ?? "",
      name: json["name"] ?? "",
      fatherName: json["father_name"] ?? "",
      parentsPhone: json["parents_phone"] ?? "",
      email: json["email"],

      gender: Gender.values.firstWhere(
        (e) => e.name == json["gender"],
        orElse: () => Gender.Male,
      ),

      phone: json["phone"] ?? "",

      dob: DateTime.parse(json["dob"]),

      address: json["address"] ?? "",

      batchTime: BatchTiming.values.firstWhere(
        (e) => e.name == json["batch_time"],
      ),

      joiningDate: DateTime.parse(json["joining_date"]),

      totalFees: (json["total_fees"] ?? 0).toDouble(),

      studentStatus: StudentStatus.values.firstWhere(
        (e) => e.name == json["student_status"],
        orElse: () => StudentStatus.Active,
      ),

      course: json["course"] ?? "",

      payments: json["payments"] == null
          ? []
          : List<FeePayment>.from(
              json["payments"].map((e) => FeePayment.fromJson(e)),
            ),
    );
  }

  /// --------------------------
  /// COPY WITH
  /// --------------------------

  StudentModel copyWith({
    String? rollNumber,
    String? name,
    String? fatherName,
    String? parentsPhone,
    String? email,
    Gender? gender,
    String? phone,
    DateTime? dob,
    String? address,
    BatchTiming? batchTime,
    DateTime? joiningDate,
    double? totalFees,
    List<FeePayment>? payments,
    StudentStatus? studentStatus,
    String? course,
  }) {
    return StudentModel(
      rollNumber: rollNumber ?? this.rollNumber,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      parentsPhone: parentsPhone ?? this.parentsPhone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      batchTime: batchTime ?? this.batchTime,
      joiningDate: joiningDate ?? this.joiningDate,
      totalFees: totalFees ?? this.totalFees,
      payments: payments ?? this.payments,
      studentStatus: studentStatus ?? this.studentStatus,
      course: course ?? this.course,
    );
  }

  @override
  String toString() {
    return '''
StudentModel(
  Roll Number : $rollNumber
  Name        : $name
  Course      : $course
  Fees Paid   : $feesPaid
  Fees Due    : $feesDues
  Status      : ${studentStatus.name}
)
''';
  }
}

///
/// ------------------------------
/// Fee Payment Model
/// ------------------------------
///

class FeePayment {
  final int? id;

  final double amount;

  final DateTime paymentDate;

  final PaymentMethod paymentMethod;

  final String? remarks;

  final String? receivedBy;

  final DateTime? createdAt;

  FeePayment({
    this.id,
    this.remarks,
    this.receivedBy,
    this.createdAt,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "amount": amount,
      "payment_date": paymentDate.toIso8601String().split('T').first,
      "payment_method": paymentMethod.name,
      "received_by": receivedBy,
      "created_at": createdAt,
      "remarks": remarks,
    };
  }

  factory FeePayment.fromJson(Map<String, dynamic> json) {
    return FeePayment(
      id: json["id"],

      amount: (json["amount"] as num).toDouble(),

      paymentDate: DateTime.parse(json["payment_date"]),

      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json["payment_method"],
        orElse: () => PaymentMethod.Cash,
      ),

      remarks: json["remarks"],

      receivedBy: json["received_by"],

      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
    );
  }

  FeePayment copyWith({
    double? amount,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    int? id,
    String? remarks,
    String? receivedBy,
    DateTime? createdAt,
  }) {
    return FeePayment(
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      id: id,
      remarks: remarks,
      receivedBy: receivedBy,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return '''
          FeePayment(
            Amount : $amount
            Date   : $paymentDate
            Method : $paymentMethod
          )
          ''';
  }
}
