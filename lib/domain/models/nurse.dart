// ============================================
// DOMAIN LAYER - lib/domain/models/nurse.dart
// ============================================

import 'staff.dart';

class Nurse extends Staff {
  String ward;
  String shift;
  String nursingLevel;

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
  }) : super(
         id: id,
         name: name,
         email: email,
         phone: phone,
         hireDate: hireDate,
         isActive: isActive,
         assignedShifts: assignedShifts,
       );

  @override
  String get role => 'Nurse';

  void transferWard(String newWard) {
    ward = newWard;
  }

  void changeShift(String newShift) {
    shift = newShift;
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
    'shift': shift,
    'nursingLevel': nursingLevel,
  };

  factory Nurse.fromJson(Map<String, dynamic> json) => Nurse(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    hireDate: DateTime.parse(json['hireDate']),
    ward: json['ward'],
    shift: json['shift'],
    nursingLevel: json['nursingLevel'],
    isActive: json['isActive'] ?? true,
    assignedShifts: List<String>.from(json['assignedShifts'] ?? []),
  );
}
