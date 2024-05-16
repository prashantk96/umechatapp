import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umechat/api/apis.dart';
import 'package:umechat/main.dart';
import 'package:umechat/screens/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  User? user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            TextField(
              controller: otpController,
            ),
            SizedBox(
              height: mq.height * 0.04,
            ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    _handleOtpVerification().then((user) async {
                      // Navigator.pop(context);

                      if (user != null) {
                        // await Future.delayed(const Duration(seconds: 2));
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
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (_) => const HomePage()));
                },
                child: Text('login'))
          ],
        ));
  }

  Future<UserCredential?> _handleOtpVerification() async {
    try {
      PhoneAuthCredential credential = await PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: otpController.text);

      final userx = await APIs.auth.signInWithCredential(credential);
      User? updatedUser = APIs.auth.currentUser;
      setState(() {
        user = updatedUser;
      });
      print(user);
      return userx;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
