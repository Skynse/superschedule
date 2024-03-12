import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:superschedule/pages/availability_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: InkWell(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        allowCompression: true,
                      );

                      if (result != null) {
                        File file = File(result.files.single.path!);
                        var ref = FirebaseStorage.instance
                            .ref()
                            .child('profile')
                            .child(FirebaseAuth.instance.currentUser!.uid);
                        await ref.putFile(file);
                        var url = await ref.getDownloadURL();
                        await FirebaseAuth.instance.currentUser!
                            .updatePhotoURL(url);
                        setState(() {});
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          FirebaseAuth.instance.currentUser!.photoURL ??
                              'https://via.placeholder.com/150'),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Display the user's name

                Text(
                  FirebaseAuth.instance.currentUser!.displayName ??
                      FirebaseAuth.instance.currentUser!.email!,
                  style: const TextStyle(fontSize: 24),
                ),

                const SizedBox(height: 16),

                // Display the user's email

                Text(
                  FirebaseAuth.instance.currentUser!.email ?? 'No Email',
                  style: const TextStyle(fontSize: 24),
                ),

                const SizedBox(height: 16),

                // edit account section

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditAccountPage(),
                      ),
                    );
                  },
                  child: const Text('Edit Account'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvailabilityPage(
                            uid: FirebaseAuth.instance.currentUser!.uid),
                      ),
                    );
                  },
                  child: const Text('Edit Availability'),
                ),

                // sign out section

                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({Key? key}) : super(key: key);

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = FirebaseAuth.instance.currentUser!.displayName ?? '';
    _emailController.text = FirebaseAuth.instance.currentUser!.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FirebaseAuth.instance.currentUser!
                        .updateDisplayName(_nameController.text);
                    await FirebaseAuth.instance.currentUser!
                        .updateEmail(_emailController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
