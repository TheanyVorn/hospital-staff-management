import 'staff.dart';
import 'nurse_shift.dart';

class Nurse extends Staff {
  String ward;
  NurseShift shift;
  String nursingLevel;
  List<String> patientsUnderCare;

  Nurse({
    required String id,
    required String name,
    required String email,
    required String phone,
    required DateTime hireDate,
    required this.ward,
    required this.shift,
    required this.nursingLevel,
    bool isActive = true,
    List<String>? assignedShifts,
    double baseSalary = 0.0,
    double bonus = 0.0,
    List<String>? patientsUnderCare,
  }) : patientsUnderCare = patientsUnderCare ?? [],
       super(
         id: id,
         name: name,
         email: email,
         phone: phone,
         hireDate: hireDate,
         isActive: isActive,
         assignedShifts: assignedShifts,
         baseSalary: baseSalary,
         bonus: bonus,
       );

  @override
  String get role => 'Nurse';

  @override
  String getStatusSummary() {
    return '''
ID: $id
Name: $name
Role: $role
Email: $email
Phone: $phone
Hire Date: ${hireDate.toLocal().toString().split(' ')[0]}
Status: ${isActive ? "Active" : "Inactive"}
Ward: $ward
Shift: ${shift.displayName}
Nursing Level: $nursingLevel
Base Salary: $baseSalary
Bonus: $bonus
Total Salary: ${calculateTotalSalary()}
Assigned Shifts: ${assignedShifts.isEmpty ? "None" : assignedShifts.join(", ")}
Active Leaves: ${leaves.where((l) => l.status.toString() == 'On Leave').length}''';
  }

  void transferWard(String newWard) {
    ward = newWard;
  }

  void changeShift(NurseShift newShift) {
    shift = newShift;
  }

  /// Update patient care status
  void updatePatientCare(String patientId) {
    if (!patientsUnderCare.contains(patientId)) {
      patientsUnderCare.add(patientId);
    }
  }

  /// Remove patient from care
  void removePatientCare(String patientId) {
    patientsUnderCare.remove(patientId);
  }

  /// Get list of patients under care
  List<String> getPatientsUnderCare() {
    return List.unmodifiable(patientsUnderCare);
  }

  /// Get number of patients under care
  int getPatientCount() {
    return patientsUnderCare.length;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'Nurse',
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'hireDate': hireDate.toIso8601String(),
    'isActive': isActive,
    'assignedShifts': assignedShifts,
    'ward': ward,
    'shift': shift.toString(),
    'nursingLevel': nursingLevel,
    'baseSalary': baseSalary,
    'bonus': bonus,
    'patientsUnderCare': patientsUnderCare,
  };

  factory Nurse.fromJson(Map<String, dynamic> json) => Nurse(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    hireDate: DateTime.parse(json['hireDate']),
    ward: json['ward'],
    shift: _parseNurseShift(json['shift']),
    nursingLevel: json['nursingLevel'],
    isActive: json['isActive'] ?? true,
    assignedShifts: List<String>.from(json['assignedShifts'] ?? []),
    baseSalary: json['baseSalary'] ?? 0.0,
    bonus: json['bonus'] ?? 0.0,
    patientsUnderCare: List<String>.from(json['patientsUnderCare'] ?? []),
  );

  static NurseShift _parseNurseShift(String? shift) {
    switch (shift) {
      case 'Afternoon':
        return NurseShift.afternoon;
      case 'Night':
        return NurseShift.night;
      default:
        return NurseShift.morning;
    }
  }
}
