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
          await _leaveRequestMenu();
          break;
        case '8':
          await _manageSalaryMenu();
          break;
        case '9':
          _viewOverallStaff();
          break;
        case '10':
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
    print('7. Leave Request                          ');
    print('8. Manage Salary                          ');
    print('9. View overall staff                     ');
    print('10. Save Data                             ');
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

    if (name == null || name.isEmpty) {
      print('✗ Invalid input!');
      return;
    }

    String id = _staffService.generateId();
    print('ID: $id');

    stdout.write('Email: ');
    String? email = stdin.readLineSync();
    stdout.write('Phone: ');
    String? phone = stdin.readLineSync();

    if (email == null || phone == null) {
      print('✗ Invalid input!');
      return;
    }

    DateTime hireDate = DateTime.now();
    Staff? newStaff;

    // Normalize type input to handle both numbers and text
    String normalizedType = type?.toLowerCase().trim() ?? '';
    if (normalizedType == 'admin')
      normalizedType = '1';
    else if (normalizedType == 'doctor')
      normalizedType = '2';
    else if (normalizedType == 'nurse')
      normalizedType = '3';

    switch (normalizedType) {
      case '1':
        stdout.write('Department: ');
        String? dept = stdin.readLineSync();
        stdout.write('Base Salary: ');
        double? baseSalary = double.tryParse(stdin.readLineSync() ?? '0');

        if (dept != null && baseSalary != null) {
          newStaff = Admin(
            id: id,
            name: name,
            email: email,
            phone: phone,
            hireDate: hireDate,
            department: dept,
            baseSalary: baseSalary,
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
        stdout.write('Base Salary: ');
        double? docBaseSalary = double.tryParse(stdin.readLineSync() ?? '0');

        if (spec != null &&
            spec.isNotEmpty &&
            licenseNum != null &&
            licenseNum.isNotEmpty &&
            years != null &&
            years > 0 &&
            docBaseSalary != null) {
          newStaff = Doctor(
            id: id,
            name: name,
            email: email,
            phone: phone,
            hireDate: hireDate,
            specialization: spec,
            licenseNumber: licenseNum,
            yearsOfExperience: years,
            baseSalary: docBaseSalary,
          );
        } else {
          print('\n✗ Invalid Doctor input:');
          if (spec == null || spec.isEmpty)
            print('  - Specialization is required');
          if (licenseNum == null || licenseNum.isEmpty)
            print('  - License Number is required');
          if (years == null || years <= 0)
            print('  - Years of Experience must be a positive number');
          if (docBaseSalary == null)
            print('  - Base Salary must be a valid number');
          print('');
        }
        break;
      case '3':
        stdout.write('Ward: ');
        String? ward = stdin.readLineSync();
        stdout.write('Shift (Morning/Afternoon/Night): ');
        String? shiftInput = stdin.readLineSync();
        stdout.write('Nursing Level (RN/LPN/CNA): ');
        String? level = stdin.readLineSync();
        stdout.write('Base Salary: ');
        double? nurseBaseSalary = double.tryParse(stdin.readLineSync() ?? '0');

        if (ward != null &&
            shiftInput != null &&
            level != null &&
            nurseBaseSalary != null) {
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
            baseSalary: nurseBaseSalary,
          );
        }
        break;
    }

    if (newStaff != null) {
      _staffService.addStaff(newStaff);
      _staffService.incrementId();
      print('\n✓ Staff added successfully!\n');
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

    // Calculate statistics
    int totalStaff = allStaff.length;
    int activeStaff = allStaff.where((staff) => staff.isActive).length;
    int inactiveStaff = totalStaff - activeStaff;

    int adminCount = allStaff.where((staff) => staff.role == 'Admin').length;
    int doctorCount = allStaff.where((staff) => staff.role == 'Doctor').length;
    int nurseCount = allStaff.where((staff) => staff.role == 'Nurse').length;

    // Display statistics
    print('\n${'─' * 50}');
    print('📊 STAFF STATISTICS');
    print('${'─' * 50}');
    print('Total Staff: $totalStaff');
    print('  Active: $activeStaff');
    print('  Inactive: $inactiveStaff');
    print('');
    print('By Role:');
    print('  Admin: $adminCount');
    print('  Doctor: $doctorCount');
    print('  Nurse: $nurseCount');
    print('${'─' * 50}\n');

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

    // Only nurses can have shift management
    if (staff.role != 'Nurse') {
      print('\n✗ Error: Only Nurses can have shift management!');
      print('  Staff ID $id is a ${staff.role}, not a Nurse.\n');
      return;
    }

    print(
      '\nCurrent shifts: ${staff.assignedShifts.isEmpty ? 'None' : staff.assignedShifts.join(", ")}',
    );
    print('1. Add Shift');
    print('2. Remove Shift');
    stdout.write('Choose: ');
    String? choice = stdin.readLineSync();

    if (choice == '1') {
      stdout.write('Enter shift (ex: Monday-Morning): ');
      String? shift = stdin.readLineSync();
      if (shift != null && shift.isNotEmpty) {
        staff.addShift(shift);
        print('✓ Shift added!');
      } else {
        print('✗ Invalid shift input!');
      }
    } else if (choice == '2') {
      stdout.write('Enter shift to remove: ');
      String? shift = stdin.readLineSync();
      if (shift != null && shift.isNotEmpty) {
        if (staff.assignedShifts.contains(shift)) {
          staff.removeShift(shift);
          print('✓ Shift removed!');
        } else {
          print(
            '✗ Shift not found! Available shifts: ${staff.assignedShifts.isEmpty ? 'None' : staff.assignedShifts.join(", ")}',
          );
        }
      } else {
        print('✗ Invalid shift input!');
      }
    } else {
      print('✗ Invalid choice!');
    }

    await _saveData();
  }

  Future<void> _leaveRequestMenu() async {
    print('\n.... Leave Request ....');
    print('1. View All Pending Leave Requests');
    print('2. Apply Leave for Staff');
    print('3. View Leave History for Staff');
    stdout.write('Choose: ');
    String? choice = stdin.readLineSync();

    if (choice == '1') {
      // Show all pending leave requests
      print('\n📋 Pending Leave Requests:');
      print('${'─' * 70}');

      var allStaff = _staffService.allStaff;
      bool hasPending = false;

      for (var staff in allStaff) {
        var leaves = staff.getLeaves();
        var pendingLeaves = leaves
            .where((l) => l.status.displayName == 'pending')
            .toList();

        if (pendingLeaves.isNotEmpty) {
          hasPending = true;
          print('\nStaff: ${staff.name} (ID: ${staff.id}) - ${staff.role}');
          for (var leave in pendingLeaves) {
            print('  • ${leave.getLeaveDetails()}');
            print('    [Duration: ${leave.getDuration()} days]');
          }
        }
      }

      if (!hasPending) {
        print('No pending leave requests.');
      }
      print('${'─' * 70}');
    } else if (choice == '2') {
      // Apply leave for staff
      stdout.write('\nEnter staff ID: ');
      String? id = stdin.readLineSync();
      var staff = _staffService.findById(id ?? '');

      if (staff == null) {
        print('✗ Staff not found!');
        return;
      }

      stdout.write('Start Date (YYYY-MM-DD): ');
      String? startDateStr = stdin.readLineSync();
      stdout.write('End Date (YYYY-MM-DD): ');
      String? endDateStr = stdin.readLineSync();

      try {
        DateTime startDate = DateTime.parse(startDateStr ?? '');
        DateTime endDate = DateTime.parse(endDateStr ?? '');

        if (startDate.isBefore(endDate) ||
            startDate.isAtSameMomentAs(endDate)) {
          staff.applyLeave(startDate, endDate);
          print('✓ Leave applied successfully! (Status: Pending)');
        } else {
          print('✗ End date must be after or equal to start date!');
        }
      } catch (e) {
        print('✗ Invalid date format! Use YYYY-MM-DD');
      }
    } else if (choice == '3') {
      // View leave history for specific staff
      stdout.write('\nEnter staff ID: ');
      String? id = stdin.readLineSync();
      var staff = _staffService.findById(id ?? '');

      if (staff == null) {
        print('✗ Staff not found!');
        return;
      }

      var leaves = staff.getLeaves();
      if (leaves.isEmpty) {
        print('No leave records found for ${staff.name}.');
      } else {
        print('\n📅 Leave History for ${staff.name}:');
        print('${'─' * 70}');
        for (var leave in leaves) {
          print('${leave.getLeaveDetails()}');
          print('Duration: ${leave.getDuration()} days');
          print('');
        }
        print('${'─' * 70}');
      }
    } else {
      print('✗ Invalid choice!');
    }

    await _saveData();
  }

  Future<void> _manageSalaryMenu() async {
    print('\n.... Manage Salary ....');
    stdout.write('Enter staff ID: ');
    String? id = stdin.readLineSync();
    var staff = _staffService.findById(id ?? '');

    if (staff == null) {
      print('✗ Staff not found!');
      return;
    }

    print('\n1. View Salary Information');
    print('2. Update Base Salary');
    print('3. Update Bonus');
    stdout.write('Choose: ');
    String? choice = stdin.readLineSync();

    if (choice == '1') {
      double total = staff.calculateTotalSalary();
      print('\n💰 Salary Information for ${staff.name}:');
      print('${'─' * 50}');
      print('Base Salary: \$${staff.baseSalary.toStringAsFixed(2)}');
      print('Bonus: \$${staff.bonus.toStringAsFixed(2)}');
      print('─' * 50);
      print('Total Compensation: \$${total.toStringAsFixed(2)}');
      print('${'─' * 50}');
    } else if (choice == '2') {
      stdout.write('Enter new base salary: ');
      double? newSalary = double.tryParse(stdin.readLineSync() ?? '0');
      if (newSalary != null && newSalary >= 0) {
        staff.updateSalary(newSalary);
        print('✓ Base salary updated successfully!');
      } else {
        print('✗ Invalid salary amount!');
      }
    } else if (choice == '3') {
      stdout.write('Enter new bonus: ');
      double? newBonus = double.tryParse(stdin.readLineSync() ?? '0');
      if (newBonus != null && newBonus >= 0) {
        staff.updateBonus(newBonus);
        print('✓ Bonus updated successfully!');
      } else {
        print('✗ Invalid bonus amount!');
      }
    } else {
      print('✗ Invalid choice!');
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
    print('\n💾 Saving data before exit...');
    await _saveData();
    print('👋 Goodbye!\n');
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
