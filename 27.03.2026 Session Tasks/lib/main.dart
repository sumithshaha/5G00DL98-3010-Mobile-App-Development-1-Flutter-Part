import 'package:flutter/material.dart';

/// Entry point of the Flutter application.
void main() {
  runApp(const MyApp());
}

/// Root widget that sets up MaterialApp with theme configuration.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

/// A simple login screen built with Column, SizedBox, and basic layout widgets.
/// UI only — no authentication functionality implemented.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // State variable for the "Remember me" checkbox
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a light background to keep the screen clean
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          // SingleChildScrollView prevents overflow on smaller screens
          child: SingleChildScrollView(
            child: Padding(
              // Horizontal padding so content doesn't touch screen edges
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                // Center everything vertically within available space
                mainAxisAlignment: MainAxisAlignment.center,
                // Stretch children to fill the width (important for text fields)
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- LOGO (loaded from assets) ----
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // App title below the logo
                  const Center(
                    child: Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ---- USERNAME TEXT FIELD ----
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---- PASSWORD TEXT FIELD ----
                  const TextField(
                    obscureText: true, // Hides the password input
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- "REMEMBER ME" CHECKBOX ----
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Remember me'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ---- LOGIN BUTTON ----
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // No functionality required — UI only
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
