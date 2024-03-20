import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scheduleup/models/group.dart';
import 'package:scheduleup/pages/groupView.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  Future<List<Group>> _getGroups() async {
    var user = FirebaseAuth.instance.currentUser;
    var groups = await FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: user!.uid)
        .get();

    List<Group> groupList = [];

    for (var group in groups.docs) {
      String id = group.id;
      var data = group.data();
      data.addAll({'id': id});
      groupList.add(Group.fromMap(data));
    }

    return groupList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        //fab
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateGroupForm()),
              );
              //navigate to create group page
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Group>>(
        future: _getGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No groups found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var group = snapshot.data![index];

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupView(group: group),
                    ),
                  );
                },
                title: Text(group.groupName),
              );
            },
          );
        },
      ),
    );
  }
}

class CreateGroupForm extends StatefulWidget {
  const CreateGroupForm({super.key});

  @override
  State<CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var user = FirebaseAuth.instance.currentUser;
                    var group = Group(
                      groupName: _groupNameController.text,
                      members: [user!.uid],
                    );

                    await FirebaseFirestore.instance
                        .collection('groups')
                        .add(group.toMap());

                    Navigator.pop(context);
                  }
                },
                child: Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
