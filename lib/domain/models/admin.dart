import 'staff.dart';

class Admin extends Staff {
  String department;
  String adminRole;
  List<String> permissions;

  Admin({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.hireDate,
    required this.department,
    this.adminRole = 'System Administrator',
    List<String>? permissions,
    super.isActive,
    super.assignedShifts,
    super.baseSalary,
    super.bonus,
  }) : permissions = permissions ?? ['view_all', 'edit_all', 'reports'];

  @override
  String get role => 'Admin';

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
Department: $department
Admin Role: $adminRole
Permissions: ${permissions.join(", ")}
Base Salary: $baseSalary
Bonus: $bonus
Total Salary: ${calculateTotalSalary()}
Active Leaves: ${leaves.where((l) => l.status.toString() == 'On Leave').length}''';
  }

  bool hasPermission(String permission) => permissions.contains(permission);

  void grantPermission(String permission) {
    if (!permissions.contains(permission)) {
      permissions.add(permission);
    }
  }

  void revokePermission(String permission) {
    permissions.remove(permission);
  }

  String manageStaffRecords(String employeeId) {
    return 'Accessing records for employee: $employeeId';
  }

  void processLeaveRequest(int leaveId, bool approved) {
    if (approved) {
    } else {}
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
