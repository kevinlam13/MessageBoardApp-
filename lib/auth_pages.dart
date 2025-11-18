import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogin = true;

  void toggle() => setState(() => showLogin = !showLogin);

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? LoginPage(onSwitchToRegister: toggle)
        : RegisterPage(onSwitchToLogin: toggle);
  }
}

// -------------------- LOGIN PAGE --------------------

class LoginPage extends StatefulWidget {
  final VoidCallback onSwitchToRegister;

  const LoginPage({super.key, required this.onSwitchToRegister});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = 'An unexpected error occurred.');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onSwitchToRegister,
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- REGISTER PAGE --------------------

class RegisterPage extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const RegisterPage({super.key, required this.onSwitchToLogin});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final role = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  String? error;

  Future<void> register() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // 1) Create the auth user
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User registration failed.');
      }

      // 2) Create Firestore user profile
      final usersRef = FirebaseFirestore.instance.collection('users');

      await usersRef.doc(user.uid).set({
        'uid': user.uid,
        'email': email.text.trim(),
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'role': role.text.trim(),
        'registrationDate': FieldValue.serverTimestamp(),
      });
      // After this, AuthGate will detect logged-in user and navigate to MessageBoardsPage
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = 'Failed to register. Please try again.');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              TextField(
                controller: firstName,
                decoration: const InputDecoration(labelText: "First Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastName,
                decoration: const InputDecoration(labelText: "Last Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: role,
                decoration: const InputDecoration(
                  labelText: "Role (e.g., Student, Teacher)",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : register,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Create Account"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onSwitchToLogin,
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
