import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package

import '../models/todo_list.dart';
import '../models/todo_item.dart';
import '../services/api_service.dart';
import '../theme.dart';

class TodoListDetailScreen extends StatefulWidget {
  final TodoList todoList;

  TodoListDetailScreen({required this.todoList});

  @override
  _TodoListDetailScreenState createState() => _TodoListDetailScreenState();
}

class _TodoListDetailScreenState extends State<TodoListDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<TodoItem>> _todoItemsFuture;

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  Future<void> _loadTodoItems() async {
    setState(() {
      _todoItemsFuture = _apiService.getTodoItems(widget.todoList.id!);
    });
  }

  Future<void> _deleteTodoItem(int id) async {
    bool success = await _apiService.deleteTodoItem(widget.todoList.id!, id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo item deleted successfully')),
      );
      _loadTodoItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete todo item')),
      );
    }
  }

  Future<void> _createTodoItem() async {
    print('TodoList ID when creating item: ${widget.todoList.id}');
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String? selectedDueDate; // Use a String? to store the formatted date

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text('Add New Todo Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: 'Item name'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(hintText: 'Description'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    GestureDetector( // Use GestureDetector to make the date area tappable
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            selectedDueDate = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          hintText: 'Select Due Date',
                        ),
                        child: Text(
                          selectedDueDate ?? 'Tap to select', // Display selected date or 'Tap to select'
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () async {
                    final itemName = nameController.text;
                    final itemDescription = descriptionController.text;
                    if (itemName.isNotEmpty && selectedDueDate != null) { // Check if a date was selected
                      bool success = await _apiService.createTodoItem(widget.todoList.id!, itemName, itemDescription, selectedDueDate!);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Todo item added successfully')),
                        );
                        _loadTodoItems();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add todo item')),
                        );
                      }
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Item name and due date cannot be empty')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editTodoItem(TodoItem todoItem) async {
    TextEditingController nameController = TextEditingController(text: todoItem.name);
    TextEditingController descriptionController = TextEditingController(text: todoItem.description);
    String? selectedDueDate = todoItem.dueDate; // Initialize with existing due date

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text('Edit Todo Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: 'Item name'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(hintText: 'Description'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        DateTime? initialDate;

                        if (selectedDueDate != null) {
                          initialDate = DateTime.parse(selectedDueDate!); // Parse existing date
                        } else {
                          initialDate = DateTime.now();
                        }
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        print('Picked DateTime: $picked');
                        if (picked != null) {
                          setStateDialog(() { // Use setStateDialog here
                            selectedDueDate = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          hintText: 'Select Due Date',
                        ),
                        child: Builder(
                          builder: (BuildContext context) {
                            return Text(
                              selectedDueDate ?? 'Tap to select',
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    final newName = nameController.text;
                    final newDescription = descriptionController.text;
                    if (newName.isNotEmpty && selectedDueDate != null) { // Check if a date was selected
                      print('Sending Due Date to Backend: $selectedDueDate');
                      bool success = await _apiService.editTodoItem(widget.todoList.id!, todoItem.id!, newName, newDescription, selectedDueDate!);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Todo item updated successfully')),
                        );
                        _loadTodoItems();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update todo item')),
                        );
                      }
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Item name and due date cannot be empty')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ... other methods in TodoListDetailScreen remain the same
  Future<void> _toggleTodoItemCompletion(TodoItem todoItem) async {
    bool success = await _apiService.updateTodoItemCompletion(
      todoItem, // Pass the entire todoItem object here
      !todoItem.isCompleted,
    );
    if (success) {
      _loadTodoItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:
        Text('Failed to update todo item status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todoList.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.todoList.description ?? 'No description provided.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TodoItem>>(
              future: _todoItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: ColorPalette.errorColor)));
                } else if (snapshot.data != null) {
                  if (snapshot.data!.isEmpty) {
                    return Center(child: Text('No todo items yet. Click the "+" button to add one.'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final todoItem = snapshot.data![index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        color: ColorPalette.cardBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: todoItem.isCompleted,
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    _toggleTodoItemCompletion(todoItem);
                                  }
                                },
                              ),
                              Expanded(
                                child: Text(
                                  todoItem.name,
                                  style: TextStyle(
                                    color: ColorPalette.textColorPrimary,
                                    decoration: todoItem.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(todoItem.dueDate),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: ColorPalette.iconColor),
                                onPressed: () => _editTodoItem(todoItem),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: ColorPalette.errorColor),
                                onPressed: () => _deleteTodoItem(todoItem.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No todo items found.', style: TextStyle(color: ColorPalette.textColorPrimary)));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTodoItem,
        child: Icon(Icons.add),
        backgroundColor: ColorPalette.primaryColor,
      ),
    );
  }
}