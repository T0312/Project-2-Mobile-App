import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appbar_animated/appbar_animated.dart';
import '../auth/login_or_register.dart';
import '../components/gradient_scaffold.dart';
import '../components/text_field.dart';
import '../components/wall_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final userDoc =
        await FirebaseFirestore.instance.collection("Users").doc(currentUser.uid).get();
    setState(() {
      username = userDoc['username'];
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginOrRegister()),
    );
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Username': currentUser.displayName,
        'Likes': [],
      });
    }

    setState(() {
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradientColors: const [
        Color.fromARGB(255, 225, 225, 225),
        Color.fromARGB(255, 42, 42, 42),
      ],
      body: ScaffoldLayoutBuilder(
        backgroundColorAppBar:
            const ColorBuilder(Colors.transparent, Color.fromARGB(255, 42, 42, 42)),
        textColorAppBar: const ColorBuilder(Colors.white, Colors.amber),
        appBarBuilder: _appBar,
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .orderBy("TimeStamp", descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final post = snapshot.data!.docs[index];

                            // Check if the 'Username' field exists in the document
                            final username = post['Username'] ?? 'Unknown User';

                            return WallPost(
                              message: post['Message'],
                              user: username,
                              postId: post.id,
                              likes: List<String>.from(post['Likes'] ?? []),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: MyTextField(
                          controller: textController,
                          hintText: 'Add something to your feed...',
                          obscureText: false,
                        ),
                      ),
                      IconButton(
                        onPressed: postMessage,
                        icon: const Icon(Icons.arrow_circle_up,
                            color: Color.fromARGB(255, 186, 186, 186)),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Logged in as: $username",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context, ColorAnimated colorAnimated) {
    return AppBar(
      backgroundColor: colorAnimated.background,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: const Text(
        "Feed",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }
}
