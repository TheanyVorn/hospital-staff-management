import 'dart:io';
import 'dart:convert';
import 'package:managing_staff_g2t3/domain/models/staff.dart';
import 'package:managing_staff_g2t3/domain/models/admin.dart';
import 'package:managing_staff_g2t3/domain/models/doctor.dart';
import 'package:managing_staff_g2t3/domain/models/nurse.dart';
import 'package:managing_staff_g2t3/domain/models/department.dart';
import 'package:managing_staff_g2t3/domain/models/shift_schedule.dart';
import 'package:managing_staff_g2t3/domain/models/leave_request.dart';
import 'package:managing_staff_g2t3/domain/models/performance_metrics.dart';

class StaffRepository {
  final String _filePath;

  StaffRepository(this._filePath);

  /// Load all data including staff, departments, shifts, skills, leaves, and performance
  Future<Map<String, dynamic>> loadData() async {
    try {
      final file = File(_filePath);
      if (!await file.exists()) {
        return _getEmptyData();
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return _getEmptyData();
      }

      final data = jsonDecode(contents);

      // Parse staff
      final staffList = <Staff>[];
      for (var item in data['staffList'] ?? []) {
        switch (item['type']) {
          case 'Admin':
            staffList.add(Admin.fromJson(item));
            break;
          case 'Doctor':
            staffList.add(Doctor.fromJson(item));
            break;
          case 'Nurse':
            staffList.add(Nurse.fromJson(item));
            break;
        }
      }

      // Parse departments
      final departments = <Department>[];
      for (var item in data['departments'] ?? []) {
        departments.add(Department.fromJson(item));
      }

      // Parse shift schedules
      final shiftSchedules = <ShiftSchedule>[];
      for (var item in data['shiftSchedules'] ?? []) {
        shiftSchedules.add(ShiftSchedule.fromJson(item));
      }

      // Parse leave requests
      final leaveRequests = <LeaveRequest>[];
      for (var item in data['leaveRequests'] ?? []) {
        leaveRequests.add(LeaveRequest.fromJson(item));
      }

      // Parse performance metrics
      final performanceMetrics = <PerformanceMetrics>[];
      for (var item in data['performanceMetrics'] ?? []) {
        performanceMetrics.add(PerformanceMetrics.fromJson(item));
      }

      return {
        'staffList': staffList,
        'nextId': data['nextId'] ?? 1,
        'departments': departments,
        'shiftSchedules': shiftSchedules,
        'leaveRequests': leaveRequests,
        'performanceMetrics': performanceMetrics,
      };
    } catch (e) {
      print('Error loading data: $e');
      return _getEmptyData();
    }
  }

  /// Save all data to JSON file
  Future<bool> saveData({
    required List<Staff> staffList,
    required int nextId,
    List<Department>? departments,
    List<ShiftSchedule>? shiftSchedules,
    List<LeaveRequest>? leaveRequests,
    List<PerformanceMetrics>? performanceMetrics,
  }) async {
    try {
      final file = File(_filePath);
      final data = {
        'staffList': staffList.map((s) => s.toJson()).toList(),
        'nextId': nextId,
        'departments': departments?.map((d) => d.toJson()).toList() ?? [],
        'shiftSchedules': shiftSchedules?.map((s) => s.toJson()).toList() ?? [],
        'leaveRequests': leaveRequests?.map((l) => l.toJson()).toList() ?? [],
        'performanceMetrics':
            performanceMetrics?.map((p) => p.toJson()).toList() ?? [],
      };

      await file.writeAsString(jsonEncode(data));
      return true;
    } catch (e) {
      print('Error saving data: $e');
      return false;
    }
  }

  /// Create a backup of the current data file
  Future<bool> backupData() async {
    try {
      final file = File(_filePath);
      if (!await file.exists()) return false;

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = '${_filePath}.backup.$timestamp';
      await file.copy(backupPath);
      print('Backup created: $backupPath');
      return true;
    } catch (e) {
      print('Error creating backup: $e');
      return false;
    }
  }

  /// Get default empty data structure
  Map<String, dynamic> _getEmptyData() {
    return {
      'staffList': <Staff>[],
      'nextId': 1,
      'departments': <Department>[],
      'shiftSchedules': <ShiftSchedule>[],
      'leaveRequests': <LeaveRequest>[],
      'performanceMetrics': <PerformanceMetrics>[],
    };
  }

  /// Export data to a formatted report
  Future<String> exportDataReport(Map<String, dynamic> data) async {
    try {
      StringBuffer report = StringBuffer();
      report.writeln('=== HOSPITAL STAFF MANAGEMENT SYSTEM REPORT ===');
      report.writeln('Generated: ${DateTime.now().toLocal()}');
      report.writeln('');

      // Staff summary
      List<Staff> staffList = data['staffList'] ?? [];
      report.writeln('STAFF SUMMARY:');
      report.writeln('Total Staff: ${staffList.length}');
      report.writeln(
        'Active Staff: ${staffList.where((s) => s.isActive).length}',
      );
      report.writeln(
        'Inactive Staff: ${staffList.where((s) => !s.isActive).length}',
      );
      report.writeln('');

      // Department summary
      List<Department> departments = data['departments'] ?? [];
      report.writeln('DEPARTMENTS: ${departments.length}');
      for (var dept in departments) {
        report.writeln(
          '  - ${dept.name}: ${dept.currentStaffCount}/${dept.staffCapacity} staff',
        );
      }
      report.writeln('');

      // Shift summary
      List<ShiftSchedule> shifts = data['shiftSchedules'] ?? [];
      report.writeln('SHIFTS: ${shifts.length}');
      int understaffed = shifts.where((s) => !s.isFullyStaffed()).length;
      report.writeln('  - Fully Staffed: ${shifts.length - understaffed}');
      report.writeln('  - Understaffed: $understaffed');
      report.writeln('');

      // Leave summary
      List<LeaveRequest> leaves = data['leaveRequests'] ?? [];
      report.writeln('LEAVE REQUESTS: ${leaves.length}');
      report.writeln(
        '  - Pending: ${leaves.where((l) => l.status == LeaveRequestStatus.pending).length}',
      );
      report.writeln(
        '  - Approved: ${leaves.where((l) => l.status == LeaveRequestStatus.approved).length}',
      );
      report.writeln('');

      return report.toString();
    } catch (e) {
      print('Error generating report: $e');
      return '';
    }
  }
}

enum LeaveRequestStatus { pending, approved, rejected, cancelled }
