class TaskModel {
  final String id;
  final String title;
  final String status;
  final String priority;
  final String project;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.project,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['_id'] ?? json['id'],
    title: json['title'] ?? '',
    status: json['status'] ?? 'pending',
    priority: json['priority'] ?? 'medium',
    project: json['project'] ?? '',
    owner: json['owner'] ?? '',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'status': status,
    'priority': priority,
    'project': project,
  };
}
