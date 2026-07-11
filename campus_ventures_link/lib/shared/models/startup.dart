class Startup {
  final String id;
  final String ownerId;
  final String startupName;
  final String description;
  final String industry;
  final int teamSize;
  final String website;
  final String verificationStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Startup({
    required this.id,
    required this.ownerId,
    required this.startupName,
    required this.description,
    required this.industry,
    required this.teamSize,
    required this.website,
    required this.verificationStatus,
    this.createdAt,
    this.updatedAt,
  });

  Startup copyWith({
    String? id,
    String? ownerId,
    String? startupName,
    String? description,
    String? industry,
    int? teamSize,
    String? website,
    String? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Startup(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      startupName: startupName ?? this.startupName,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      teamSize: teamSize ?? this.teamSize,
      website: website ?? this.website,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'startupName': startupName,
      'description': description,
      'industry': industry,
      'teamSize': teamSize,
      'website': website,
      'verificationStatus': verificationStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Startup.fromMap(Map<String, dynamic> map) {
    return Startup(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      startupName: map['startupName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      industry: map['industry'] as String? ?? '',
      teamSize: (map['teamSize'] as num?)?.toInt() ?? 0,
      website: map['website'] as String? ?? '',
      verificationStatus: map['verificationStatus'] as String? ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate() as DateTime
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate() as DateTime
          : null,
    );
  }
}
