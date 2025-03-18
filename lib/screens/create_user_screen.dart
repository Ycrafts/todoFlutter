import 'package:flutter/material.dart';
import 'package:todo_tracker/screens/login_screen.dart';
import 'package:todo_tracker/screens/todo_list_screen.dart';
import '../services/api_service.dart';

class CreateUserScreen extends StatefulWidget {
  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {

  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Basic email validation using a regular expression
                  final emailRegex = RegExp(
                      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
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
                onPressed: () async { // Make it async
                  if (_formKey.currentState!.validate()) {
                    final String username = _usernameController.text;
                    final String email = _emailController.text;
                    final String password = _passwordController.text;
                    print('Username: $username');
                    print('Email: $email');
                    print('Password: $password');

                    bool registrationSuccessful = await _apiService.registerUser(username,email,password);

                    if (registrationSuccessful) {
                      // 1. Show registered successfully message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Account created successfully!'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      // 2. Automatically take them to Login Page
                      Navigator.pop(context); // Use pop to go back to the previous screen (LoginScreen)
                    } else {
                      // Handle registration failure (you might want to show a specific error message)
                      setState(() {
                        _errorMessage = 'Failed to create account. Please try again.';
                      });
                    }
                  }
                },
                child: Text('Create Account'),
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