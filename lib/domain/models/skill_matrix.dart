import 'skill.dart';

class SkillMatrix {
  final String staffId;
  final List<Skill> skills;
  DateTime lastUpdated;

  SkillMatrix({
    required this.staffId,
    List<Skill>? skills,
    DateTime? lastUpdated,
  })  : skills = skills ?? [],
        lastUpdated = lastUpdated ?? DateTime.now();

  /// Add a new skill
  void addSkill(Skill skill) {
    if (!skills.any((s) => s.name.toLowerCase() == skill.name.toLowerCase())) {
      skills.add(skill);
      lastUpdated = DateTime.now();
    }
  }

  /// Remove a skill
  bool removeSkill(String skillName) {
    final initialLength = skills.length;
    skills.removeWhere((s) => s.name.toLowerCase() == skillName.toLowerCase());
    final removed = skills.length < initialLength;
    if (removed) {
      lastUpdated = DateTime.now();
    }
    return removed;
  }

  /// Update a skill
  bool updateSkill(String skillName, Skill updatedSkill) {
    final index = skills.indexWhere((s) => s.name.toLowerCase() == skillName.toLowerCase());
    if (index != -1) {
      skills[index] = updatedSkill;
      lastUpdated = DateTime.now();
      return true;
    }
    return false;
  }

  /// Get all valid (non-expired) skills
  List<Skill> getValidSkills() {
    return skills.where((s) => s.isValid()).toList();
  }

  /// Get all expired skills
  List<Skill> getExpiredSkills() {
    return skills.where((s) => !s.isValid()).toList();
  }

  /// Get skills expiring soon
  List<Skill> getExpiringSkills() {
    return skills.where((s) => s.isExpiringonly()).toList();
  }

  /// Get skills by level
  List<Skill> getSkillsByLevel(String level) {
    return skills.where((s) => s.level.toLowerCase() == level.toLowerCase()).toList();
  }

  /// Check if staff has a specific skill
  bool hasSkill(String skillName) {
    return skills.any((s) => s.name.toLowerCase() == skillName.toLowerCase() && s.isValid());
  }

  /// Check if staff has a skill at minimum level
  bool hasSkillAtLevel(String skillName, String minLevel) {
    final skill = skills.firstWhere(
      (s) => s.name.toLowerCase() == skillName.toLowerCase(),
      orElse: () => Skill(
        name: '',
        level: 'Beginner',
        certifiedDate: DateTime.now(),
        expiryDate: DateTime.now(),
      ),
    );
    if (skill.name.isEmpty) return false;
    return skill.isValid() && skill.getLevelValue() >= Skill(
      name: '',
      level: minLevel,
      certifiedDate: DateTime.now(),
      expiryDate: DateTime.now(),
    ).getLevelValue();
  }

  /// Get total skills count
  int getTotalSkills() => skills.length;

  /// Get valid skills count
  int getValidSkillsCount() => getValidSkills().length;

  /// Calculate skill coverage (percentage of valid skills)
  double getSkillCoverage() {
    if (skills.isEmpty) return 0.0;
    return (getValidSkillsCount() / skills.length) * 100;
  }

  /// Get high-level skills (Advanced + Expert)
  List<Skill> getHighLevelSkills() {
    return skills.where((s) => s.getLevelValue() >= 3 && s.isValid()).toList();
  }

  /// Validate skill matrix
  List<String> validate() {
    List<String> errors = [];
    
    if (staffId.isEmpty) {
      errors.add('Staff ID cannot be empty');
    }
    
    for (var skill in skills) {
      final validationErrors = skill.validate();
      errors.addAll(validationErrors);
    }
    
    return errors;
  }

  String getSkillMatrixInfo() {
    return '''
Staff ID: $staffId
Total Skills: ${getTotalSkills()}
Valid Skills: ${getValidSkillsCount()}
Skill Coverage: ${getSkillCoverage().toStringAsFixed(1)}%
High-Level Skills: ${getHighLevelSkills().length}
Expiring Soon: ${getExpiringSkills().length}
Expired: ${getExpiredSkills().length}
Last Updated: ${lastUpdated.toLocal().toString().split(' ')[0]}''';
  }

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'skills': skills.map((s) => s.toJson()).toList(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory SkillMatrix.fromJson(Map<String, dynamic> json) => SkillMatrix(
    staffId: json['staffId'],
    skills: (json['skills'] as List?)
        ?.map((s) => Skill.fromJson(s as Map<String, dynamic>))
        .toList() ?? [],
    lastUpdated: json['lastUpdated'] != null
        ? DateTime.parse(json['lastUpdated'])
        : DateTime.now(),
  );
}
