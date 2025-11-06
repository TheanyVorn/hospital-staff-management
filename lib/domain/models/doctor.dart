// ============================================
// DOMAIN LAYER - lib/domain/models/doctor.dart
// ============================================

import 'staff.dart';

class Doctor extends Staff {
  String specialization;
  String licenseNumber;
  int yearsOfExperience;
  List<String> certifications;

  Doctor({
    required String id,
    required String name,
    required String email,
    required String phone,
    required DateTime hireDate,
    required this.specialization,
    required this.licenseNumber,
    required this.yearsOfExperience,
    List<String>? certifications,
    bool isActive = true,
    List<String>? assignedShifts,
  }) : certifications = certifications ?? [],
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
  String get role => 'Doctor';

  void addCertification(String cert) {
    if (!certifications.contains(cert)) {
      certifications.add(cert);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'Doctor',
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'hireDate': hireDate.toIso8601String(),
    'isActive': isActive,
    'assignedShifts': assignedShifts,
    'specialization': specialization,
    'licenseNumber': licenseNumber,
    'yearsOfExperience': yearsOfExperience,
    'certifications': certifications,
  };

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    hireDate: DateTime.parse(json['hireDate']),
    specialization: json['specialization'],
    licenseNumber: json['licenseNumber'],
    yearsOfExperience: json['yearsOfExperience'],
    certifications: List<String>.from(json['certifications'] ?? []),
    isActive: json['isActive'] ?? true,
    assignedShifts: List<String>.from(json['assignedShifts'] ?? []),
  );
}
