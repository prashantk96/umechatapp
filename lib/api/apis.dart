import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:umechat/models/message_model.dart';
import 'package:umechat/models/user_model.dart';
import 'package:intl/intl.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static User get user => auth.currentUser!;
  static late UserModel me;
  static FirebaseStorage storage = FirebaseStorage.instance;

//for storing current user info
  // static UserModel me = UserModel(
  //     id: user.uid,
  //     name: user.displayName.toString(),
  //     email: user.email.toString(),
  //     about: "Hey, I'm using We Chat!",
  //     image: user.photoURL.toString(),
  //     createdAt: '',
  //     isOnline: false,
  //     lastActive: '',
  //     pushToken: '');

//to check user already exist returns bool

  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

//get current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = UserModel.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

//to create new user
  static Future<void> createUser() async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      final userModel = UserModel(
          image: user.photoURL.toString(),
          about: "hello there i am using ume chat",
          name: user.displayName.toString(),
          createdAt: time,
          isOnline: false,
          id: user.uid,
          lastActive: time,
          pushToken: "",
          email: user.email.toString(),
          mobileNumber: user.phoneNumber ?? "");

      return await firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  //to get all users

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///-------------- chat messages api ----------------
  static String getConvesationID(String id) {
    return user.uid.hashCode <= id.hashCode
        ? '${user.uid}_$id'
        : '${id}_${user.uid}';
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      UserModel user) {
    return firestore
        .collection('chats/${getConvesationID(user.id)}/messages')
        .snapshots();
  }

  static Future<void> sendMessage(UserModel sender, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch;
    final String sentTime = formatTimestamp(time);
    final MessageModel message = MessageModel(
        toId: sender.id,
        type: Type.text,
        fromId: user.uid,
        msg: msg,
        read: '',
        sent: sentTime);
    final ref =
        firestore.collection('chats/${getConvesationID(sender.id)}/messages/');
    await ref.doc(time.toString()).set(message.toJson());
  }

  static String formatTimestamp(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final String formattedTime = DateFormat.jm()
        .format(dateTime); // 'jm' format gives 12-hour format with AM/PM
    return formattedTime;
  }

  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query Firestore collection for users with matching phone numbers
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      // Check if any documents match the query
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle errors, such as Firestore not being available
      print('Error checking phone number registration: $e');
      return false;
    }
  }
}
