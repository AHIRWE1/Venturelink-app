class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final List<String> skills;
  final String? bio;
  final String? cvUrl;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? websiteUrl;
  final String? photoUrl;
  final bool onboardingCompleted;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.skills,
    this.bio,
    this.cvUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.websiteUrl,
    this.photoUrl,
    this.onboardingCompleted = false,
    this.createdAt,
  });

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    List<String>? skills,
    String? bio,
    String? cvUrl,
    String? githubUrl,
    String? linkedinUrl,
    String? websiteUrl,
    String? photoUrl,
    bool? onboardingCompleted,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      cvUrl: cvUrl ?? this.cvUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'skills': skills,
      'bio': bio,
      'cvUrl': cvUrl,
      'githubUrl': githubUrl,
      'linkedinUrl': linkedinUrl,
      'websiteUrl': websiteUrl,
      'photoUrl': photoUrl,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String,
      role: map['role'] as String? ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      bio: map['bio'] as String?,
      cvUrl: map['cvUrl'] as String?,
      githubUrl: map['githubUrl'] as String?,
      linkedinUrl: map['linkedinUrl'] as String?,
      websiteUrl: map['websiteUrl'] as String?,
      photoUrl: map['photoUrl'] as String?,
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate() as DateTime
          : null,
    );
  }

  factory AppUser.initial({
    required String uid,
    required String email,
  }) {
    return AppUser(
      uid: uid,
      name: '',
      email: email,
      role: '',
      skills: const [],
      onboardingCompleted: false,
      createdAt: DateTime.now(),
    );
  }
}
