import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Logo and Title
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 40,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "DMMMSU Navigate",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Expanded IntroductionScreen (Centers Content)
            Expanded(
              child: IntroductionScreen(
                pages: [
                  _buildPage(
                    title: "Welcome to DMMMSU Navigate",
                    body: "Find your way around campus with ease.",
                    imagePath: "assets/images/clipart/compass.png",
                  ),
                  _buildPage(
                    title: "Find Buildings & Offices",
                    body: "Locate any building or office in a few taps.",
                    imagePath: "assets/images/clipart/building.png",
                  ),
                  _buildPage(
                    title: "Stay Updated on School Events",
                    body: "Get event notifications and find locations easily.",
                    imagePath: "assets/images/clipart/notification.png",
                  ),
                  _buildPage(
                    title: "Start Navigating",
                    body: "Get step-by-step directions on campus.",
                    imagePath: "assets/images/clipart/user_location.png",
                    isLastPage: true,
                    context: context,
                  ),
                ],
                globalBackgroundColor: Colors.white,
                showSkipButton: true,
                showDoneButton: false,
                skip: Text("Skip", style: TextStyle(color: Colors.blue)),
                next: Icon(Icons.arrow_forward, color: Colors.blue),
                done: null, // Set to null to avoid assertion error
                onDone: () {}, // Must be provided even if unused
                dotsDecorator: DotsDecorator(
                  size: Size(10, 10),
                  color: Colors.grey,
                  activeColor: Colors.blue,
                  activeSize: Size(22, 10),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  PageViewModel _buildPage({
    required String title,
    required String body,
    required String imagePath,
    bool isLastPage = false,
    BuildContext? context,
  }) {
    return PageViewModel(
      titleWidget: SizedBox.shrink(), // Remove default title
      bodyWidget: Center(
        child: Container(
          height: 550,
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(66, 25, 27, 101),
                blurRadius: 4,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                imagePath,
                height: 300,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              if (isLastPage && context != null) ...[
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => goToHome(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.zero,
        contentMargin: EdgeInsets.zero,
        fullScreen: false,
        pageColor: Colors.white,
      ),
    );
  }
}
