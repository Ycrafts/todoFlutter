import 'package:flutter/material.dart';
import 'package:todo_tracker/screens/login_screen.dart';
import 'package:todo_tracker/screens/todo_list_screen.dart';
import '../services/api_service.dart';
import '../theme.dart'; // Import your ColorPalette

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
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: ColorPalette.backgroundColorDark,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorPalette.appBarColorDark,
          titleTextStyle: TextStyle(color: ColorPalette.textColorPrimaryDark),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.borderColorDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.primaryColorDark),
          ),
          labelStyle: TextStyle(color: ColorPalette.textColorSecondaryDark),
          hintStyle: TextStyle(color: ColorPalette.textColorHintDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.buttonColorDark,
            foregroundColor: ColorPalette.buttonTextColorDark,
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: ColorPalette.textColorPrimaryDark),
          titleMedium: TextStyle(color: ColorPalette.textColorPrimaryDark),
          labelLarge: TextStyle(color: ColorPalette.textColorPrimaryDark),
        ),
        colorScheme: ColorScheme.dark(
          primary: ColorPalette.primaryColorDark,
          secondary: ColorPalette.textColorSecondaryDark,
          error: ColorPalette.errorColorDark,
        ),
      ),
      child: Scaffold(
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
                  style: TextStyle(color: ColorPalette.textColorPrimaryDark),
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
                  style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
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
                  style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final String username = _usernameController.text;
                      final String email = _emailController.text;
                      final String password = _passwordController.text;
                      // print('Username: $username');
                      // print('Email: $email');
                      // print('Password: $password');

                      String? registrationResult = await _apiService.registerUser(username, email, password);

                      if (registrationResult == null || registrationResult == 'success') {

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Account created successfully!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        Navigator.pop(context);
                      } else if (registrationResult == 'Username already taken') {
                        // Handle duplicate username error
                        setState(() {
                          _errorMessage = 'Username already taken. Please choose a different one.';
                        });
                      } else {
                        // Handle other registration failures
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
                      style: TextStyle(color: ColorPalette.errorColorDark),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}