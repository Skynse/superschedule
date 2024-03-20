import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scheduleup/models/user.dart';
import 'package:scheduleup/services/firebase_service.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({Key? key}) : super(key: key);

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  Stream<List<Map<String, dynamic>>> _getFriends() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((event) => List<Map<String, dynamic>>.from(event['friends']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFriendForm()),
              );
            },
          ),
        ],
        title: Text('Friends List'),
      ),
      body: StreamBuilder<List<SuperUser>>(
        stream: FirebaseService().getFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No friends found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var friend = snapshot.data![index];
              return ListTile(
                  title: Text(friend.name),
                  subtitle: Text(friend.email),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'friends': FieldValue.arrayRemove([friend.toJson()])
                      });
                    },
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend.photoUrl ?? ''),
                  ));
            },
          );
        },
      ),
    );
  }
}

class AddFriendForm extends StatefulWidget {
  const AddFriendForm({Key? key}) : super(key: key);

  @override
  State<AddFriendForm> createState() => _AddFriendFormState();
}

class _AddFriendFormState extends State<AddFriendForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    // filter by email field
    // should not be ourselves
    var users = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: query + '\uf8ff')
        .where('email', isNotEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();

    return users.docs.map((e) => e.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListenableBuilder(
                    listenable: _nameController,
                    builder: (context, child) {
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: searchUsers(_nameController.text),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No users found'));
                          }

                          return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              var user = snapshot.data![index];
                              return ListTile(
                                title: Text(user['display_name']),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      user['photo_url'] ??
                                          'https://via.placeholder.com/150'),
                                ),
                                subtitle: Text(user['email']),
                                trailing: IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .update({
                                      'friends': FieldValue.arrayUnion([
                                        {
                                          'uid': user['uid'],
                                          'display_name': user['display_name'],
                                          'email': user['email'],
                                          'photo_url': user['photo_url']
                                        }
                                      ])
                                    });

                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    }),
              ),
            ],
          )),
    );
  }
}
