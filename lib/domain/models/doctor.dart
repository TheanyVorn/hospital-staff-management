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
Specialization: $specialization
License Number: $licenseNumber
Years of Experience: $yearsOfExperience
Base Salary: $baseSalary
Bonus: $bonus
Total Salary: ${calculateTotalSalary()}
Active Leaves: ${leaves.where((l) => l.status.toString() == 'On Leave').length}
Available: ${isAvailable ? "Yes" : "No"}
Current Patients: $currentPatients / $maxPatients''';
  }

  void addCertification(String cert) {
    if (!certifications.contains(cert)) {
      certifications.add(cert);
    }
  }

  bool isAvailableForAppointments() {
    return isAvailable && isActive;
  }

  bool canAcceptNewPatient() {
    return isAvailableForAppointments() && currentPatients < maxPatients;
  }

  bool addPatient() {
    if (canAcceptNewPatient()) {
      currentPatients++;
      return true;
    }
    return false;
  }

  void removePatient() {
    if (currentPatients > 0) {
      currentPatients--;
    }
  }

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
