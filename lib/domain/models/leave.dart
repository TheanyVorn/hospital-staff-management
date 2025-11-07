import 'leave_status.dart';

class Leave {
  final int leaveId;
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  LeaveStatus status;

  Leave({
    required this.leaveId,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    this.status = LeaveStatus.pending,
  });

  /// Calculate the duration of the leave in days
  int getDuration() {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Check if leave is valid (end date after start date)
  bool isValid() {
    return endDate.isAfter(startDate);
  }

  /// Get leave summary
  String getLeaveDetails() {
    return '''
Leave ID: $leaveId
Employee ID: $employeeId
Start Date: ${startDate.toLocal().toString().split(' ')[0]}
End Date: ${endDate.toLocal().toString().split(' ')[0]}
Duration: ${getDuration()} days
Status: $status''';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'leaveId': leaveId,
    'employeeId': employeeId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'status': status.toString(),
  };

  /// Create from JSON
  factory Leave.fromJson(Map<String, dynamic> json) => Leave(
    leaveId: json['leaveId'],
    employeeId: json['employeeId'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    status: _parseLeaveStatus(json['status']),
  );

  static LeaveStatus _parseLeaveStatus(String? status) {
    switch (status) {
      case 'Approved':
        return LeaveStatus.approved;
      case 'Cancelled':
        return LeaveStatus.cancelled;
      case 'On Leave':
        return LeaveStatus.onLeave;
      default:
        return LeaveStatus.pending;
    }
  }
}
