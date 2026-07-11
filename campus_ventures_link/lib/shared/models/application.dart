class ApplicationModel {
  final String id;
  final String studentId;
  final String startupId;
  final String opportunityId;
  final String status;
  final String coverLetter;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ApplicationModel({
    required this.id,
    required this.studentId,
    required this.startupId,
    required this.opportunityId,
    required this.status,
    required this.coverLetter,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'startupId': startupId,
      'opportunityId': opportunityId,
      'status': status,
      'coverLetter': coverLetter,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      startupId: map['startupId'] as String,
      opportunityId: map['opportunityId'] as String,
      status: map['status'] as String? ?? 'pending',
      coverLetter: map['coverLetter'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate() as DateTime
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate() as DateTime
          : null,
    );
  }
}
