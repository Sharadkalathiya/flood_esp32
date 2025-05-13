import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'sensor_data_screen.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  SignupScreen({required this.toggleTheme, required this.themeMode});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  String selectedCity = "Ahmedabad"; // Default city selection
  bool isLoading = false;

  final List<String> cityList = [
    "Ahmedabad", "Amreli", "Anand", "Aravalli", "Botad", "Banaskantha", "Bharuch",
    "Bhavnagar", "Chhota Udaipur", "Dahod", "Dang", "Devbhoomi Dwarka",
    "Gandhinagar", "Gir Somnath", "Jamnagar", "Junagadh", "Kheda", "Kutch",
    "Mehsana", "Mahisagar", "Morbi", "Narmada", "Navsari", "Panchmahal",
    "Patan", "Porbandar", "Rajkot", "Sabarkantha", "Surat", "Surendranagar",
    "Tapi", "Vadodara", "Valsad", "Vyara"
  ];

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        // Create user with email and password
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (userCredential.user != null) {
          final userData = {
            'email': emailController.text.trim(),
            'name': nameController.text.trim(),
            'contact': contactController.text.trim(),
            'city': selectedCity,
            'createdAt': FieldValue.serverTimestamp(),
          };
          print('User data type: \\${userData.runtimeType}, value: \\${userData}');
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(userData);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SensorDataScreen(
                  toggleTheme: widget.toggleTheme,
                  themeMode: widget.themeMode,
                ),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException: code=${e.code}, message=${e.message}');
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'This email is already registered. Please use a different email.';
            break;
          case 'invalid-email':
            message = 'Please enter a valid email address.';
            break;
          case 'operation-not-allowed':
            message = 'Email/password accounts are not enabled. Please contact support.';
            break;
          case 'weak-password':
            message = 'The password is too weak. Please use a stronger password.';
            break;
          default:
            message = 'An error occurred during sign up. Please try again.';
        }
        if (mounted) {
          setState(() {
            errorMessage = message;
            isLoading = false;
          });
        }
      } catch (e) {
        print('Firestore write error: $e');
        if (mounted) {
          setState(() {
            errorMessage = 'An unexpected error occurred. Please try again.';
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Sign Up", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Full Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: "Contact Number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit contact number';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  value: selectedCity,
                  items: cityList.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value.toString();
                    });
                  },
                  decoration: InputDecoration(labelText: "City"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a city';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Text(errorMessage, style: TextStyle(color: Colors.red)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : signUp,
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text("Sign Up"),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        toggleTheme: widget.toggleTheme,
                        themeMode: widget.themeMode,
                      ),
                    ),
                  ),
                  child: Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
