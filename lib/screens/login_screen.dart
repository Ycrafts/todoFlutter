import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import your ApiService
import 'create_user_screen.dart';
import 'todo_list_screen.dart'; // Import the TodoListScreen
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  final ApiService _apiService = ApiService(); // Create an instance of ApiService
  final _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async { // Make the onPressed async
                  if (_formKey.currentState!.validate()) {
                    final String username = _usernameController.text;
                    final String password = _passwordController.text;

                    // Call the login method from ApiService
                    final String? token = await _apiService.login(username, password);

                    if (token != null) {
                      // Login successful, store the token and navigate to the next screen
                      print('Login successful! JWT: $token');
                      await _storage.write(key: 'jwt_token', value: token);
                      // TODO: Store the token securely
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => TodoListScreen()),
                      );
                    } else {
                      // Login failed, show an error message
                      setState(() {
                        _errorMessage = 'Invalid username or password';
                      });
                    }
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10), // Add some spacing
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateUserScreen()),
                  );
                },
                child: Text(
                  'Create Account',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}