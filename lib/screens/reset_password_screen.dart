import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import 'home_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0c1830),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [

            const SizedBox(height:100),

            const Text(
              "Reset Password",
              style: TextStyle(color: Colors.white,fontSize:22),
            ),

            const SizedBox(height:40),

            const CustomTextField(hint:"Password"),
            const CustomTextField(hint:"Confirm Password"),

            const SizedBox(height:20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity,50),
              ),
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: const Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}