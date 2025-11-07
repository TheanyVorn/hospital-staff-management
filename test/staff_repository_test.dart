import 'package:test/test.dart';
import 'package:managing_staff_g2t3/data/staff_repository.dart';
import 'package:managing_staff_g2t3/domain/models/admin.dart';
import 'package:managing_staff_g2t3/domain/models/doctor.dart';
import 'package:managing_staff_g2t3/domain/models/nurse.dart';
import 'package:managing_staff_g2t3/domain/models/nurse_shift.dart';
import 'dart:io';

void main() {
  group('Data Layer - StaffRepository', () {
    late StaffRepository repository;
    final testFilePath = 'test_staff_data.json';

    setUp(() {
      repository = StaffRepository(testFilePath);
      // Clean up any existing test file
      try {
        if (File(testFilePath).existsSync()) {
          File(testFilePath).deleteSync();
        }
      } catch (e) {
        // File doesn't exist, that's okay
      }
    });

    tearDown(() {
      // Clean up test files after each test
      try {
        if (File(testFilePath).existsSync()) {
          File(testFilePath).deleteSync();
        }
      } catch (e) {
        // File doesn't exist, that's okay
      }
      // Clean up backup files
      final dir = Directory('.');
      try {
        for (var file in dir.listSync()) {
          if (file is File &&
              file.path.contains('test_staff_data.json.backup')) {
            file.deleteSync();
          }
        }
      } catch (e) {
        // Backup files don't exist, that's okay
      }
    });

    group('Load Data', () {
      test('Should return empty list when file does not exist', () async {
        var data = await repository.loadData();
        expect(data['staffList'], isNotNull);
        expect(data['staffList'], isEmpty);
        expect(data['nextId'], equals(1));
      });

      test('Should return empty list when file is empty', () async {
        File(testFilePath).writeAsStringSync('');
        var data = await repository.loadData();
        expect(data['staffList'], isEmpty);
        expect(data['nextId'], equals(1));
      });

      test('Should load data with valid staff members', () async {
        String jsonData = '''{
          "staffList": [
            {
              "type": "Admin",
              "id": "S0001",
              "name": "John Admin",
              "email": "john@hospital.com",
              "phone": "555-0001",
              "hireDate": "2020-01-15T00:00:00.000Z",
              "department": "IT",
              "permissions": ["view_all", "edit_all"],
              "isActive": true,
              "assignedShifts": []
            },
            {
              "type": "Doctor",
              "id": "S0002",
              "name": "Dr. Sarah",
              "email": "sarah@hospital.com",
              "phone": "555-0002",
              "hireDate": "2019-06-10T00:00:00.000Z",
              "specialization": "Cardiology",
              "licenseNumber": "MD-2019-001",
              "yearsOfExperience": 4,
              "certifications": ["ACLS"],
              "isActive": true,
              "assignedShifts": []
            }
          ],
          "nextId": 3
        }''';

        File(testFilePath).writeAsStringSync(jsonData);
        var data = await repository.loadData();

        expect(data['staffList'], isNotEmpty);
        expect(data['staffList'].length, equals(2));
        expect(data['nextId'], equals(3));
      });

      test('Should correctly deserialize Admin from JSON', () async {
        String jsonData = '''{
          "staffList": [
            {
              "type": "Admin",
              "id": "S0001",
              "name": "Admin Name",
              "email": "admin@hospital.com",
              "phone": "555-0001",
              "hireDate": "2020-01-15T00:00:00.000Z",
              "department": "Finance",
              "permissions": ["view_all", "delete_all"],
              "isActive": true,
              "assignedShifts": ["Monday-Day"]
            }
          ],
          "nextId": 2
        }''';

        File(testFilePath).writeAsStringSync(jsonData);
        var data = await repository.loadData();
        var admin = data['staffList'][0];

        expect(admin.role, equals('Admin'));
        expect(admin.name, equals('Admin Name'));
        expect(admin.department, equals('Finance'));
        expect(admin.assignedShifts, contains('Monday-Day'));
      });

      test('Should correctly deserialize Doctor from JSON', () async {
        String jsonData = '''{
          "staffList": [
            {
              "type": "Doctor",
              "id": "S0002",
              "name": "Dr. Test",
              "email": "dr@hospital.com",
              "phone": "555-0002",
              "hireDate": "2018-03-20T00:00:00.000Z",
              "specialization": "Surgery",
              "licenseNumber": "MD-2018-001",
              "yearsOfExperience": 5,
              "certifications": ["ACLS", "BLS"],
              "isActive": true,
              "assignedShifts": []
            }
          ],
          "nextId": 3
        }''';

        File(testFilePath).writeAsStringSync(jsonData);
        var data = await repository.loadData();
        var doctor = data['staffList'][0];

        expect(doctor.role, equals('Doctor'));
        expect(doctor.specialization, equals('Surgery'));
        expect(doctor.yearsOfExperience, equals(5));
        expect(doctor.certifications, contains('BLS'));
      });

      test('Should correctly deserialize Nurse from JSON', () async {
        String jsonData = '''{
          "staffList": [
            {
              "type": "Nurse",
              "id": "S0003",
              "name": "Emma Nurse",
              "email": "emma@hospital.com",
              "phone": "555-0003",
              "hireDate": "2019-09-05T00:00:00.000Z",
              "ward": "ICU",
              "shift": "Night",
              "nursingLevel": "RN",
              "isActive": true,
              "assignedShifts": []
            }
          ],
          "nextId": 4
        }''';

        File(testFilePath).writeAsStringSync(jsonData);
        var data = await repository.loadData();
        var nurse = data['staffList'][0];

        expect(nurse.role, equals('Nurse'));
        expect(nurse.ward, equals('ICU'));
        expect(nurse.shift, equals(NurseShift.night));
        expect(nurse.nursingLevel, equals('RN'));
      });

      test('Should handle error gracefully and return empty list', () async {
        File(testFilePath).writeAsStringSync('{ invalid json }');
        var data = await repository.loadData();

        expect(data['staffList'], isEmpty);
        expect(data['nextId'], equals(1));
      });
    });

    group('Save Data', () {
      test('Should save empty staff list', () async {
        bool success = await repository.saveData([], 1);
        expect(success, isTrue);

        final file = File(testFilePath);
        expect(file.existsSync(), isTrue);
      });

      test('Should save single staff member', () async {
        Admin admin = Admin(
          id: 'S0001',
          name: 'Save Test Admin',
          email: 'save@hospital.com',
          phone: '555-0001',
          hireDate: DateTime(2020, 1, 15),
          department: 'HR',
        );

        bool success = await repository.saveData([admin], 2);
        expect(success, isTrue);

        var loaded = await repository.loadData();
        expect(loaded['staffList'].length, equals(1));
        expect(loaded['staffList'][0].name, equals('Save Test Admin'));
      });

      test('Should save multiple staff members', () async {
        Admin admin = Admin(
          id: 'S0001',
          name: 'Admin',
          email: 'admin@hospital.com',
          phone: '555-0001',
          hireDate: DateTime(2020, 1, 15),
          department: 'IT',
        );
        Doctor doctor = Doctor(
          id: 'S0002',
          name: 'Dr. Smith',
          email: 'dr@hospital.com',
          phone: '555-0002',
          hireDate: DateTime(2019, 6, 10),
          specialization: 'Cardiology',
          licenseNumber: 'MD-001',
          yearsOfExperience: 5,
        );
        Nurse nurse = Nurse(
          id: 'S0003',
          name: 'Emma Nurse',
          email: 'emma@hospital.com',
          phone: '555-0003',
          hireDate: DateTime(2021, 3, 20),
          ward: 'Emergency',
          shift: NurseShift.morning,
          nursingLevel: 'LPN',
        );

        bool success = await repository.saveData([admin, doctor, nurse], 4);
        expect(success, isTrue);

        var loaded = await repository.loadData();
        expect(loaded['staffList'].length, equals(3));
        expect(loaded['nextId'], equals(4));
      });

      test('Should overwrite existing data when saving', () async {
        // Save first set
        Admin admin1 = Admin(
          id: 'S0001',
          name: 'First Admin',
          email: 'first@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'IT',
        );
        await repository.saveData([admin1], 2);

        // Save different data
        Doctor doctor = Doctor(
          id: 'S0002',
          name: 'Dr. New',
          email: 'dr@hospital.com',
          phone: '555-0002',
          hireDate: DateTime.now(),
          specialization: 'Surgery',
          licenseNumber: 'MD-002',
          yearsOfExperience: 3,
        );
        await repository.saveData([doctor], 3);

        var loaded = await repository.loadData();
        expect(loaded['staffList'].length, equals(1));
        expect(loaded['staffList'][0].role, equals('Doctor'));
      });

      test('Should handle save errors gracefully', () async {
        // Use an invalid path to trigger an error
        StaffRepository badRepo = StaffRepository('/invalid/path/file.json');
        bool success = await badRepo.saveData([], 1);
        expect(success, isFalse);
      });
    });

    group('Backup Data', () {
      test('Should not backup if file does not exist', () async {
        bool success = await repository.backupData();
        expect(success, isFalse);
      });

      test('Should create backup file', () async {
        // First create and save data
        Admin admin = Admin(
          id: 'S0001',
          name: 'Backup Test',
          email: 'backup@hospital.com',
          phone: '555-0001',
          hireDate: DateTime.now(),
          department: 'IT',
        );
        await repository.saveData([admin], 2);

        // Now backup
        bool success = await repository.backupData();
        expect(success, isTrue);

        // Check if backup file exists
        final dir = Directory('.');
        var backupFiles = dir
            .listSync()
            .where(
              (file) =>
                  file is File &&
                  file.path.contains('test_staff_data.json.backup'),
            )
            .toList();
        expect(backupFiles.isNotEmpty, isTrue);
      });

      test('Backup file should contain same data as original', () async {
        Admin admin = Admin(
          id: 'S0001',
          name: 'Backup Data Test',
          email: 'backup@hospital.com',
          phone: '555-0001',
          hireDate: DateTime(2020, 1, 15),
          department: 'Finance',
        );
        await repository.saveData([admin], 2);

        await repository.backupData();

        // Find and load backup file
        final dir = Directory('.');
        var backupFile =
            dir.listSync().firstWhere(
                  (file) =>
                      file is File &&
                      file.path.contains('test_staff_data.json.backup'),
                )
                as File;

        String backupContent = backupFile.readAsStringSync();
        String originalContent = File(testFilePath).readAsStringSync();

        expect(backupContent, equals(originalContent));
      });
    });

    group('Round-trip Serialization', () {
      test('Should preserve all Admin data through save/load cycle', () async {
        Admin admin = Admin(
          id: 'S0001',
          name: 'John Admin',
          email: 'john@hospital.com',
          phone: '555-0001',
          hireDate: DateTime(2020, 1, 15),
          department: 'IT',
          permissions: ['view_all', 'edit_all', 'delete_reports'],
          isActive: true,
          assignedShifts: ['Monday-Day', 'Wednesday-Evening'],
        );

        await repository.saveData([admin], 2);
        var loaded = await repository.loadData();
        Admin loadedAdmin = loaded['staffList'][0];

        expect(loadedAdmin.id, equals('S0001'));
        expect(loadedAdmin.name, equals('John Admin'));
        expect(loadedAdmin.email, equals('john@hospital.com'));
        expect(loadedAdmin.department, equals('IT'));
        expect(loadedAdmin.permissions.length, equals(3));
        expect(loadedAdmin.assignedShifts.length, equals(2));
      });

      test('Should preserve all Doctor data through save/load cycle', () async {
        Doctor doctor = Doctor(
          id: 'S0002',
          name: 'Dr. Sarah',
          email: 'sarah@hospital.com',
          phone: '555-0002',
          hireDate: DateTime(2018, 6, 10),
          specialization: 'Cardiology',
          licenseNumber: 'MD-2018-001',
          yearsOfExperience: 5,
          certifications: ['ACLS', 'BLS', 'PALS'],
          isActive: true,
        );

        await repository.saveData([doctor], 3);
        var loaded = await repository.loadData();
        Doctor loadedDoctor = loaded['staffList'][0];

        expect(loadedDoctor.id, equals('S0002'));
        expect(loadedDoctor.specialization, equals('Cardiology'));
        expect(loadedDoctor.yearsOfExperience, equals(5));
        expect(loadedDoctor.certifications.length, equals(3));
      });

      test('Should preserve all Nurse data through save/load cycle', () async {
        Nurse nurse = Nurse(
          id: 'S0003',
          name: 'Emma Nurse',
          email: 'emma@hospital.com',
          phone: '555-0003',
          hireDate: DateTime(2019, 3, 20),
          ward: 'ICU',
          shift: NurseShift.night,
          nursingLevel: 'RN',
          isActive: true,
          assignedShifts: ['Tuesday-Night', 'Thursday-Night'],
        );

        await repository.saveData([nurse], 4);
        var loaded = await repository.loadData();
        Nurse loadedNurse = loaded['staffList'][0];

        expect(loadedNurse.id, equals('S0003'));
        expect(loadedNurse.ward, equals('ICU'));
        expect(loadedNurse.shift, equals(NurseShift.night));
        expect(loadedNurse.nursingLevel, equals('RN'));
      });
    });
  });
}
