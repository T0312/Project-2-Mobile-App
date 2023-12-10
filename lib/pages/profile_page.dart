import 'package:appbar_animated/appbar_animated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/text_box.dart';
import '../components/gradient_scaffold.dart';
import '../components/wall_post.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  String username = '';
  String biography = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDoc = await usersCollection.doc(currentUser.uid).get();
    setState(() {
      username = userDoc['username'];
      biography = userDoc['bio'];
    });
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.uid).update({field: newValue});
    }
    _loadUserData();
  }

  Future<void> _deletePost(String postId) async {
    await FirebaseFirestore.instance.collection("User Posts").doc(postId).delete();
    // Reload the posts after deletion
    setState(() {});
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
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const Icon(
                    Icons.person,
                    size: 172,
                  ),
                  Text(
                    username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 25.0),
                    child: const Text(
                      'My Details',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  MyTextBox(
                    sectionName: 'Username',
                    text: username,
                    onPressed: () => editField('username'),
                  ),
                  MyTextBox(
                    sectionName: 'Biography',
                    text: biography,
                    onPressed: () => editField('bio'),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 25.0),
                    child: const Text(
                      'My Posts',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 350,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .where('Username', isEqualTo: username)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index];

                          // Check if the 'Username' field exists in the document
                          final username = post['Username'] ?? 'Unknown User';

                          return Column(
                            children: [
                              WallPost(
                                message: post['Message'],
                                user: username,
                                postId: post.id,
                                likes: List<String>.from(post['Likes'] ?? []),
                              ),
                              if (username == this.username)
                                // Only show delete button for the user's own posts
                                ElevatedButton(
                                  onPressed: () => _deletePost(post.id),
                                  child: const Text('Delete Post'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                            ],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context, ColorAnimated colorAnimated) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: const Text(
        "Profile Page",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }
}
