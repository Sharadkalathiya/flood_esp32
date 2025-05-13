import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'sensor_data_screen.dart';
import 'signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  LoginScreen({required this.toggleTheme, required this.themeMode});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  bool isLoading = false;

  void login() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      // Validate email and password
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        setState(() {
          errorMessage = "Please enter both email and password";
          isLoading = false;
        });
        return;
      }

      // Attempt to sign in
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
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
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        default:
          message = 'An error occurred during sign in.';
      }
      setState(() {
        errorMessage = message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again.';
        isLoading = false;
      });
      print('Error during sign in: $e');
    }
  }

  void loginWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        setState(() {
          errorMessage = 'Google sign in was cancelled';
          isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // If user doesn't exist in Firestore, create a new document
          await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
            "name": userCredential.user!.displayName ?? "User",
            "email": userCredential.user!.email,
            "contact": "",
            "city": "Ahmedabad", // Default city
          });
        }

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
      setState(() {
        errorMessage = 'Failed to sign in with Google: ${e.message}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again.';
        isLoading = false;
      });
      print('Error during Google sign in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud, size: 80, color: Colors.blue),
                SizedBox(height: 10),
                Text(
                  "Flood Monitoring System",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                ),
                SizedBox(height: 10),
                Text(errorMessage, style: TextStyle(color: Colors.red)),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : Column(
                  children: [
                    ElevatedButton(
                      onPressed: login,
                      child: Text("Login"),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.g_mobiledata),
                      label: Text("Sign in with Google"),
                      onPressed: loginWithGoogle,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SignupScreen(
                        toggleTheme: widget.toggleTheme,
                        themeMode: widget.themeMode,
                      ),
                    ),
                  ),
                  child: Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
