import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  Widget box(){
    return Container(
      width:50,
      height:50,
      margin:const EdgeInsets.symmetric(horizontal:5),
      decoration:BoxDecoration(
        color:const Color(0xff1c2a4a),
        borderRadius:BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0c1830),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Text(
            "Enter OTP Password",
            style: TextStyle(color: Colors.white,fontSize:22),
          ),

          const SizedBox(height:30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              box(),box(),box(),box()
            ],
          ),

          const SizedBox(height:40),

          ElevatedButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
              );
            },
            child: const Text("Verify"),
          )
        ],
      ),
    );
  }
}