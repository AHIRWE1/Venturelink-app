class Bookmark {
  final String id;
  final String studentId;
  final String opportunityId;
  final DateTime? createdAt;

  const Bookmark({
    required this.id,
    required this.studentId,
    required this.opportunityId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'opportunityId': opportunityId,
      'createdAt': createdAt,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      opportunityId: map['opportunityId'] as String,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate() as DateTime
          : null,
    );
  }
}
