import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:umechat/main.dart';
import 'package:umechat/screens/home_screen.dart';
import 'package:umechat/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in, navigate to the home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // User is not signed in, navigate to the login page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });

    // Delayed navigation in case Firebase authentication takes too long to respond
    Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to UME Chat',
        ),
      ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('assets/images/communications.png')),

          //google signin
          Positioned(
              bottom: mq.height * .01,
              width: mq.width,
              height: mq.height * .15,
              child: const Text(
                "Made with Love ❤️",
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }
}
