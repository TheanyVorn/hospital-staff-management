class ShiftSchedule {
  final String id;
  DateTime date;
  String shift; // Morning, Afternoon, Night
  Map<String, int> requiredStaff; // e.g., {"doctors": 2, "nurses": 3}
  List<String> assignedStaff; // Staff IDs assigned to this shift
  List<String> emergencyBackup; // Emergency backup staff IDs
  DateTime createdDate;
  DateTime? modifiedDate;

  ShiftSchedule({
    required this.id,
    required this.date,
    required this.shift,
    required this.requiredStaff,
    List<String>? assignedStaff,
    List<String>? emergencyBackup,
    DateTime? createdDate,
    this.modifiedDate,
  })  : assignedStaff = assignedStaff ?? [],
        emergencyBackup = emergencyBackup ?? [],
        createdDate = createdDate ?? DateTime.now();

  /// Calculate coverage percentage
  int getCoveragePercentage() {
    int totalRequired = requiredStaff.values.fold(0, (sum, val) => sum + val);
    if (totalRequired == 0) return 0;
    return ((assignedStaff.length / totalRequired) * 100).toInt();
  }

  /// Check if shift is fully staffed
  bool isFullyStaffed() {
    int totalRequired = requiredStaff.values.fold(0, (sum, val) => sum + val);
    return assignedStaff.length >= totalRequired;
  }

  /// Get remaining slots to fill
  int getRemainingSlots() {
    int totalRequired = requiredStaff.values.fold(0, (sum, val) => sum + val);
    return (totalRequired - assignedStaff.length).clamp(0, totalRequired);
  }

  /// Add staff to shift
  bool addStaff(String staffId) {
    int totalRequired = requiredStaff.values.fold(0, (sum, val) => sum + val);
    if (assignedStaff.length < totalRequired && !assignedStaff.contains(staffId)) {
      assignedStaff.add(staffId);
      modifiedDate = DateTime.now();
      return true;
    }
    return false;
  }

  /// Remove staff from shift
  bool removeStaff(String staffId) {
    if (assignedStaff.contains(staffId)) {
      assignedStaff.remove(staffId);
      modifiedDate = DateTime.now();
      return true;
    }
    return false;
  }

  /// Add emergency backup
  bool addEmergencyBackup(String staffId) {
    if (!emergencyBackup.contains(staffId)) {
      emergencyBackup.add(staffId);
      modifiedDate = DateTime.now();
      return true;
    }
    return false;
  }

  /// Remove emergency backup
  bool removeEmergencyBackup(String staffId) {
    if (emergencyBackup.contains(staffId)) {
      emergencyBackup.remove(staffId);
      modifiedDate = DateTime.now();
      return true;
    }
    return false;
  }

  /// Validate shift schedule
  List<String> validate() {
    List<String> errors = [];
    
    if (date.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      errors.add('Cannot schedule shift in the past');
    }
    
    if (shift.isEmpty) {
      errors.add('Shift type cannot be empty');
    }
    
    if (!['Morning', 'Afternoon', 'Night'].contains(shift)) {
      errors.add('Invalid shift type. Must be Morning, Afternoon, or Night');
    }
    
    if (requiredStaff.isEmpty) {
      errors.add('Required staff cannot be empty');
    }
    
    requiredStaff.forEach((role, count) {
      if (count <= 0) {
        errors.add('Required $role count must be greater than 0');
      }
    });
    
    return errors;
  }

  String getScheduleInfo() {
    int totalRequired = requiredStaff.values.fold(0, (sum, val) => sum + val);
    return '''
Schedule ID: $id
Date: ${date.toLocal().toString().split(' ')[0]}
Shift: $shift
Required Staff: ${requiredStaff.entries.map((e) => '${e.value} ${e.key}').join(', ')}
Assigned Staff: ${assignedStaff.length} / $totalRequired
Coverage: ${getCoveragePercentage()}%
Emergency Backup: ${emergencyBackup.length}
Status: ${isFullyStaffed() ? "Fully Staffed" : "Understaffed"}''';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'shift': shift,
    'requiredStaff': requiredStaff,
    'assignedStaff': assignedStaff,
    'emergencyBackup': emergencyBackup,
    'createdDate': createdDate.toIso8601String(),
    'modifiedDate': modifiedDate?.toIso8601String(),
  };

  factory ShiftSchedule.fromJson(Map<String, dynamic> json) => ShiftSchedule(
    id: json['id'],
    date: DateTime.parse(json['date']),
    shift: json['shift'],
    requiredStaff: Map<String, int>.from(json['requiredStaff'] ?? {}),
    assignedStaff: List<String>.from(json['assignedStaff'] ?? []),
    emergencyBackup: List<String>.from(json['emergencyBackup'] ?? []),
    createdDate: json['createdDate'] != null
        ? DateTime.parse(json['createdDate'])
        : DateTime.now(),
    modifiedDate: json['modifiedDate'] != null
        ? DateTime.parse(json['modifiedDate'])
        : null,
  );
}
