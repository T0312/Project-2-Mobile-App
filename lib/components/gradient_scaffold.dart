import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/drawer.dart';
import '../auth/login_or_register.dart';
import '../pages/profile_page.dart';


class GradientScaffold extends StatefulWidget {
  final Widget body;
  final List<Color> gradientColors;

  const GradientScaffold({
    Key? key,
    required this.body,
    this.gradientColors = const [Colors.blue, Colors.purple],
  }) : super(key: key);

  @override
  State<GradientScaffold> createState() => _GradientScaffoldState();
}

class _GradientScaffoldState extends State<GradientScaffold> {

  void signOut() {
    FirebaseAuth.instance.signOut();
  Navigator.push(context,
          PageRouteBuilder(pageBuilder: (_, __, ___) => LoginOrRegister()),
          );
  }

  void goToProfilePage() {
    Navigator.pop(context);

    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const ProfilePage()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradientColors,
            begin: Alignment.topCenter,
            end: Alignment(1, 1),
          ),
        ),
        child: widget.body,
        ),
      );
  }
}
