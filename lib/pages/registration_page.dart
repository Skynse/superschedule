import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduleup/services/firebase_service.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Registration and Login'),
          bottom: TabBar(
            unselectedLabelColor: Colors.white,
            labelColor: Colors.amber,
            tabs: [
              Tab(text: 'Register'),
              Tab(text: 'Login'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RegistrationForm(formKey: _formKey),
            LoginForm(),
          ],
        ),
      ),
    );
  }
}

class RegistrationForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;

  RegistrationForm({required this.formKey});

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // form should have nice rounded textfields and nice spacing

    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your display name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ref
                      .read(firebaseServiceProvider)
                      .createUserWithEmailAndPassword(
                        emailController.text,
                        passwordController.text,
                        displayNameController.text,
                      );
                }
              },
              child: Text(
                'Get Started',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ref.read(firebaseServiceProvider).signInWithEmailAndPassword(
                      emailController.text, passwordController.text);
                }
              },
              child: Text('Login', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
