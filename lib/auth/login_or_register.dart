import 'package:flutter/widgets.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  bool showLoginPage = true;

  @override
  void initState() {
    super.initState();
    togglePages();
  }

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
    return RegisterPage(onTap: togglePages);
  } else {
    return LoginPage(onTap: togglePages);
  }
  }
}