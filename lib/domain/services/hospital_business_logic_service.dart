import 'package:managing_staff_g2t3/domain/models/department.dart';
import 'package:managing_staff_g2t3/domain/models/shift_schedule.dart';
import 'package:managing_staff_g2t3/domain/models/leave_request.dart';
import 'package:managing_staff_g2t3/domain/models/performance_metrics.dart';

/// Complex business logic service for managing hospital operations
class HospitalBusinessLogicService {
  final List<Department> departments;
  final List<ShiftSchedule> shiftSchedules;
  final List<LeaveRequest> leaveRequests;
  final List<PerformanceMetrics> performanceMetrics;

  HospitalBusinessLogicService({
    List<Department>? departments,
    List<ShiftSchedule>? shiftSchedules,
    List<LeaveRequest>? leaveRequests,
    List<PerformanceMetrics>? performanceMetrics,
  }) : departments = departments ?? [],
       shiftSchedules = shiftSchedules ?? [],
       leaveRequests = leaveRequests ?? [],
       performanceMetrics = performanceMetrics ?? [];

  // ==================== DEPARTMENT LOGIC ====================

  /// Add a new department
  bool addDepartment(Department department) {
    final errors = department.validate();
    if (errors.isNotEmpty) {
      print('Department validation failed: $errors');
      return false;
    }
    if (!departments.any((d) => d.id == department.id)) {
      departments.add(department);
      return true;
    }
    return false;
  }

