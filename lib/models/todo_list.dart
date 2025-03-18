class TodoList{
  final int? id;
  final String name;
  final String? description;

  TodoList({this.id, required this.name, this.description});

  factory TodoList.fromJson(Map<String, dynamic> json){
    return TodoList(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}