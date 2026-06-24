class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['_id'] ?? json['id'],
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? 'active',
    owner: json['owner'] ?? '',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'status': status,
  };
}
