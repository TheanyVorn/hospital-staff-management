class PerformanceMetrics {
  final String staffId;
  final String period; // Format: YYYY-Q1, YYYY-Q2, etc. or YYYY-MM
  int patientsServed;
  double qualityScore; // 0.0 - 5.0
  int attendanceRate; // 0 - 100%
  int incidents;
  int compliments;
  double productivityScore; // 0.0 - 100.0
  DateTime evaluationDate;
  String? notes;
  String? evaluatedBy;

  PerformanceMetrics({
    required this.staffId,
    required this.period,
    this.patientsServed = 0,
    this.qualityScore = 0.0,
    this.attendanceRate = 100,
    this.incidents = 0,
    this.compliments = 0,
    this.productivityScore = 0.0,
    DateTime? evaluationDate,
    this.notes,
    this.evaluatedBy,
  }) : evaluationDate = evaluationDate ?? DateTime.now();

  /// Calculate overall performance rating (0-100)
  double getOverallRating() {
    double rating = 0.0;
    rating += (qualityScore / 5.0) * 40; // Quality: 40%
    rating += (attendanceRate / 100.0) * 30; // Attendance: 30%
    rating += productivityScore * 0.2; // Productivity: 20%
    rating += (compliments * 5).clamp(0, 10); // Compliments: 10%
    return rating.clamp(0, 100);
  }

  /// Get performance level based on rating
  String getPerformanceLevel() {
    double rating = getOverallRating();
    if (rating >= 90) return 'Excellent';
    if (rating >= 80) return 'Very Good';
    if (rating >= 70) return 'Good';
    if (rating >= 60) return 'Satisfactory';
    return 'Needs Improvement';
  }

  /// Check if performance is concerning
  bool isPerformanceConcerning() {
    return getOverallRating() < 60 || incidents > 3 || attendanceRate < 80;
  }

  /// Get quality score assessment
  String getQualityAssessment() {
    if (qualityScore >= 4.5) return 'Excellent';
    if (qualityScore >= 4.0) return 'Very Good';
    if (qualityScore >= 3.5) return 'Good';
    if (qualityScore >= 3.0) return 'Satisfactory';
    return 'Needs Improvement';
  }

  /// Update performance metrics
  void updateMetrics({
    int? patientsServed,
    double? qualityScore,
    int? attendanceRate,
    int? incidents,
    int? compliments,
    double? productivityScore,
  }) {
    if (patientsServed != null) this.patientsServed = patientsServed;
    if (qualityScore != null) this.qualityScore = qualityScore.clamp(0, 5);
    if (attendanceRate != null) this.attendanceRate = attendanceRate.clamp(0, 100);
    if (incidents != null) this.incidents = incidents;
    if (compliments != null) this.compliments = compliments;
    if (productivityScore != null) this.productivityScore = productivityScore.clamp(0, 100);
    evaluationDate = DateTime.now();
  }

  /// Validate performance metrics
  List<String> validate() {
    List<String> errors = [];
    
    if (staffId.isEmpty) {
      errors.add('Staff ID cannot be empty');
    }
    
    if (period.isEmpty) {
      errors.add('Period cannot be empty');
    }
    
    if (qualityScore < 0 || qualityScore > 5) {
      errors.add('Quality score must be between 0 and 5');
    }
    
    if (attendanceRate < 0 || attendanceRate > 100) {
      errors.add('Attendance rate must be between 0 and 100');
    }
    
    if (productivityScore < 0 || productivityScore > 100) {
      errors.add('Productivity score must be between 0 and 100');
    }
    
    if (patientsServed < 0) {
      errors.add('Patients served cannot be negative');
    }
    
    if (incidents < 0) {
      errors.add('Incidents cannot be negative');
    }
    
    return errors;
  }

  String getMetricsInfo() {
    return '''
Staff ID: $staffId
Period: $period
Patients Served: $patientsServed
Quality Score: ${qualityScore.toStringAsFixed(1)}/5.0 (${getQualityAssessment()})
Attendance Rate: $attendanceRate%
Incidents: $incidents
Compliments: $compliments
Productivity Score: ${productivityScore.toStringAsFixed(1)}%
Overall Rating: ${getOverallRating().toStringAsFixed(1)}/100 (${getPerformanceLevel()})
Status: ${isPerformanceConcerning() ? "⚠️ Concerning" : "✓ Good"}
Evaluated: ${evaluationDate.toLocal().toString().split(' ')[0]}
Evaluated By: ${evaluatedBy ?? "Not specified"}''';
  }

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'period': period,
    'patientsServed': patientsServed,
    'qualityScore': qualityScore,
    'attendanceRate': attendanceRate,
    'incidents': incidents,
    'compliments': compliments,
    'productivityScore': productivityScore,
    'evaluationDate': evaluationDate.toIso8601String(),
    'notes': notes,
    'evaluatedBy': evaluatedBy,
  };

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) => PerformanceMetrics(
    staffId: json['staffId'],
    period: json['period'],
    patientsServed: json['patientsServed'] ?? 0,
    qualityScore: (json['qualityScore'] as num?)?.toDouble() ?? 0.0,
    attendanceRate: json['attendanceRate'] ?? 100,
    incidents: json['incidents'] ?? 0,
    compliments: json['compliments'] ?? 0,
    productivityScore: (json['productivityScore'] as num?)?.toDouble() ?? 0.0,
    evaluationDate: json['evaluationDate'] != null
        ? DateTime.parse(json['evaluationDate'])
        : DateTime.now(),
    notes: json['notes'],
    evaluatedBy: json['evaluatedBy'],
  );
}
