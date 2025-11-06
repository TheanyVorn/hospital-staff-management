// ============================================
// DOMAIN LAYER - lib/domain/models/admin.dart
// ============================================

import 'staff.dart';

class Admin extends Staff {
  String department;
  List<String> permissions;

  Admin({
    required String id,
    required String name,
    required String email,
    required String phone,
    required DateTime hireDate,
    required this.department,
    List<String>? permissions,
    bool isActive = true,
    List<String>? assignedShifts,
  }) : permissions = permissions ?? ['view_all', 'edit_all', 'reports'],
       super(
         id: id,
         name: name,
         email: email,
         phone: phone,
         hireDate: hireDate,
         isActive: isActive,
         assignedShifts: assignedShifts,
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
    'permissions': permissions,
  };

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    hireDate: DateTime.parse(json['hireDate']),
    department: json['department'],
    permissions: List<String>.from(json['permissions'] ?? []),
    isActive: json['isActive'] ?? true,
    assignedShifts: List<String>.from(json['assignedShifts'] ?? []),
  );
}
