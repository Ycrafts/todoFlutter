class TodoItem {
  final int id; // Backend uses Long, which maps to int in Dart for practical purposes
  final String name;
  final String? description;
  final String status; // Will be "PENDING" or "COMPLETED"
  final String dueDate; // Store as String for simplicity, you might want to parse to DateTime later
  final String createdAt;
  final String updatedAt;

  TodoItem({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] != null ? json['id'].toInt() : 0, // Handle potential null and convert to int
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'PENDING',
      dueDate: json['dueDate'] ?? '', // You might want to format this
      createdAt: json['createdAt'] ?? '', // You might want to parse to DateTime
      updatedAt: json['updatedAt'] ?? '', // You might want to parse to DateTime
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'status': status,
      'dueDate': dueDate,
    };
  }

  bool get isCompleted => status == 'COMPLETED';
}