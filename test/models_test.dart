import 'package:test/test.dart';
import 'package:managing_staff_g2t3/domain/models/staff.dart';
import 'package:managing_staff_g2t3/domain/models/admin.dart';
import 'package:managing_staff_g2t3/domain/models/doctor.dart';
import 'package:managing_staff_g2t3/domain/models/nurse.dart';
import 'package:managing_staff_g2t3/domain/models/nurse_shift.dart';

void main() {
  group('Domain Models - Staff Management', () {
    group('Admin Model', () {
      late Admin admin;

      setUp(() {
        admin = Admin(
          id: 'S0001',
          name: 'John Administrator',
          email: 'john@hospital.com',
          phone: '555-0001',
          hireDate: DateTime(2020, 1, 15),
          department: 'IT',
        );
      });

      test('Admin should be created with correct properties', () {
        expect(admin.id, equals('S0001'));
        expect(admin.name, equals('John Administrator'));
        expect(admin.email, equals('john@hospital.com'));
        expect(admin.phone, equals('555-0001'));
        expect(admin.department, equals('IT'));
        expect(admin.role, equals('Admin'));
        expect(admin.isActive, isTrue);
      });

      test('Admin should have default permissions', () {
        expect(admin.permissions, contains('view_all'));
        expect(admin.permissions, contains('edit_all'));
        expect(admin.permissions, contains('reports'));
      });

      test('Admin should grant permission correctly', () {
        admin.grantPermission('delete_all');
        expect(admin.permissions, contains('delete_all'));
      });

      test('Admin should not grant duplicate permissions', () {
        int initialLength = admin.permissions.length;
        admin.grantPermission('view_all');
        expect(admin.permissions.length, equals(initialLength));
      });

      test('Admin should revoke permission correctly', () {
        admin.revokePermission('reports');
        expect(admin.permissions, isNot(contains('reports')));
      });

      test('Admin should check if has permission', () {
        expect(admin.hasPermission('view_all'), isTrue);
        expect(admin.hasPermission('nonexistent'), isFalse);
      });

      test('Admin should be serializable to JSON', () {
        Map<String, dynamic> json = admin.toJson();
        expect(json['type'], equals('Admin'));
        expect(json['id'], equals('S0001'));
        expect(json['name'], equals('John Administrator'));
        expect(json['department'], equals('IT'));
        expect(json['isActive'], isTrue);
      });

      test('Admin should be deserializable from JSON', () {
        Map<String, dynamic> json = {
          'type': 'Admin',
          'id': 'S0002',
          'name': 'Jane Manager',
          'email': 'jane@hospital.com',
          'phone': '555-0002',
          'hireDate': DateTime(2021, 6, 1).toIso8601String(),
          'department': 'HR',
          'permissions': ['view_all', 'edit_all'],
          'isActive': true,
          'assignedShifts': [],
        };
        Admin restored = Admin.fromJson(json);
        expect(restored.id, equals('S0002'));
        expect(restored.name, equals('Jane Manager'));
        expect(restored.department, equals('HR'));
      });

      test('Admin should add shift correctly', () {
        admin.addShift('Monday-Morning');
        expect(admin.assignedShifts, contains('Monday-Morning'));
      });

      test('Admin should not add duplicate shifts', () {
        admin.addShift('Tuesday-Evening');
        admin.addShift('Tuesday-Evening');
        expect(admin.assignedShifts.length, equals(1));
      });

      test('Admin should remove shift correctly', () {
        admin.addShift('Wednesday-Night');
        admin.removeShift('Wednesday-Night');
        expect(admin.assignedShifts, isNot(contains('Wednesday-Night')));
      });
    });

    group('Doctor Model', () {
      late Doctor doctor;

      setUp(() {
        doctor = Doctor(
          id: 'S0010',
          name: 'Dr. Sarah Smith',
          email: 'sarah@hospital.com',
          phone: '555-0010',
          hireDate: DateTime(2018, 3, 20),
          specialization: 'Cardiology',
          licenseNumber: 'MD-2018-001',
          yearsOfExperience: 5,
        );
      });

      test('Doctor should be created with correct properties', () {
        expect(doctor.id, equals('S0010'));
        expect(doctor.name, equals('Dr. Sarah Smith'));
        expect(doctor.specialization, equals('Cardiology'));
        expect(doctor.licenseNumber, equals('MD-2018-001'));
        expect(doctor.yearsOfExperience, equals(5));
        expect(doctor.role, equals('Doctor'));
        expect(doctor.isActive, isTrue);
      });

      test('Doctor should have empty certifications initially', () {
        expect(doctor.certifications, isEmpty);
      });

      test('Doctor should add certification correctly', () {
        doctor.addCertification('Advanced Cardiac Life Support');
        expect(
          doctor.certifications,
          contains('Advanced Cardiac Life Support'),
        );
      });

      test('Doctor should not add duplicate certifications', () {
        doctor.addCertification('BLS');
        doctor.addCertification('BLS');
        expect(doctor.certifications.length, equals(1));
      });

      test('Doctor should be serializable to JSON', () {
        doctor.addCertification('ACLS');
        Map<String, dynamic> json = doctor.toJson();
        expect(json['type'], equals('Doctor'));
        expect(json['specialization'], equals('Cardiology'));
        expect(json['licenseNumber'], equals('MD-2018-001'));
        expect(json['yearsOfExperience'], equals(5));
        expect(json['certifications'], contains('ACLS'));
      });

      test('Doctor should be deserializable from JSON', () {
        Map<String, dynamic> json = {
          'type': 'Doctor',
          'id': 'S0011',
          'name': 'Dr. Michael Brown',
          'email': 'michael@hospital.com',
          'phone': '555-0011',
          'hireDate': DateTime(2019, 7, 10).toIso8601String(),
          'specialization': 'Neurology',
          'licenseNumber': 'MD-2019-002',
          'yearsOfExperience': 3,
          'certifications': ['ACLS', 'BLS'],
          'isActive': true,
          'assignedShifts': [],
        };
        Doctor restored = Doctor.fromJson(json);
        expect(restored.specialization, equals('Neurology'));
        expect(restored.yearsOfExperience, equals(3));
      });

      test('Doctor should update specialization', () {
        doctor.specialization = 'Neurology';
        expect(doctor.specialization, equals('Neurology'));
      });
    });

    group('Nurse Model', () {
      late Nurse nurse;

      setUp(() {
        nurse = Nurse(
          id: 'S0020',
          name: 'Emma Johnson',
          email: 'emma@hospital.com',
          phone: '555-0020',
          hireDate: DateTime(2019, 9, 5),
          ward: 'ICU',
          shift: NurseShift.morning,
          nursingLevel: 'RN',
        );
      });

      test('Nurse should be created with correct properties', () {
        expect(nurse.id, equals('S0020'));
        expect(nurse.name, equals('Emma Johnson'));
        expect(nurse.ward, equals('ICU'));
        expect(nurse.shift, equals(NurseShift.morning));
        expect(nurse.nursingLevel, equals('RN'));
        expect(nurse.role, equals('Nurse'));
        expect(nurse.isActive, isTrue);
      });

      test('Nurse should transfer ward correctly', () {
        nurse.transferWard('Emergency');
        expect(nurse.ward, equals('Emergency'));
      });

      test('Nurse should change shift correctly', () {
        nurse.changeShift(NurseShift.night);
        expect(nurse.shift, equals(NurseShift.night));
      });

      test('Nurse should validate nursing levels', () {
        nurse = Nurse(
          id: 'S0021',
          name: 'Test Nurse',
          email: 'test@hospital.com',
          phone: '555-0021',
          hireDate: DateTime.now(),
          ward: 'General',
          shift: NurseShift.afternoon,
          nursingLevel: 'LPN',
        );
        expect(nurse.nursingLevel, equals('LPN'));
      });

      test('Nurse should be serializable to JSON', () {
        Map<String, dynamic> json = nurse.toJson();
        expect(json['type'], equals('Nurse'));
        expect(json['ward'], equals('ICU'));
        expect(json['shift'], equals('Morning'));
        expect(json['nursingLevel'], equals('RN'));
      });

      test('Nurse should be deserializable from JSON', () {
        Map<String, dynamic> json = {
          'type': 'Nurse',
          'id': 'S0022',
          'name': 'Robert Davis',
          'email': 'robert@hospital.com',
          'phone': '555-0022',
          'hireDate': DateTime(2020, 2, 14).toIso8601String(),
          'ward': 'Pediatrics',
          'shift': 'Evening',
          'nursingLevel': 'CNA',
          'isActive': true,
          'assignedShifts': [],
        };
        Nurse restored = Nurse.fromJson(json);
        expect(restored.ward, equals('Pediatrics'));
        expect(restored.nursingLevel, equals('CNA'));
      });
    });

    group('Staff Status Management', () {
      test('Staff should activate and deactivate correctly', () {
        Admin admin = Admin(
          id: 'S0030',
          name: 'Test Admin',
          email: 'test@hospital.com',
          phone: '555-0030',
          hireDate: DateTime.now(),
          department: 'Finance',
          isActive: false,
        );
        expect(admin.isActive, isFalse);
        admin.isActive = true;
        expect(admin.isActive, isTrue);
      });

      test('Staff should generate summary correctly', () {
        Doctor doctor = Doctor(
          id: 'S0031',
          name: 'Dr. Test',
          email: 'dr@hospital.com',
          phone: '555-0031',
          hireDate: DateTime(2020, 1, 1),
          specialization: 'General',
          licenseNumber: 'MD-2020-001',
          yearsOfExperience: 2,
        );
        String summary = doctor.getStatusSummary();
        expect(summary, contains('S0031'));
        expect(summary, contains('Dr. Test'));
        expect(summary, contains('Doctor'));
        expect(summary, contains('Active'));
      });
    });
  });
}
