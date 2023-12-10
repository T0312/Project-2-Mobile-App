import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_or_register.dart';
import '../pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final User? user = snapshot.data;

          if (user != null) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("Users").doc(user.uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final username = userSnapshot.data!['username'];
                  if (username.isNotEmpty) {
                    return const HomePage();
                  }
                }
                return const LoginOrRegister();
              },
            );
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
