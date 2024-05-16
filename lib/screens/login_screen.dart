import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:umechat/api/apis.dart';
import 'package:umechat/helper/dialogs.dart';
import 'package:umechat/main.dart';
import 'package:umechat/screens/home_screen.dart';
import 'package:umechat/screens/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  TextEditingController mobileController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  String verificationId = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to U ME Chat',
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .15,
              right: _isAnimate ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .5,
              duration: const Duration(seconds: 1),
              child: Image.asset('assets/images/communications.png')),

          Positioned(
            bottom: mq.height * .30,
            left: mq.width * .050,
            width: mq.width * .9,
            height: mq.height * .07,
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.phone,
              controller: mobileController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.indigo.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
          ),
          Positioned(
            bottom: mq.height * .20,
            left: mq.width * .050,
            width: mq.width * .9,
            height: mq.height * .07,
            child: ElevatedButton(
              onPressed: () async {
                bool isSuccess = await _handleMobileVerification();
                if (isSuccess) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OtpScreen(
                                verificationId: verificationId,
                              )));
                }
              },
              child: Text('Sign In with Mobile'),
            ),
          ),

          //google signin
          Positioned(
              bottom: mq.height * .10,
              left: mq.width * .050,
              width: mq.width * .9,
              height: mq.height * .07,
              child: ElevatedButton.icon(
                onPressed: () {
                  Dialogs.showProgressBar(context);
                  try {
                    _handleSignIn().then((user) async {
                      Navigator.pop(context);

                      if (user != null) {
                        log('Hello There : Prashant');
                        if ((await APIs.userExist())) {
                          log('direct Heven');
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        } else {
                          log('creating user');
                          await APIs.createUser().then((value) =>
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage())));
                        }
                      }
                    });
                  } catch (e) {
                    log(e.toString());
                  }
                },
                icon: Image.asset(
                  'assets/images/google.png',
                  height: mq.height * 0.04,
                ),
                label: const Text('sign in with Google'),
              )),
        ],
      ),
    );
  }

  Future<UserCredential?> _handleSignIn() async {
    try {
      //creating instances
      GoogleSignIn googleSignIn = GoogleSignIn();
      FirebaseAuth auth = FirebaseAuth.instance;

      //triggering sign in method
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      return await auth.signInWithCredential(credential);
    } catch (error) {
      log(error.toString());
      Dialogs.showSnackbar(
          context, 'Something went Wrong..please check internet connection');
    }
    return null;
  }

  Future<bool> _handleMobileVerification() async {
    try {
      String phoneNumber =
          "+91" + mobileController.text; // Assuming it's Indian number format
      await APIs.auth.verifyPhoneNumber(
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException ex) {},
        codeSent: (String verificationid, int? resendToken) {
          setState(() {
            verificationId = verificationid;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        phoneNumber: phoneNumber,
      );
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
