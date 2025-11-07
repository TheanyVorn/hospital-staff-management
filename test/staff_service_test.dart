import 'package:test/test.dart';
import 'package:managing_staff_g2t3/domain/services/staff_service.dart';
import 'package:managing_staff_g2t3/domain/models/staff.dart';
import 'package:managing_staff_g2t3/domain/models/admin.dart';
import 'package:managing_staff_g2t3/domain/models/doctor.dart';
import 'package:managing_staff_g2t3/domain/models/nurse.dart';
import 'package:managing_staff_g2t3/domain/models/nurse_shift.dart';

void main() {
  group('Domain Services - StaffService', () {
    late StaffService staffService;

    setUp(() {
      staffService = StaffService();
    });

    group('Add Staff', () {
      test('Should add staff and return ID', () {
        Admin admin = Admin(
          id: 'S0001',
          name: 'John Admin',
          email: 'john@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'IT',
        );

        String id = staffService.addStaff(admin);
        expect(id, equals('S0001'));
        expect(staffService.allStaff.length, equals(1));
      });

      test('Should add multiple staff members', () {
        Admin admin = Admin(
          id: 'S0001',
          name: 'Admin 1',
          email: 'admin1@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'IT',
        );
        Doctor doctor = Doctor(
          id: 'S0002',
          name: 'Dr. Smith',
          email: 'dr.smith@hospital.com',
          phone: '555-0002',
          hireDate: DateTime.now(),
          specialization: 'Cardiology',
          licenseNumber: 'MD-001',
          yearsOfExperience: 5,
        );

        staffService.addStaff(admin);
        staffService.addStaff(doctor);
        expect(staffService.allStaff.length, equals(2));
      });
    });

    group('Find Staff', () {
      late Admin admin;
      late Doctor doctor;
      late Nurse nurse;

      setUp(() {
        admin = Admin(
          id: 'S0001',
          name: 'John Admin',
          email: 'john@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'IT',
        );
        doctor = Doctor(
          id: 'S0002',
          name: 'Dr. Sarah',
          email: 'sarah@hospital.com',
          phone: '555-0002',
          hireDate: DateTime.now(),
          specialization: 'Neurology',
          licenseNumber: 'MD-002',
          yearsOfExperience: 3,
        );
        nurse = Nurse(
          id: 'S0003',
          name: 'Emma Nurse',
          email: 'emma@hospital.com',
          phone: '555-0003',
          hireDate: DateTime.now(),
          ward: 'ICU',
          shift: NurseShift.night,
          nursingLevel: 'RN',
        );

        staffService.addStaff(admin);
        staffService.addStaff(doctor);
        staffService.addStaff(nurse);
      });

      test('Should find staff by ID', () {
        Staff? found = staffService.findById('S0001');
        expect(found, isNotNull);
        expect(found?.name, equals('John Admin'));
      });

      test('Should return null if ID not found', () {
        Staff? found = staffService.findById('NONEXISTENT');
        expect(found, isNull);
      });

      test('Should find staff by name (case-insensitive)', () {
        List<Staff> results = staffService.findByName('Sarah');
        expect(results.length, equals(1));
        expect(results[0].name, contains('Sarah'));
      });

      test('Should find multiple staff by partial name', () {
        List<Staff> results = staffService.findByName('a');
        expect(results.length, greaterThan(1));
      });

      test('Should find staff by role', () {
        List<Staff> doctors = staffService.findByRole('Doctor');
        expect(doctors.length, equals(1));
        expect(doctors[0].role, equals('Doctor'));
      });

      test('Should find multiple by role', () {
        staffService.addStaff(
          Doctor(
            id: 'S0004',
            name: 'Dr. Michael',
            email: 'michael@hospital.com',
            phone: '555-0004',
            hireDate: DateTime.now(),
            specialization: 'Cardiology',
            licenseNumber: 'MD-003',
            yearsOfExperience: 7,
          ),
        );

        List<Staff> doctors = staffService.findByRole('Doctor');
        expect(doctors.length, equals(2));
      });

      test('Should return empty list for nonexistent role', () {
        List<Staff> results = staffService.findByRole('InvalidRole');
        expect(results, isEmpty);
      });
    });

    group('Update Staff', () {
      late Admin admin;

      setUp(() {
        admin = Admin(
          id: 'S0001',
          name: 'Original Name',
          email: 'original@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'IT',
        );
        staffService.addStaff(admin);
      });

      test('Should update staff successfully', () {
        Admin updatedAdmin = Admin(
          id: 'S0001',
          name: 'Updated Name',
          email: 'updated@hospital.com',
          phone: '555-1111',
          hireDate: DateTime.now(),
          department: 'HR',
        );

        bool success = staffService.updateStaff('S0001', updatedAdmin);
        expect(success, isTrue);

        Staff? found = staffService.findById('S0001');
        expect(found?.name, equals('Updated Name'));
        expect(found?.email, equals('updated@hospital.com'));
      });

      test('Should return false for nonexistent ID', () {
        Admin updatedAdmin = Admin(
          id: 'S0999',
          name: 'Fake',
          email: 'fake@hospital.com',
          phone: '555-9999',
          hireDate: DateTime.now(),
          department: 'None',
        );

        bool success = staffService.updateStaff('S0999', updatedAdmin);
        expect(success, isFalse);
      });
    });

    group('Activate/Deactivate Staff', () {
      late Doctor doctor;

      setUp(() {
        doctor = Doctor(
          id: 'S0001',
          name: 'Dr. Test',
          email: 'dr@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          specialization: 'General',
          licenseNumber: 'MD-001',
          yearsOfExperience: 2,
        );
        staffService.addStaff(doctor);
      });

      test('Should deactivate active staff', () {
        expect(staffService.findById('S0001')?.isActive, isTrue);

        bool success = staffService.deactivateStaff('S0001');
        expect(success, isTrue);
        expect(staffService.findById('S0001')?.isActive, isFalse);
      });

      test('Should activate inactive staff', () {
        staffService.deactivateStaff('S0001');
        expect(staffService.findById('S0001')?.isActive, isFalse);

        bool success = staffService.activateStaff('S0001');
        expect(success, isTrue);
        expect(staffService.findById('S0001')?.isActive, isTrue);
      });

      test('Should return false when deactivating already inactive staff', () {
        staffService.deactivateStaff('S0001');
        bool success = staffService.deactivateStaff('S0001');
        expect(success, isFalse);
      });

      test('Should return false when activating already active staff', () {
        bool success = staffService.activateStaff('S0001');
        expect(success, isFalse);
      });

      test('Should get active staff list', () {
        Nurse nurse = Nurse(
          id: 'S0002',
          name: 'Emma',
          email: 'emma@hospital.com',
          phone: '555-0002',
          hireDate: DateTime.now(),
          ward: 'ICU',
          shift: NurseShift.morning,
          nursingLevel: 'RN',
        );
        staffService.addStaff(nurse);
        staffService.deactivateStaff('S0001');

        List<Staff> active = staffService.getActiveStaff();
        expect(active.length, equals(1));
        expect(active[0].name, equals('Emma'));
      });

      test('Should get inactive staff list', () {
        Nurse nurse = Nurse(
          id: 'S0002',
          name: 'Emma',
          email: 'emma@hospital.com',
          phone: '555-0002',
          hireDate: DateTime.now(),
          ward: 'ICU',
          shift: NurseShift.morning,
          nursingLevel: 'RN',
        );
        staffService.addStaff(nurse);
        staffService.deactivateStaff('S0001');

        List<Staff> inactive = staffService.getInactiveStaff();
        expect(inactive.length, equals(1));
        expect(inactive[0].name, equals('Dr. Test'));
      });
    });

    group('Delete Staff', () {
      late Admin admin;
      late Doctor doctor;

      setUp(() {
        admin = Admin(
          id: 'S0001',
          name: 'Admin to Delete',
          email: 'delete@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'IT',
        );
        doctor = Doctor(
          id: 'S0002',
          name: 'Doctor to Keep',
          email: 'keep@hospital.com',
          phone: '555-0002',
          hireDate: DateTime.now(),
          specialization: 'Surgery',
          licenseNumber: 'MD-001',
          yearsOfExperience: 4,
        );
        staffService.addStaff(admin);
        staffService.addStaff(doctor);
      });

      test('Should delete staff successfully', () {
        expect(staffService.allStaff.length, equals(2));

        bool success = staffService.deleteStaff('S0001');
        expect(success, isTrue);
        expect(staffService.allStaff.length, equals(1));
        expect(staffService.findById('S0001'), isNull);
      });

      test('Should return false when deleting nonexistent staff', () {
        bool success = staffService.deleteStaff('S0999');
        expect(success, isFalse);
        expect(staffService.allStaff.length, equals(2));
      });
    });

    group('ID Generation', () {
      test('Should generate sequential IDs', () {
        String id1 = staffService.generateId();
        staffService.incrementId();
        String id2 = staffService.generateId();

        expect(id1, equals('S0001'));
        expect(id2, equals('S0002'));
      });

      test('Should pad ID with zeros', () {
        for (int i = 0; i < 15; i++) {
          staffService.incrementId();
        }
        String id = staffService.generateId();
        expect(id, equals('S0016'));
      });
    });

    group('Statistics', () {
      late Admin admin;
      late Doctor doctor1;
      late Doctor doctor2;
      late Nurse nurse;

      setUp(() {
        admin = Admin(
          id: 'S0001',
          name: 'Admin',
          email: 'admin@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'IT',
        );
        doctor1 = Doctor(
          id: 'S0002',
          name: 'Dr. 1',
          email: 'dr1@hospital.com',
          phone: '555-0002',
          hireDate: DateTime.now(),
          specialization: 'Cardiology',
          licenseNumber: 'MD-001',
          yearsOfExperience: 5,
        );
        doctor2 = Doctor(
          id: 'S0003',
          name: 'Dr. 2',
          email: 'dr2@hospital.com',
          phone: '555-0003',
          hireDate: DateTime.now(),
          specialization: 'Neurology',
          licenseNumber: 'MD-002',
          yearsOfExperience: 3,
        );
        nurse = Nurse(
          id: 'S0004',
          name: 'Nurse',
          email: 'nurse@hospital.com',
          phone: '555-0004',
          hireDate: DateTime.now(),
          ward: 'ICU',
          shift: NurseShift.night,
          nursingLevel: 'RN',
        );

        staffService.addStaff(admin);
        staffService.addStaff(doctor1);
        staffService.addStaff(doctor2);
        staffService.addStaff(nurse);
      });

      test('Should return correct total staff count', () {
        Map<String, int> stats = staffService.getStatistics();
        expect(stats['total'], equals(4));
      });

      test('Should return correct role breakdown', () {
        Map<String, int> stats = staffService.getStatistics();
        expect(stats['admins'], equals(1));
        expect(stats['doctors'], equals(2));
        expect(stats['nurses'], equals(1));
      });

      test('Should return correct active/inactive counts', () {
        staffService.deactivateStaff('S0002');

        Map<String, int> stats = staffService.getStatistics();
        expect(stats['active'], equals(3));
        expect(stats['inactive'], equals(1));
      });

      test('Should return all zero stats for empty service', () {
        StaffService emptyService = StaffService();
        Map<String, int> stats = emptyService.getStatistics();
        expect(stats['total'], equals(0));
        expect(stats['active'], equals(0));
        expect(stats['admins'], equals(0));
      });
    });

    group('Data Loading', () {
      test('Should load staff list correctly', () {
        Admin admin = Admin(
          id: 'S0001',
          name: 'Loaded Admin',
          email: 'loaded@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'Finance',
        );
        Doctor doctor = Doctor(
          id: 'S0002',
          name: 'Loaded Doctor',
          email: 'loaded.dr@hospital.com',
          phone: '555-0002',
          hireDate: DateTime.now(),
          specialization: 'Oncology',
          licenseNumber: 'MD-001',
          yearsOfExperience: 6,
        );

        List<Staff> staffList = [admin, doctor];
        staffService.loadStaffList(staffList, 3);

        expect(staffService.allStaff.length, equals(2));
        expect(staffService.nextId, equals(3));
        expect(staffService.findById('S0001')?.name, equals('Loaded Admin'));
      });

      test('Should clear existing staff when loading', () {
        Admin oldAdmin = Admin(
          id: 'S0099',
          name: 'Old Admin',
          email: 'old@hospital.com',
          phone: '555-0099',
          hireDate: DateTime.now(),
          department: 'Old',
        );
        staffService.addStaff(oldAdmin);
        expect(staffService.allStaff.length, equals(1));

        Admin newAdmin = Admin(
          id: 'S0001',
          name: 'New Admin',
          email: 'new@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'New',
        );
        staffService.loadStaffList([newAdmin], 2);

        expect(staffService.allStaff.length, equals(1));
        expect(staffService.findById('S0099'), isNull);
        expect(staffService.findById('S0001'), isNotNull);
      });
    });
  });
}
