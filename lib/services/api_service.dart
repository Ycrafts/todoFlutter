import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/todo_item.dart';
import '../models/todo_list.dart';
import 'package:intl/intl.dart';

class ApiService {
  final String baseUrl = 'url_to_backendAPI';

  final _storage = FlutterSecureStorage();

  Future<List<TodoList>> getAllTodoLists() async {
    final String? token = await _storage.read(key: 'jwt_token');
    print("token:$token");
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/todo-lists'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => TodoList.fromJson(json)).toList();
    } else {
      print('Failed to load todo lists with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load todo lists');
    }
  }

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'usernameOrEmail': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['token'];
    } else {
      print('Login failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }


  Future<String?> registerUser(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('Registration Response Status Code: ${response.statusCode}');
      print('Registration Response Body: ${response.body}');

      if (response.statusCode == 201) {
        return null;
      } else if (response.statusCode == 400) {

        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData.containsKey('message') && responseData['message'] == 'Username already exists') {
            return 'Username already taken';
          } else {
            return 'Failed to create account. Please try again.';
          }
        } catch (e) {
          print('Error decoding response body: $e');
          return 'Failed to create account. Please try again.';
        }
      } else {
        return 'Failed to create account. Please try again.';
      }
    } catch (error) {
      print('Error during registration: $error');
      return 'Failed to connect to the server.';
    }
  }

  Future<bool> deleteTodoList(int id) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }
    final response = await http.delete(
      Uri.parse('$baseUrl/todo-lists/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      print('Todo list with ID $id deleted successfully');
      return true;
    } else {
      print('Failed to delete todo list with ID $id. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  Future<bool> editTodoList(int id, String newTitle) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }
    final response = await http.put(
      Uri.parse('$baseUrl/todo-lists/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'name': newTitle,
      }),
    );

    if (response.statusCode == 200) {
      print('Todo list with ID $id updated successfully');
      return true;
    } else {
      print('Failed to update todo list with ID $id. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }


  Future<bool> createTodoList(String title, String description) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/todo-lists'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'name': title,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      print('Todo list created successfully');
      return true;
    } else {
      print('Failed to create todo list with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  Future<List<TodoItem>> getTodoItems(int todoListId) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/todo-items/lists/$todoListId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => TodoItem.fromJson(json)).toList();
    } else {
      print('Failed to load todo items with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 404) {
        throw Exception('Todo List not found');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to access items in this todo list');
      } else {
        throw Exception('Failed to load todo items');
      }
    }
  }

  Future<bool> createTodoItem(int todoListId, String name, String? description, String dueDateString) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }


    final formattedDueDate = _formatDateTime(dueDateString);

    final response = await http.post(
      Uri.parse('$baseUrl/todo-items'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'description': description,
        'dueDate': formattedDueDate,
        'todoListId': todoListId,
      }),
    );
    if (response.statusCode == 201) {
      print('Todo item created successfully');
      return true;
    } else {
      print('Failed to create todo item with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  Future<bool> editTodoItem(int todoListId, int itemId, String name, String? description, String dueDateString) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }


    final formattedDueDate = _formatDateTime(dueDateString);

    final response = await http.put(
      Uri.parse('$baseUrl/todo-items/$itemId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'id': itemId,
        'name': name,
        'description': description,
        'dueDate': formattedDueDate,
        'todoList': {'id': todoListId},
      }),
    );
    if (response.statusCode == 200) {
      print('Todo item updated successfully');
      return true;
    } else {
      print('Failed to update todo item with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  // function to format the date
  String _formatDateTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
      return formatter.format(dateTime);
    } catch (e) {

      print('Error parsing date: $e');
      return dateString;
    }
  }

  Future<bool> deleteTodoItem(int todoListId, int itemId) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }
    final response = await http.delete(
      Uri.parse('$baseUrl/todo-items/$itemId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 204) {
      print('Todo item deleted successfully');
      return true;
    } else {
      print('Failed to delete todo item with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  Future<bool> updateTodoItemCompletion(TodoItem todoItem, bool isCompleted) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }
    final response = await http.put(
      Uri.parse('$baseUrl/todo-items/${todoItem.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'id': todoItem.id.toString(),
        'name': todoItem.name,
        'description': todoItem.description ?? '',
        'status': isCompleted ? 'COMPLETED' : 'PENDING',
        'dueDate': todoItem.dueDate,

      }),
    );
    if (response.statusCode == 200) {
      print('Todo item completion status updated successfully');
      return true;
    } else {
      print('Failed to update todo item completion status with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }

    print('Retrieved JWT Token: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load user profile with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load user profile');
    }
  }

  Future<bool> updateUserProfile(String newEmail, String newUsername) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No JWT found, user not authenticated');
    }

    try {

      final userProfile = await getUserProfile();
      final userId = userProfile['id'];
      if (userId == null) {
        throw Exception('Could not retrieve current user ID');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'email': newEmail,
          'username': newUsername,
        }),
      );

      if (response.statusCode == 200) {
        print('User profile updated successfully');
        return true;
      } else {
        print('Failed to update user profile with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error updating user profile: $error');
      return false;
    }
  }
}