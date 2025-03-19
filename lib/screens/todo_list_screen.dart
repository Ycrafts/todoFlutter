import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_tracker/screens/profile_screen.dart';
import 'package:todo_tracker/screens/todo_list_detail_screen.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import '../models/todo_list.dart';
import '../theme.dart'; // Import the ColorPalette

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final ApiService _apiService = ApiService();
  final _storage = FlutterSecureStorage();
  late Future<List<TodoList>> _todoListsFuture;

  @override
  void initState() {
    super.initState();
    _loadTodoLists();
  }

  Future<void> _loadTodoLists() async {
    setState(() {
      _todoListsFuture = _apiService.getAllTodoLists();
    });
  }

  Future<void> _logout(BuildContext context) async {
    await _storage.delete(key: 'jwt_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _deleteTodoList(int? id) async {
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot delete todo list with a null ID')),
      );
      return;
    }
    bool success = await _apiService.deleteTodoList(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo list deleted successfully')),
      );
      _loadTodoLists(); // Reload the list after deletion
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete todo list')),
      );
    }
  }

  Future<void> _editTodoList(TodoList todoList) async {
    TextEditingController titleController = TextEditingController(text: todoList.name);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Todo List', style: TextStyle(color: ColorPalette.textColorPrimaryDark)),
          backgroundColor: ColorPalette.cardBackgroundColorDark,
          content: TextField(
            controller: titleController,
            style: TextStyle(color: ColorPalette.textColorPrimaryDark),
            decoration: InputDecoration(
              hintText: 'New title',
              hintStyle: TextStyle(color: ColorPalette.textColorHintDark),
              border: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.borderColorDark)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.primaryColorDark)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: ColorPalette.textColorLinkDark)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: ColorPalette.textColorLinkDark)),
              onPressed: () async {
                final newTitle = titleController.text;
                if (newTitle.isNotEmpty) {
                  bool success = await _apiService.editTodoList(todoList.id!, newTitle);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Todo list updated successfully')),
                    );
                    _loadTodoLists(); // Reload the list after editing
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update todo list')),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateTodoListDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController(); // Controller for the description
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Todo List', style: TextStyle(color: ColorPalette.textColorPrimaryDark)),
          backgroundColor: ColorPalette.cardBackgroundColorDark,
          content: Column( // Use a Column to arrange the TextFields vertically
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'Title',
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
                maxLines: 3, // Allow multiple lines for the description
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: ColorPalette.textColorLinkDark)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create', style: TextStyle(color: ColorPalette.textColorLinkDark)),
              onPressed: () async {
                final newTitle = titleController.text;
                final newDescription = descriptionController.text; // Get the description
                if (newTitle.isNotEmpty) {
                  bool success = await _apiService.createTodoList(newTitle, newDescription); // Call with both title and description
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Todo list created successfully')),
                    );
                    _loadTodoLists(); // Reload the list after creating
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create todo list')),
                    );
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Title cannot be empty')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: ColorPalette.backgroundColorDark,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorPalette.appBarColorDark,
          titleTextStyle: TextStyle(color: ColorPalette.textColorPrimaryDark),
          iconTheme: IconThemeData(color: ColorPalette.textColorPrimaryDark), // For the menu icon
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: ColorPalette.backgroundColorDark,
        ),
        listTileTheme: ListTileThemeData(
          textColor: ColorPalette.textColorPrimaryDark,
          iconColor: ColorPalette.textColorPrimaryDark,
        ),
        cardTheme: CardTheme(
          color: ColorPalette.cardBackgroundColorDark,
          margin: EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        ),
        iconTheme: IconThemeData(color: ColorPalette.iconColorDark),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: ColorPalette.textColorPrimaryDark),
          titleMedium: TextStyle(color: ColorPalette.textColorPrimaryDark, fontWeight: FontWeight.bold),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: ColorPalette.primaryColorDark,
          foregroundColor: ColorPalette.textColorPrimaryDark,
        ),
        colorScheme: ColorScheme.dark(
          primary: ColorPalette.primaryColorDark,
          secondary: ColorPalette.textColorSecondaryDark,
          error: ColorPalette.errorColorDark,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: Text('Todo Lists'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.account_circle,
                size: 35,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: ColorPalette.primaryColorDark,
                ),
                child: Text(
                  'Todo Tracker Menu',
                  style: TextStyle(
                    color: ColorPalette.textColorPrimaryDark,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Todo Lists'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  _logout(context);
                },
              ),
            ],
          ),
        ),
        body: FutureBuilder<List<TodoList>>(
          future: _todoListsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: ColorPalette.errorColorDark)));
            } else if (snapshot.data != null && snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No todo lists found.',
                      style: TextStyle(fontSize: 18, color: ColorPalette.textColorSecondaryDark),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Tap the "+" button below to add a new list.',
                      style: TextStyle(color: ColorPalette.textColorHintDark),
                    ),
                  ],
                ),
              );
            } else if (snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final todoList = snapshot.data![index];
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodoListDetailScreen(todoList: todoList),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(todoList.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editTodoList(todoList),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteTodoList(todoList.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No todo lists found.', style: TextStyle(color: ColorPalette.textColorPrimaryDark)));
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateTodoListDialog, // Call the create dialog
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}