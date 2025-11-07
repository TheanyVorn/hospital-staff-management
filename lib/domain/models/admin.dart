import 'staff.dart';

class Admin extends Staff {
  String department;
  String adminRole;
  List<String> permissions;

  Admin({
    required String id,
    required String name,
    required String email,
    required String phone,
    required DateTime hireDate,
    required this.department,
    this.adminRole = 'System Administrator',
    List<String>? permissions,
    bool isActive = true,
    List<String>? assignedShifts,
    double baseSalary = 0.0,
    double bonus = 0.0,
  }) : permissions = permissions ?? ['view_all', 'edit_all', 'reports'],
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
  String get role => 'Admin';

  bool hasPermission(String permission) => permissions.contains(permission);

  void grantPermission(String permission) {
    if (!permissions.contains(permission)) {
      permissions.add(permission);
    }
  }

  void revokePermission(String permission) {
    permissions.remove(permission);
  }

  /// Manage staff records (view/edit employee information)
  String manageStaffRecords(String employeeId) {
    return 'Accessing records for employee: $employeeId';
  }

  /// Process leave request from an employee
  void processLeaveRequest(int leaveId, bool approved) {
    // In a real system, this would update the leave record in a database
    if (approved) {
      // Log or update leave status to approved
    } else {
      // Log or update leave status to cancelled
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'Admin',
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'hireDate': hireDate.toIso8601String(),
    'isActive': isActive,
    'assignedShifts': assignedShifts,
    'department': department,
    'adminRole': adminRole,
    'permissions': permissions,
    'baseSalary': baseSalary,
    'bonus': bonus,
  };

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    hireDate: DateTime.parse(json['hireDate']),
    department: json['department'],
    adminRole: json['adminRole'] ?? 'System Administrator',
    permissions: List<String>.from(json['permissions'] ?? []),
    isActive: json['isActive'] ?? true,
    assignedShifts: List<String>.from(json['assignedShifts'] ?? []),
    baseSalary: json['baseSalary'] ?? 0.0,
    bonus: json['bonus'] ?? 0.0,
  );
}
