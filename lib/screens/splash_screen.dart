import 'package:flutter/material.dart';
import 'login_screen.dart'; // Ensure this file exists in your project

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Online Transparent Luxury Watch URL
    const String watchImageUrl = 'https://pngimg.com/uploads/watch/watch_PNG9894.png';

    return Scaffold(
      backgroundColor: const Color(0xFFC9BB9D),
      body: SafeArea(
        child: Stack(
          children: [
            /// 1. TOP HEADER
            Positioned(
              top: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars_rounded, color: Colors.black.withOpacity(0.7), size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        "LUXORA",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.menu_rounded, color: Colors.black87, size: 30),
                ],
              ),
            ),

            /// 2. CENTER WATCH IMAGE (Using Image.network)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80, bottom: 180),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    Image.network(
                      watchImageUrl,
                      height: 380,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const CircularProgressIndicator(color: Colors.white);
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.watch, size: 120, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),

            /// 3. TEXT CONTENT
            Positioned(
              bottom: 140,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  const Text(
                    "THE ART OF TIMEKEEPING",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Luxury watches crafted for distinction.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            /// 4. BOTTOM SWIPE SLIDER (Left to Right to Login)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: GestureDetector(
                // SWIPE LOGIC: Left to Right
                onHorizontalDragEnd: (details) {
                  // If swipe velocity is positive and fast enough
                  if (details.primaryVelocity! > 300) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff998C74).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Starting Point (Watch Icon)
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.watch_outlined, color: Colors.black, size: 24),
                      ),
                      
                      // Visual Swipe Indicator
                      const Row(
                        children: [
                          Text("Swipe to Start  ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white54),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white70),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                        ],
                      ),

                      // Target Point Icon
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.black.withOpacity(0.4),
                        child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}