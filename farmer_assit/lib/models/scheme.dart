class Scheme {
  final String id;
  final String name;
  final String category;
  final String level;
  final String description;
  final List<String> eligibility;
  final List<String> benefits;
  final String applicationLink;
  final String applicationProcess;

  Scheme({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.description,
    required this.eligibility,
    required this.benefits,
    required this.applicationLink,
    required this.applicationProcess,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      description: json['description'] ?? '',
      eligibility: (json['eligibility'] as List?)?.map((e) => e.toString()).toList() ?? [],
      benefits: (json['benefits'] as List?)?.map((e) => e.toString()).toList() ?? [],
      applicationLink: json['applicationLink'] ?? '',
      applicationProcess: json['applicationProcess'] ?? '',
    );
  }
}