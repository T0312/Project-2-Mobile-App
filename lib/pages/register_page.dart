import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_or_register.dart';
import '../components/button.dart';
import '../components/gradient_scaffold.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  bool _isDisposed = false;
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void dispose() {
    _isDisposed = true;
    // Dispose of controllers and other resources
    usernameTextController.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    try {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      if (passwordTextController.text != confirmPasswordTextController.text) {
        Navigator.pop(context);
        displayMessage("Passwords don't match!");
        return;
      }

      // Create user with email and password
      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Get the currently signed-in user
      final currentUser = authResult.user;
      if (currentUser != null) {
        // Update the user profile with the provided username
        await currentUser.updateDisplayName(usernameTextController.text);

        // Create a document in the Users collection
        await FirebaseFirestore.instance.collection("Users").doc(currentUser.uid).set({
          'username': usernameTextController.text,
          'userID': currentUser.uid,
          'bio': '',
        });
        Navigator.push(context,
          PageRouteBuilder(pageBuilder: (_, __, ___) => LoginOrRegister()),
        );
      }
    } on FirebaseAuthException catch (e) {
      displayMessage(e.code);
    } finally {
      if (!_isDisposed && context.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradientColors: [
        const Color.fromARGB(255, 225, 225, 225),
        Color.fromARGB(255, 42, 42, 42),
      ],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(
                  height: 50,
                ),
                const Text("Lets create an account for you"),
                const SizedBox(
                  height: 25,
                ),
                MyTextField(
                  controller: usernameTextController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextField(
                  controller: confirmPasswordTextController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(
                  height: 25,
                ),
                MyButton(
                  onTap: signUp,
                  text: 'Sign Up',
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
