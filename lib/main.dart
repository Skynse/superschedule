import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scheduleup/firebase_options.dart';
import 'package:scheduleup/pages/dash.dart';
import 'package:scheduleup/services/firebase_service.dart';
import 'package:scheduleup/pages/registration_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseFirestore.instance
      .collection('events')
      .where('date', isLessThan: DateTime.now())
      .get()
      .then((snapshot) {
    for (var doc in snapshot.docs) {
      doc.reference.delete();
    }
  });

  runApp(ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  Widget build(BuildContext context) {
    var loggedIn = ref.watch(firebaseServiceProvider).authStateChanges;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StreamBuilder<User?>(
        stream: loggedIn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return RegistrationPage();
            } else {
              return Dashboard();
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
