import 'package:flutter/material.dart';
import 'package:umechat/api/apis.dart';
import 'package:umechat/main.dart';
import 'package:umechat/models/message_model.dart';

class MessageCard extends StatelessWidget {
  MessageCard({super.key, required this.message});
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == message.fromId ? senderCard() : recieverCard();
  }

  Widget senderCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.all(mq.width * 0.04),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * 0.04, vertical: mq.width * 0.01),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent),
              color: Colors.green.shade100,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30))),
          child: Text(
            message.msg,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(message.sent),
        )
      ],
    );
  }

  Widget recieverCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(mq.width * 0.04),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * 0.04, vertical: mq.width * 0.01),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              color: Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: Text(
            message.msg,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(message.sent),
        )
      ],
    );
  }
}
