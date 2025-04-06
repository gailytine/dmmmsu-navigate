import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showText = false; // Controls fade-in effect for the text

  @override
  void initState() {
    super.initState();

    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Initialize the animation controller (set duration later)
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/logo_startup.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                // Set the animation duration
                _controller.duration = composition.duration;
                _controller.forward().whenComplete(() {
                  setState(() {
                    _showText = true; // Show text after animation
                  });

                  Future.delayed(const Duration(seconds: 2), () {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Restore UI
                    widget.onFinish(); // Navigate to main screen
                  });
                });
              },
              controller: _controller, // Assign controller properly
            ),
          ),
          const SizedBox(height: 20), // Space between logo and text
          AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: _showText ? 1.0 : 0.0,
            child: const Text(
              'DMMMSU NAVIGATE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 68, 138, 255),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
