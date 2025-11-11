class Skill {
  final String name;
  final String level; // Beginner, Intermediate, Advanced, Expert
  final DateTime certifiedDate;
  final DateTime expiryDate;
  bool isExpired;

  Skill({
    required this.name,
    required this.level,
    required this.certifiedDate,
    required this.expiryDate,
  }) : isExpired = DateTime.now().isAfter(expiryDate);

  /// Check if skill is valid (not expired)
  bool isValid() {
    isExpired = DateTime.now().isAfter(expiryDate);
    return !isExpired;
  }

  /// Get days until expiry
  int daysUntilExpiry() {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// Check if skill is expiring soon (within 30 days)
  bool isExpiringsoon() {
    return daysUntilExpiry() <= 30 && daysUntilExpiry() > 0;
  }

  /// Get skill level numeric value (for comparison)
  int getLevelValue() {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
        return 3;
      case 'expert':
        return 4;
      default:
        return 0;
    }
  }

  /// Validate skill data
  List<String> validate() {
    List<String> errors = [];
    
    if (name.isEmpty) {
      errors.add('Skill name cannot be empty');
    }
    
    if (!['Beginner', 'Intermediate', 'Advanced', 'Expert'].contains(level)) {
      errors.add('Invalid skill level');
    }
    
    if (expiryDate.isBefore(certifiedDate)) {
      errors.add('Expiry date cannot be before certified date');
    }
    
    return errors;
  }

  String getSkillInfo() {
    return '''
Skill: $name
Level: $level
Certified: ${certifiedDate.toLocal().toString().split(' ')[0]}
Expires: ${expiryDate.toLocal().toString().split(' ')[0]}
Status: ${isValid() ? (isExpiringonly() ? "Expiring Soon" : "Valid") : "Expired"}''';
  }

  bool isExpiringonly() => isExpiringsoon();

  Map<String, dynamic> toJson() => {
    'name': name,
    'level': level,
    'certifiedDate': certifiedDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    name: json['name'],
    level: json['level'],
    certifiedDate: DateTime.parse(json['certifiedDate']),
    expiryDate: DateTime.parse(json['expiryDate']),
  );
}
