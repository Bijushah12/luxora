import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  // 🔥 NEW FUNCTION (Firebase Signup)
  Future<void> createAccount() async {
    try {
      setState(() => isLoading = true);

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "name": name,
        "email": email,
        "uid": uid,
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully")),
      );

if (!mounted) return; 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

    } on FirebaseAuthException catch (e) {
      String message = "Error";

      if (e.code == 'email-already-in-use') {
        message = "Email already exists";
      } else if (e.code == 'weak-password') {
        message = "Password too weak";
      }
if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      body: SingleChildScrollView(
        child: Column(
          children: [

            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 320,
                    width: double.infinity,
                    color: AppColors.primary,
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.network(
                        "https://images.unsplash.com/photo-1547996160-81dfa63595aa",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: const [
                      Icon(Icons.stars_rounded, color: Colors.white, size: 40),
                      SizedBox(height: 10),
                      Text(
                        "LUXORA",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                      Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    const SizedBox(height: 25),

                    TextFormField(
                      controller: nameController,
                      validator: (v) => v!.isEmpty ? "Enter name" : null,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: inputDecoration("User Name", Icons.person),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: emailController,
                      validator: (v) => v!.isEmpty ? "Enter email" : null,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: inputDecoration("Email Address", Icons.email),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      validator: (v) {
                        if (v!.isEmpty) return "Enter password";
                        if (v.length < 6) return "Min 6 characters";
                        return null;
                      },
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: inputDecoration("Password", Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.textDark,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: confirmController,
                      obscureText: hidePassword,
                      validator: (v) {
                        if (v != passwordController.text) {
                          return "Password not match";
                        }
                        return null;
                      },
                      style: const TextStyle(color: AppColors.textDark),
                      decoration:
                          inputDecoration("Confirm Password", Icons.lock_outline),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  createAccount();
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "SIGN UP",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have account?",
                          style: TextStyle(color: AppColors.textLight),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textLight),
      prefixIcon: Icon(icon, color: AppColors.textDark),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

