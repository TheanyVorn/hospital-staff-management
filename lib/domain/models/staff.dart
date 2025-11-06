// ============================================
// DOMAIN LAYER - lib/domain/models/staff.dart
// ============================================

abstract class Staff {
  final String id;
  String name;
  String email;
  String phone;
  DateTime hireDate;
  bool isActive;
  List<String> assignedShifts;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.hireDate,
    this.isActive = true,
    List<String>? assignedShifts,
  }) : assignedShifts = assignedShifts ?? [];

  String get role;
  Map<String, dynamic> toJson();

  void addShift(String shift) {
    if (!assignedShifts.contains(shift)) {
      assignedShifts.add(shift);
    }
  }

  void removeShift(String shift) {
    assignedShifts.remove(shift);
  }

  String getStatusSummary() {
    return '''
ID: $id
Name: $name
Role: $role
Email: $email
Phone: $phone
Hire Date: ${hireDate.toLocal().toString().split(' ')[0]}
Status: ${isActive ? "Active" : "Inactive"}
Assigned Shifts: ${assignedShifts.isEmpty ? "None" : assignedShifts.join(", ")}''';
  }
}
