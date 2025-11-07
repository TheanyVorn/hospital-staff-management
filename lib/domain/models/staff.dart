import 'leave.dart';

abstract class Staff {
  final String id;
  String name;
  String email;
  String phone;
  DateTime hireDate;
  bool isActive;
  List<String> assignedShifts;
  double baseSalary;
  double bonus;
  List<Leave> leaves;
  int nextLeaveId;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.hireDate,
    this.isActive = true,
    List<String>? assignedShifts,
    this.baseSalary = 0.0,
    this.bonus = 0.0,
    List<Leave>? leaves,
    this.nextLeaveId = 1,
  }) : assignedShifts = assignedShifts ?? [],
       leaves = leaves ?? [];

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

  /// Apply for leave
  Leave applyLeave(DateTime startDate, DateTime endDate) {
    Leave leave = Leave(
      leaveId: nextLeaveId,
      employeeId: id,
      startDate: startDate,
      endDate: endDate,
    );
    leaves.add(leave);
    nextLeaveId++;
    return leave;
  }

  /// Get all leaves for this staff member
  List<Leave> getLeaves() {
    return List.unmodifiable(leaves);
  }

  /// Calculate total salary (base + bonus)
  double calculateTotalSalary() {
    return baseSalary + bonus;
  }

  /// Update base salary
  void updateSalary(double newAmount) {
    if (newAmount >= 0) {
      baseSalary = newAmount;
    }
  }

  /// Update bonus
  void updateBonus(double newBonus) {
    if (newBonus >= 0) {
      bonus = newBonus;
    }
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
Base Salary: $baseSalary
Bonus: $bonus
Total Salary: ${calculateTotalSalary()}
Assigned Shifts: ${assignedShifts.isEmpty ? "None" : assignedShifts.join(", ")}
Active Leaves: ${leaves.where((l) => l.status.toString() == 'On Leave').length}''';
  }
}
