import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Contact> contacts = [];
  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  void getPermissions() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      setState(() {});
      log(contacts[0].phones[0].number.toString());
    } else {
      try {
        log('Hello');
        await Permission.contacts.request();
        log("Permission requested");
        getPermissions();
      } catch (e) {
        log(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: contacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                Contact? contactWithPhoneNumber;

                // Find the next contact with a phone number
                for (int i = index; i < contacts.length; i++) {
                  if (contacts[i].phones.isNotEmpty) {
                    contactWithPhoneNumber = contacts[i];
                    break;
                  }
                }

                // If no contact with phone number found, return an empty container
                if (contactWithPhoneNumber == null) {
                  return Container();
                }

                return InkWell(
                  onTap: () {},
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(contactWithPhoneNumber.displayName[0]),
                    ),
                    title: Text(contactWithPhoneNumber.displayName),
                    subtitle: Text(contactWithPhoneNumber.phones[0].number),
                  ),
                );
              },
            ),
    );
  }
}
