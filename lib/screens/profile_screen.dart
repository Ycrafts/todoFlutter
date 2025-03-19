import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    // TODO: Implement API call to fetch user profile
    try {
      final userProfile = await _apiService.getUserProfile();
      setState(() {
        _emailController.text = userProfile['email']; // Assuming your API returns email
        _usernameController.text = userProfile['username']; // Assuming your API returns username
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile information: $error')),
      );
    }
  }

  Future<void> _updateProfile() async {
    final newEmail = _emailController.text;
    final newUsername = _usernameController.text;

    // TODO: Implement API call to update user profile
    try {
      bool success = await _apiService.updateUserProfile(newEmail, newUsername);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        // Optionally, you might want to reload the profile or navigate back
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $error')),
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
            backgroundColor: ColorPalette.primaryColorDark,
            foregroundColor: ColorPalette.textColorPrimaryDark,
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
          title: Text('Profile'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: ColorPalette.textColorSecondaryDark),
                  border: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.borderColorDark)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.primaryColorDark)),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                style: TextStyle(color: ColorPalette.textColorPrimaryDark),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: ColorPalette.textColorSecondaryDark),
                  border: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.borderColorDark)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorPalette.primaryColorDark)),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}