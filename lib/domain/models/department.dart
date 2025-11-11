class Department {
  final String id;
  String name;
  String head; // Staff ID of department head
  double budget;
  int staffCapacity;
  int currentStaffCount;
  List<String> requiredSkills;
  DateTime createdDate;
  bool isActive;

  Department({
    required this.id,
    required this.name,
    required this.head,
    required this.budget,
    required this.staffCapacity,
    this.currentStaffCount = 0,
    List<String>? requiredSkills,
    DateTime? createdDate,
    this.isActive = true,
  }) : requiredSkills = requiredSkills ?? [],
       createdDate = createdDate ?? DateTime.now();

  /// Check if department has capacity for new staff
  bool hasCapacity() => currentStaffCount < staffCapacity;

  /// Calculate remaining budget
  double getRemainingBudget() => budget;

  /// Check if department meets required skill set
  bool meetsRequiredSkills(List<String> staffSkills) {
    return requiredSkills.every((skill) => staffSkills.contains(skill));
  }

  /// Get occupancy percentage
  double getOccupancyPercentage() {
    if (staffCapacity == 0) return 0.0;
    return (currentStaffCount / staffCapacity) * 100;
  }

  /// Add staff to department
  bool addStaff() {
    if (hasCapacity()) {
      currentStaffCount++;
      return true;
    }
    return false;
  }

  /// Remove staff from department
  void removeStaff() {
    if (currentStaffCount > 0) {
      currentStaffCount--;
    }
  }

  /// Validate department configuration
  List<String> validate() {
    List<String> errors = [];
    
    if (name.isEmpty) {
      errors.add('Department name cannot be empty');
    }
    
    if (head.isEmpty) {
      errors.add('Department head ID cannot be empty');
    }
    
    if (budget < 0) {
      errors.add('Budget cannot be negative');
    }
    
    if (staffCapacity <= 0) {
      errors.add('Staff capacity must be greater than 0');
    }
    
    if (requiredSkills.isEmpty) {
      errors.add('Department must have at least one required skill');
    }
    
    return errors;
  }

  String getDepartmentInfo() {
    return '''
Department ID: $id
Name: $name
Head: $head
Budget: \$${budget.toStringAsFixed(2)}
Staff Capacity: $currentStaffCount / $staffCapacity
Occupancy: ${getOccupancyPercentage().toStringAsFixed(1)}%
Required Skills: ${requiredSkills.join(", ")}
Status: ${isActive ? "Active" : "Inactive"}
Created: ${createdDate.toLocal().toString().split(' ')[0]}''';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'head': head,
    'budget': budget,
    'staffCapacity': staffCapacity,
    'currentStaffCount': currentStaffCount,
    'requiredSkills': requiredSkills,
    'createdDate': createdDate.toIso8601String(),
    'isActive': isActive,
  };

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json['id'],
    name: json['name'],
    head: json['head'],
    budget: (json['budget'] as num).toDouble(),
    staffCapacity: json['staffCapacity'],
    currentStaffCount: json['currentStaffCount'] ?? 0,
    requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
    createdDate: json['createdDate'] != null 
        ? DateTime.parse(json['createdDate'])
        : DateTime.now(),
    isActive: json['isActive'] ?? true,
  );
}
