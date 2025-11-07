import 'staff.dart';

class Doctor extends Staff {
  String specialization;
  String licenseNumber;
  int yearsOfExperience;
  List<String> certifications;
  bool isAvailable;
  int maxPatients;
  int currentPatients;

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
    double baseSalary = 0.0,
    double bonus = 0.0,
    this.isAvailable = true,
    this.maxPatients = 20,
    this.currentPatients = 0,
  }) : certifications = certifications ?? [],
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
  String get role => 'Doctor';

  void addCertification(String cert) {
    if (!certifications.contains(cert)) {
      certifications.add(cert);
    }
  }

  /// Check if doctor is available for appointments
  bool isAvailableForAppointments() {
    return isAvailable && isActive;
  }

  /// Check if doctor can accept new patients
  bool canAcceptNewPatient() {
    return isAvailableForAppointments() && currentPatients < maxPatients;
  }

  /// Add a new patient
  bool addPatient() {
    if (canAcceptNewPatient()) {
      currentPatients++;
      return true;
    }
    return false;
  }

  /// Remove a patient
  void removePatient() {
    if (currentPatients > 0) {
      currentPatients--;
    }
  }

  /// Set doctor availability
  void setAvailability(bool available) {
    isAvailable = available;
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
    'baseSalary': baseSalary,
    'bonus': bonus,
    'isAvailable': isAvailable,
    'maxPatients': maxPatients,
    'currentPatients': currentPatients,
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
    baseSalary: json['baseSalary'] ?? 0.0,
    bonus: json['bonus'] ?? 0.0,
    isAvailable: json['isAvailable'] ?? true,
    maxPatients: json['maxPatients'] ?? 20,
    currentPatients: json['currentPatients'] ?? 0,
  );
}