  /// Get department by ID
  Department? getDepartmentById(String id) {
    try {
      return departments.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all available departments (with capacity)
  List<Department> getAvailableDepartments() {
    return departments.where((d) => d.hasCapacity() && d.isActive).toList();
  }

  /// Get department occupancy report
  Map<String, dynamic> getDepartmentOccupancyReport() {
    return {
      'totalDepartments': departments.length,
      'averageOccupancy': departments.isEmpty
          ? 0.0
          : departments.fold(
                  0.0,
                  (sum, d) => sum + d.getOccupancyPercentage(),
                ) /
                departments.length,
      'departments': departments
          .map(
            (d) => {
              'id': d.id,
              'name': d.name,
              'occupancy': d.getOccupancyPercentage(),
              'currentStaff': d.currentStaffCount,
              'capacity': d.staffCapacity,
            },
          )
          .toList(),
    };
  }

  // ==================== SHIFT SCHEDULING LOGIC ====================

  /// Add a new shift schedule
  bool addShiftSchedule(ShiftSchedule schedule) {
    final errors = schedule.validate();
    if (errors.isNotEmpty) {
      print('Shift schedule validation failed: $errors');
      return false;
    }
    if (!shiftSchedules.any((s) => s.id == schedule.id)) {
      shiftSchedules.add(schedule);
      return true;
    }
    return false;
  }

  /// Get shift schedule by ID
  ShiftSchedule? getShiftScheduleById(String id) {
    try {
      return shiftSchedules.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get understaffed shifts
  List<ShiftSchedule> getUnderstaffedShifts() {
    return shiftSchedules.where((s) => !s.isFullyStaffed()).toList();
  }

  /// Get shifts for a specific date
  List<ShiftSchedule> getShiftsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return shiftSchedules
        .where(
          (s) => DateTime(s.date.year, s.date.month, s.date.day) == dateOnly,
        )
        .toList();
  }

  /// Get shifts for a specific staff member
  List<ShiftSchedule> getShiftsForStaff(String staffId) {
    return shiftSchedules
        .where((s) => s.assignedStaff.contains(staffId))
        .toList();
  }

  /// Get weekly schedule report
  Map<String, dynamic> getWeeklyScheduleReport(DateTime startDate) {
    final weekShifts = <String, List<ShiftSchedule>>{};
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final dayName = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ][date.weekday - 1];
      weekShifts[dayName] = getShiftsForDate(date);
    }
    return {
      'week':
          '${startDate.toLocal().toString().split(' ')[0]} to ${startDate.add(Duration(days: 7)).toLocal().toString().split(' ')[0]}',
      'totalShifts': shiftSchedules.length,
      'fullyStaffed': shiftSchedules.where((s) => s.isFullyStaffed()).length,
      'understaffed': getUnderstaffedShifts().length,
      'dailySchedules': weekShifts,
    };
  }

  // ==================== LEAVE REQUEST LOGIC ====================

  /// Submit a leave request
  bool submitLeaveRequest(LeaveRequest leaveRequest) {
    final errors = leaveRequest.validate();
    if (errors.isNotEmpty) {
      print('Leave request validation failed: $errors');
      return false;
    }
    if (!leaveRequests.any((l) => l.id == leaveRequest.id)) {
      leaveRequests.add(leaveRequest);
      return true;
    }
    return false;
  }

  /// Approve leave request with validation
  bool approveLeaveRequest(
    String leaveId,
    String approverId,
    String? replacementStaffId,
  ) {
    try {
      final leaveRequest = leaveRequests.firstWhere((l) => l.id == leaveId);

      // Check if replacement staff is necessary
      if (replacementStaffId == null &&
          !_canCoverWithoutReplacement(leaveRequest.staffId)) {
        print('Error: Replacement staff required for this leave period');
        return false;
      }

      return leaveRequest.approve(approverId, replacementStaffId);
    } catch (e) {
      return false;
    }
  }

  /// Reject leave request with reason
  bool rejectLeaveRequest(String leaveId, String approverId, String reason) {
    try {
      final leaveRequest = leaveRequests.firstWhere((l) => l.id == leaveId);
      return leaveRequest.reject(approverId, reason);
    } catch (e) {
      return false;
    }
  }

  /// Get pending leave requests
  List<LeaveRequest> getPendingLeaveRequests() {
    return leaveRequests
        .where((l) => l.status == LeaveRequestStatus.pending)
        .toList();
  }

  /// Get leave requests for a staff member
  List<LeaveRequest> getLeaveRequestsForStaff(String staffId) {
    return leaveRequests.where((l) => l.staffId == staffId).toList();
  }

  /// Get overlapping leave requests
  List<LeaveRequest> getOverlappingLeaveRequests(
    DateTime startDate,
    DateTime endDate,
  ) {
    return leaveRequests.where((l) {
      return l.status == LeaveRequestStatus.approved &&
          !l.endDate.isBefore(startDate) &&
          !l.startDate.isAfter(endDate);
    }).toList();
  }

  bool _canCoverWithoutReplacement(String staffId) {
    // Check if there are enough staff members to cover shifts
    // This is a simplified check
    return false;
  }

  // ==================== PERFORMANCE METRICS LOGIC ====================

  /// Add or update performance metrics
  bool updatePerformanceMetrics(PerformanceMetrics metrics) {
    final errors = metrics.validate();
    if (errors.isNotEmpty) {
      print('Performance metrics validation failed: $errors');
      return false;
    }
    final index = performanceMetrics.indexWhere(
      (m) => m.staffId == metrics.staffId && m.period == metrics.period,
    );
    if (index != -1) {
      performanceMetrics[index] = metrics;
    } else {
      performanceMetrics.add(metrics);
    }
    return true;
  }

  /// Get performance metrics for a staff member
  PerformanceMetrics? getPerformanceMetricsForStaff(
    String staffId,
    String period,
  ) {
    try {
      return performanceMetrics.firstWhere(
        (m) => m.staffId == staffId && m.period == period,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get staff with concerning performance
  List<PerformanceMetrics> getStaffWithConcerningPerformance() {
    return performanceMetrics
        .where((m) => m.isPerformanceConcerning())
        .toList();
  }

  /// Get performance report for a period
  Map<String, dynamic> getPerformanceReportForPeriod(String period) {
    final metricsForPeriod = performanceMetrics
        .where((m) => m.period == period)
        .toList();

    if (metricsForPeriod.isEmpty) {
      return {'period': period, 'count': 0, 'data': []};
    }

    double avgQualityScore =
        metricsForPeriod.fold(0.0, (sum, m) => sum + m.qualityScore) /
        metricsForPeriod.length;
    int avgAttendanceRate =
        (metricsForPeriod.fold(0, (sum, m) => sum + m.attendanceRate) /
                metricsForPeriod.length)
            .toInt();
    double avgOverallRating =
        metricsForPeriod.fold(0.0, (sum, m) => sum + m.getOverallRating()) /
        metricsForPeriod.length;

    return {
      'period': period,
      'totalStaff': metricsForPeriod.length,
      'averageQualityScore': avgQualityScore.toStringAsFixed(2),
      'averageAttendanceRate': avgAttendanceRate,
      'averageOverallRating': avgOverallRating.toStringAsFixed(2),
      'excellentPerformers': metricsForPeriod
          .where((m) => m.getPerformanceLevel() == 'Excellent')
          .length,
      'concerningPerformers': metricsForPeriod
          .where((m) => m.isPerformanceConcerning())
          .length,
      'staffMetrics': metricsForPeriod
          .map(
            (m) => {
              'staffId': m.staffId,
              'overallRating': m.getOverallRating().toStringAsFixed(1),
              'level': m.getPerformanceLevel(),
              'qualityScore': m.qualityScore,
              'attendanceRate': m.attendanceRate,
            },
          )
          .toList(),
    };
  }

  // ==================== COMPLEX ANALYTICS ====================

  /// Get staff availability for a given date and shift
  List<String> getAvailableStaffForShift(
    DateTime date,
    String shift,
    String role,
  ) {
    final shiftForDate = getShiftsForDate(
      date,
    ).where((s) => s.shift == shift).toList();
    List<String> assignedStaff = [];

    for (var schedule in shiftForDate) {
      assignedStaff.addAll(schedule.assignedStaff);
    }

    // Get approved leave for this date (staff on leave cannot be assigned)
    getOverlappingLeaveRequests(date, date);

    // Filter based on role would require full staff list reference
    // This is a simplified version - returns empty list as placeholder
    return [];
  }

  /// Get compliance report
  Map<String, dynamic> getComplianceReport() {
    return {
      'totalDepartments': departments.length,
      'departmentsAtCapacity': departments
          .where((d) => !d.hasCapacity())
          .length,
      'totalSchedules': shiftSchedules.length,
      'fullyStaffedSchedules': shiftSchedules
          .where((s) => s.isFullyStaffed())
          .length,
      'understaffedSchedules': getUnderstaffedShifts().length,
      'pendingLeaveRequests': getPendingLeaveRequests().length,
      'staffWithConcerningPerformance':
          getStaffWithConcerningPerformance().length,
    };
  }

  /// Get comprehensive hospital operational summary
  Map<String, dynamic> getHospitalOperationalSummary() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'departments': getDepartmentOccupancyReport(),
      'scheduling': {
        'totalSchedules': shiftSchedules.length,
        'understaffed': getUnderstaffedShifts().length,
        'coverage': shiftSchedules.isEmpty
            ? 0
            : (shiftSchedules.fold(
                        0.0,
                        (sum, s) => sum + s.getCoveragePercentage(),
                      ) /
                      shiftSchedules.length)
                  .toInt(),
      },
      'leaveManagement': {
        'pending': getPendingLeaveRequests().length,
        'approved': leaveRequests
            .where((l) => l.status == LeaveRequestStatus.approved)
            .length,
      },
      'compliance': getComplianceReport(),
    };
  }
}
