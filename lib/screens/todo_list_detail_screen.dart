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
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String? selectedDueDate;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              backgroundColor: ColorPalette.backgroundColorDark,
              title: Text('Add New Todo Item', style: TextStyle(color: ColorPalette.textColorPrimaryDark)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                      decoration: InputDecoration(
                        hintText: 'Item name',
                        hintStyle: TextStyle(color: ColorPalette.textColorHintDark),
                        border: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.borderColorDark)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.primaryColorDark)),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                      decoration: InputDecoration(
                        hintText: 'Description',
                        hintStyle: TextStyle(color: ColorPalette.textColorHintDark),
                        border: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.borderColorDark)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.primaryColorDark)),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: ColorPalette.primaryColorDark,
                                  onPrimary: ColorPalette.textColorPrimaryDark,
                                  surface: ColorPalette.backgroundColorDark,
                                  onSurface: ColorPalette.textColorPrimaryDark,
                                ),
                                dialogBackgroundColor: ColorPalette.backgroundColorDark,
                              ),
                              child: child!,
                            );
                          },
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
                          labelStyle: TextStyle(color: ColorPalette.textColorSecondaryDark),
                          hintText: 'Select Due Date',
                          hintStyle: TextStyle(color: ColorPalette.textColorHintDark),
                          border: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.borderColorDark)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.primaryColorDark)),
                        ),
                        child: Text(
                          selectedDueDate ?? 'Tap to select',
                          style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: ColorPalette.textColorSecondaryDark)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add', style: TextStyle(color: ColorPalette.textColorSecondaryDark)),
                  onPressed: () async {
                    final itemName = nameController.text;
                    final itemDescription = descriptionController.text;
                    if (itemName.isNotEmpty && selectedDueDate != null) {
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
    String? selectedDueDate = todoItem.dueDate;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              backgroundColor: ColorPalette.backgroundColorDark,
              title: Text('Edit Todo Item', style: TextStyle(color: ColorPalette.textColorPrimaryDark)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                      decoration: InputDecoration(
                        hintText: 'Item name',
                        hintStyle: TextStyle(color: ColorPalette.textColorHintDark),
                        border: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.borderColorDark)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.primaryColorDark)),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                      decoration: InputDecoration(
                        hintText: 'Description',
                        hintStyle: TextStyle(color: ColorPalette.textColorHintDark),
                        border: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.borderColorDark)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.primaryColorDark)),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        DateTime? initialDate = selectedDueDate != null ? DateTime.parse(selectedDueDate!) : DateTime.now();
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: ColorPalette.primaryColorDark,
                                  onPrimary: ColorPalette.textColorPrimaryDark,
                                  surface: ColorPalette.backgroundColorDark,
                                  onSurface: ColorPalette.textColorPrimaryDark,
                                ),
                                dialogBackgroundColor: ColorPalette.backgroundColorDark,
                              ),
                              child: child!,
                            );
                          },
                        );
                        print('Picked DateTime: $picked');
                        if (picked != null) {
                          setStateDialog(() {
                            selectedDueDate = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          labelStyle: TextStyle(color: ColorPalette.textColorSecondaryDark),
                          hintText: 'Select Due Date',
                          hintStyle: TextStyle(color: ColorPalette.textColorHintDark),
                          border: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.borderColorDark)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.primaryColorDark)),
                        ),
                        child: Text(
                          selectedDueDate ?? 'Tap to select',
                          style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: ColorPalette.textColorSecondaryDark)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save', style: TextStyle(color: ColorPalette.textColorSecondaryDark)),
                  onPressed: () async {
                    final newName = nameController.text;
                    final newDescription = descriptionController.text;
                    if (newName.isNotEmpty && selectedDueDate != null) {
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
  Future<void> _toggleTodoItemCompletion(TodoItem todoItem) async {
    bool success = await _apiService.updateTodoItemCompletion(
      todoItem,
      !todoItem.isCompleted,
    );
    if (success) {
      _loadTodoItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update todo item status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: ColorPalette.backgroundColorDark,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorPalette.appBarColorDark,
          titleTextStyle: TextStyle(color: ColorPalette.textColorPrimaryDark),
          iconTheme: IconThemeData(color: ColorPalette.textColorPrimaryDark),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: ColorPalette.textColorPrimaryDark),
          titleMedium: TextStyle(color: ColorPalette.textColorPrimaryDark),
        ),
        colorScheme: ColorScheme.dark(
          primary: ColorPalette.primaryColorDark,
          secondary: ColorPalette.textColorSecondaryDark,
          error: ColorPalette.errorColorDark,
        ),
      ),
      child: Scaffold(
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
                style: TextStyle(fontSize: 16, color: ColorPalette.textColorPrimaryDark),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<TodoItem>>(
                future: _todoItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: ColorPalette.errorColorDark)));
                  } else if (snapshot.data != null) {
                    if (snapshot.data!.isEmpty) {
                      return Center(child: Text('No todo items yet. Click the "+" button to add one.', style: TextStyle(color: ColorPalette.textColorPrimaryDark)));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final todoItem = snapshot.data![index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          color: ColorPalette.cardBackgroundColorDark,
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
                                      color: ColorPalette.textColorPrimaryDark,
                                      decoration: todoItem.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(todoItem.dueDate, style: TextStyle(color: ColorPalette.textColorSecondaryDark)),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: ColorPalette.iconColorDark),
                                  onPressed: () => _editTodoItem(todoItem),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: ColorPalette.errorColorDark),
                                  onPressed: () => _deleteTodoItem(todoItem.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No todo items found.', style: TextStyle(color: ColorPalette.textColorPrimaryDark)));
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createTodoItem,
          child: Icon(Icons.add),
          backgroundColor: ColorPalette.primaryColorDark,
        ),
      ),
    );
  }
}
