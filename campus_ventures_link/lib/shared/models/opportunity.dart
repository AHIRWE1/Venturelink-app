class Opportunity {
  final String id;
  final String startupId;
  final String title;
  final String description;
  final String category;
  final String location;
  final String employmentType;
  final List<String> requiredSkills;
  final DateTime? deadline;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Opportunity({
    required this.id,
    required this.startupId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.employmentType,
    required this.requiredSkills,
    this.deadline,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startupId': startupId,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'employmentType': employmentType,
      'requiredSkills': requiredSkills,
      'deadline': deadline,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Opportunity.fromMap(Map<String, dynamic> map) {
    return Opportunity(
      id: map['id'] as String,
      startupId: map['startupId'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      location: map['location'] as String? ?? 'Remote',
      employmentType: map['employmentType'] as String? ?? 'Internship',
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      deadline: map['deadline'] != null
          ? (map['deadline'] as dynamic).toDate() as DateTime
          : null,
      status: map['status'] as String? ?? 'open',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate() as DateTime
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate() as DateTime
          : null,
    );
  }
}
