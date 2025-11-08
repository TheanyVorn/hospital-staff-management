//AI-GENERATED

import 'dart:io';
import '../domain/models/staff.dart';
import '../domain/models/admin.dart';
import '../domain/models/doctor.dart';
import '../domain/models/nurse.dart';
import '../domain/models/nurse_shift.dart';
import '../domain/services/staff_service.dart';
import '../data/staff_repository.dart';

class ConsoleUI {
  final StaffService _staffService;
  final StaffRepository _repository;

  ConsoleUI(this._staffService, this._repository);

  get license => null;

  Future<void> start() async {
    await _loadData();

    print('.............................................');
    print('.  Hospital Staff Management System         .');
    print('.   Deep Dive: Staff Management Module      .');
    print('.............................................');

    while (true) {
      _showMainMenu();
      String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          await _addStaffMenu();
          break;
        case '2':
          _viewAllStaff();
          break;
        case '3':
          _searchStaffMenu();
          break;
        case '4':
          await _updateStaffMenu();
          break;
        case '5':
          await _manageStaffStatusMenu();
          break;
        case '6':
          await _manageShiftsMenu();
          break;
        case '7':
          _viewOverallStaff();
          break;
        case '8':
          await _saveData();
          break;
        case '0':
          await _exit();
          return;
        default:
          print('\n❌ Invalid choice!');
      }
    }
  }

  void _showMainMenu() {
    print('\n.............. MAIN MENU ...................');
    print('1. Add New Staff                          ');
    print('2. View All Staff                         ');
    print('3. Search Staff                           ');
    print('4. Update Staff Information               ');
    print('5. Manage Staff Status (Activate/Deact)   ');
    print('6. Manage Staff Shifts                    ');
    print('7. View overall staff                     ');
    print('8. Save Data                              ');
    print('0. Exit                                   ');
    stdout.write('Enter choice: ');
  }

  Future<void> _addStaffMenu() async {
    print('\n.... Add New Staff ....');
    print('1. Admin');
    print('2. Doctor');
    print('3. Nurse');
    stdout.write('Select type: ');
    String? type = stdin.readLineSync();

    stdout.write('Name: ');
    String? name = stdin.readLineSync();
    stdout.write('Email: ');
    String? email = stdin.readLineSync();
    stdout.write('Phone: ');
    String? phone = stdin.readLineSync();

    if (name == null || email == null || phone == null) {
      print(' Invalid input!');
      return;
    }

    String id = _staffService.generateId();
    DateTime hireDate = DateTime.now();
    Staff? newStaff;

    switch (type) {
      case '1':
        stdout.write('Department: ');
        String? dept = stdin.readLineSync();
        if (dept != null) {
          newStaff = Admin(
            id: id,
            name: name,
            email: email,
            phone: phone,
            hireDate: hireDate,
            department: dept,
          );
        }
        break;
      case '2':
        stdout.write('Specialization: ');
        String? spec = stdin.readLineSync();
        stdout.write('License Number: ');
        String? licenseNum = stdin.readLineSync();
        stdout.write('Years of Experience: ');
        String? yearsStr = stdin.readLineSync();
        int? years = int.tryParse(yearsStr ?? '0');

        if (spec != null &&
            spec.isNotEmpty &&
            licenseNum != null &&
            licenseNum.isNotEmpty &&
            years != null &&
            years > 0) {
          newStaff = Doctor(
            id: id,
            name: name,
            email: email,
            phone: phone,
            hireDate: hireDate,
            specialization: spec,
            licenseNumber: licenseNum,
            yearsOfExperience: years,
          );
        } else {
          print(
            '\n✗ Invalid Doctor input. Please ensure all fields are filled correctly.\n',
          );
        }
        break;
      case '3':
        stdout.write('Ward: ');
        String? ward = stdin.readLineSync();
        stdout.write('Shift (Morning/Afternoon/Night): ');
        String? shiftInput = stdin.readLineSync();
        stdout.write('Nursing Level (RN/LPN/CNA): ');
        String? level = stdin.readLineSync();

        if (ward != null && shiftInput != null && level != null) {
          NurseShift nurseShift = _parseNurseShift(shiftInput);
          newStaff = Nurse(
            id: id,
            name: name,
            email: email,
            phone: phone,
            hireDate: hireDate,
            ward: ward,
            shift: nurseShift,
            nursingLevel: level,
          );
        }
        break;
    }

    if (newStaff != null) {
      _staffService.addStaff(newStaff);
      _staffService.incrementId();
      print('\n✓ Staff added successfully! ID: $id\n');
      await _saveData();
    } else {
      print('\n✗ Failed to add staff. Invalid input provided.\n');
    }
  }

  void _viewAllStaff() {
    print('\n.... All Staff Members ....');
    var allStaff = _staffService.allStaff;
    if (allStaff.isEmpty) {
      print('No staff found!');
      return;
    }

    for (var staff in allStaff) {
      print('\n${'─' * 50}');
      print(staff.getStatusSummary());
    }
  }

  void _searchStaffMenu() {
    print('\n.... Search Staff ....');
    print('1. By ID');
    print('2. By Name');
    print('3. By Role');
    stdout.write('Choose: ');
    String? choice = stdin.readLineSync();

    List<Staff> results = [];

    switch (choice) {
      case '1':
        stdout.write('Enter ID: ');
        String? id = stdin.readLineSync();
        var staff = _staffService.findById(id ?? '');
        if (staff != null) results.add(staff);
        break;
      case '2':
        stdout.write('Enter name: ');
        String? name = stdin.readLineSync();
        if (name != null) results = _staffService.findByName(name);
        break;
      case '3':
        stdout.write('Enter role (Admin/Doctor/Nurse): ');
        String? role = stdin.readLineSync();
        if (role != null) results = _staffService.findByRole(role);
        break;
    }

    if (results.isEmpty) {
      print('\n No results found!');
    } else {
      print('\n Found ${results.length} result(s):');
      for (var staff in results) {
        print('\n${'─' * 50}');
        print(staff.getStatusSummary());
      }
    }
  }

  Future<void> _updateStaffMenu() async {
    stdout.write('\nEnter staff ID to update: ');
    String? id = stdin.readLineSync();
    var staff = _staffService.findById(id ?? '');

    if (staff == null) {
      print(' Staff not found!');
      return;
    }

    print('\nCurrent Info:');
    print(staff.getStatusSummary());

    print('\n1. Update Name');
    print('2. Update Email');
    print('3. Update Phone');
    stdout.write('Choose: ');
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write('New name: ');
        String? name = stdin.readLineSync();
        if (name != null) staff.name = name;
        break;
      case '2':
        stdout.write('New email: ');
        String? email = stdin.readLineSync();
        if (email != null) staff.email = email;
        break;
      case '3':
        stdout.write('New phone: ');
        String? phone = stdin.readLineSync();
        if (phone != null) staff.phone = phone;
        break;
    }

    print('\n Updated successfully!');
    await _saveData();
  }

  Future<void> _manageStaffStatusMenu() async {
    stdout.write('\nEnter staff ID: ');
    String? id = stdin.readLineSync();
    var staff = _staffService.findById(id ?? '');

    if (staff == null) {
      print(' Staff not found!');
      return;
    }

    print('\nCurrent status: ${staff.isActive ? "Active" : "Inactive"}');
    print('1. Activate');
    print('2. Deactivate');
    stdout.write('Choose: ');
    String? choice = stdin.readLineSync();

    if (choice == '1') {
      _staffService.activateStaff(id!);
      print(' Staff activated!');
    } else if (choice == '2') {
      _staffService.deactivateStaff(id!);
      print(' Staff deactivated!');
    }

    await _saveData();
  }

  Future<void> _manageShiftsMenu() async {
    stdout.write('\nEnter staff ID: ');
    String? id = stdin.readLineSync();
    var staff = _staffService.findById(id ?? '');

    if (staff == null) {
      print(' Staff not found!');
      return;
    }

    print('\nCurrent shifts: ${staff.assignedShifts.join(", ")}');
    print('1. Add Shift');
    print('2. Remove Shift');
    stdout.write('Choose: ');
    String? choice = stdin.readLineSync();

    if (choice == '1') {
      stdout.write('Enter shift (ex: Monday-Morning): ');
      String? shift = stdin.readLineSync();
      if (shift != null) {
        staff.addShift(shift);
        print(' Shift added!');
      }
    } else if (choice == '2') {
      stdout.write('Enter shift to remove: ');
      String? shift = stdin.readLineSync();
      if (shift != null) {
        staff.removeShift(shift);
        print(' Shift removed!');
      }
    }

    await _saveData();
  }

  void _viewOverallStaff() {
    print('\n.... Overall Staff Summary ....');
    var stats = _staffService.getStatistics();

    print('Total Staff: ${stats['total']}');
    print('Active: ${stats['active']}');
    print('Inactive: ${stats['inactive']}');
    print('Admins: ${stats['admins']}');
    print('Doctors: ${stats['doctors']}');
    print('Nurses: ${stats['nurses']}');
  }

  Future<void> _loadData() async {
    print('\n Loading data...');
    var data = await _repository.loadData();
    _staffService.loadStaffList(data['staffList'], data['nextId']);
    print(' Data loaded! ${data['staffList'].length} staff members found.');
  }

  Future<void> _saveData() async {
    var success = await _repository.saveData(
      _staffService.allStaff,
      _staffService.nextId,
    );
    if (success) {
      print('Data saved successfully!');
    } else {
      print('Failed to save data!');
    }
  }

  Future<void> _exit() async {
    stdout.write('\nSave data before exiting? (y/n): ');
    String? response = stdin.readLineSync();
    if (response?.toLowerCase() == 'y') {
      await _saveData();
    }
    print('\n Goodbye!');
  }

  NurseShift _parseNurseShift(String input) {
    switch (input.toLowerCase()) {
      case 'afternoon':
        return NurseShift.afternoon;
      case 'night':
        return NurseShift.night;
      default:
        return NurseShift.morning;
    }
  }
}
