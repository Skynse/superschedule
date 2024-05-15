import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduleup/services/firebase_service.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class PasswordTextField extends StatefulWidget {
  PasswordTextField(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.validator});
  TextEditingController controller;
  String labelText;
  String? Function(String?) validator;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: widget.validator,
    );
  }
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
            PasswordTextField(
              controller: passwordController,
              labelText: 'Password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }

                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PasswordTextField(
              controller: confirmPasswordController,
              labelText: 'Confirm Password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }

                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
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
            PasswordTextField(
              controller: passwordController,
              labelText: 'Password',
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
