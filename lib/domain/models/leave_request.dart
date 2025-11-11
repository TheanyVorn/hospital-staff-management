enum LeaveRequestStatus { pending, approved, rejected, cancelled }

class LeaveRequest {
  final String id;
  final String staffId;
  DateTime startDate;
  DateTime endDate;
  String leaveType; // Sick, Vacation, Personal, Maternity, etc.
  LeaveRequestStatus status;
  String reason;
  String? replacementStaffId;
  String? approvedBy;
  DateTime requestDate;
  DateTime? approvalDate;
  String? rejectionReason;

  LeaveRequest({
    required this.id,
    required this.staffId,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    this.status = LeaveRequestStatus.pending,
    required this.reason,
    this.replacementStaffId,
    this.approvedBy,
    DateTime? requestDate,
    this.approvalDate,
    this.rejectionReason,
  }) : requestDate = requestDate ?? DateTime.now();

  /// Get duration of leave in days
  int getDuration() {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Check if leave dates are valid
  bool isValid() {
    return endDate.isAfter(startDate) && startDate.isAfter(DateTime.now().subtract(Duration(days: 1)));
  }

  /// Approve the leave request
  bool approve(String approverId, String? replacementId) {
    if (status != LeaveRequestStatus.pending) {
      return false;
    }
    status = LeaveRequestStatus.approved;
    approvedBy = approverId;
    approvalDate = DateTime.now();
    replacementStaffId = replacementId;
    return true;
  }

  /// Reject the leave request
  bool reject(String approverId, String reason) {
    if (status != LeaveRequestStatus.pending) {
      return false;
    }
    status = LeaveRequestStatus.rejected;
    approvedBy = approverId;
    approvalDate = DateTime.now();
    rejectionReason = reason;
    return true;
  }

  /// Cancel the leave request
  bool cancel() {
    if (status == LeaveRequestStatus.cancelled) {
      return false;
    }
    status = LeaveRequestStatus.cancelled;
    return true;
  }

  /// Check if replacement is required
  bool requiresReplacement() {
    return status == LeaveRequestStatus.approved && replacementStaffId != null;
  }

  /// Get days pending approval
  int daysPendingApproval() {
    if (status == LeaveRequestStatus.pending) {
      return DateTime.now().difference(requestDate).inDays;
    }
    return 0;
  }

  /// Validate leave request
  List<String> validate() {
    List<String> errors = [];
    
    if (staffId.isEmpty) {
      errors.add('Staff ID cannot be empty');
    }
    
    if (!isValid()) {
      errors.add('End date must be after start date and in the future');
    }
    
    if (leaveType.isEmpty) {
      errors.add('Leave type cannot be empty');
    }
    
    if (reason.isEmpty) {
      errors.add('Reason cannot be empty');
    }
    
    if (getDuration() > 365) {
      errors.add('Leave duration cannot exceed 365 days');
    }
    
    if (status == LeaveRequestStatus.approved && replacementStaffId == null) {
      errors.add('Approved leave must have a replacement staff member');
    }
    
    return errors;
  }

  String getLeaveRequestInfo() {
    return '''
Leave ID: $id
Staff ID: $staffId
Start Date: ${startDate.toLocal().toString().split(' ')[0]}
End Date: ${endDate.toLocal().toString().split(' ')[0]}
Duration: ${getDuration()} days
Type: $leaveType
Reason: $reason
Status: ${status.toString().split('.').last}
Replacement: ${replacementStaffId ?? "Not assigned"}
Approved By: ${approvedBy ?? "Pending"}
Requested: ${requestDate.toLocal().toString().split(' ')[0]}
Days Pending: ${daysPendingApproval()}''';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'staffId': staffId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'leaveType': leaveType,
    'status': status.toString().split('.').last,
    'reason': reason,
    'replacementStaffId': replacementStaffId,
    'approvedBy': approvedBy,
    'requestDate': requestDate.toIso8601String(),
    'approvalDate': approvalDate?.toIso8601String(),
    'rejectionReason': rejectionReason,
  };

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    LeaveRequestStatus parseStatus(String? status) {
      switch (status) {
        case 'approved':
          return LeaveRequestStatus.approved;
        case 'rejected':
          return LeaveRequestStatus.rejected;
        case 'cancelled':
          return LeaveRequestStatus.cancelled;
        default:
          return LeaveRequestStatus.pending;
      }
    }

    return LeaveRequest(
      id: json['id'],
      staffId: json['staffId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      leaveType: json['leaveType'],
      status: parseStatus(json['status']),
      reason: json['reason'],
      replacementStaffId: json['replacementStaffId'],
      approvedBy: json['approvedBy'],
      requestDate: DateTime.parse(json['requestDate']),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      rejectionReason: json['rejectionReason'],
    );
  }
}
