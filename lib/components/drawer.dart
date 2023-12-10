import 'package:flutter/material.dart';
import '../components/list_tile.dart';
import '../pages/home_page.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Column(
          children: [
                const DrawerHeader(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 64,
              ),
            ),
            MyListTile(
              icon: Icons.home,
              text: 'H O M E',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
      builder: (context) => const HomePage()));
              },
            ),
            MyListTile(
              icon: Icons.account_circle,
              text: 'P R O F I L E',
              onTap: onProfileTap,
            ),
            SizedBox(
              height: 525
            ),
            MyListTile(
              icon: Icons.logout,
              text: 'L O G O U T',
              onTap: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}
