import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:umechat/main.dart';
import 'package:umechat/models/user_model.dart';
import 'package:umechat/screens/chat_screen.dart';

class ChatCard extends StatefulWidget {
  final UserModel user;
  const ChatCard({super.key, required this.user});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * 0.03, vertical: 4),
        child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatScreen(user: widget.user)));
            },
            child: ListTile(
              title: Text(widget.user.name),
              subtitle: Text(
                widget.user.about,
                maxLines: 1,
              ),
              leading: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.03),
                  child: CachedNetworkImage(
                    height: mq.height * 0.055,
                    width: mq.height * 0.055,
                    imageUrl: widget.user.image,
                    fit: BoxFit.fill,
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(Icons.person)),
                  )),
              // CircleAvatar(
              //   child: Icon(CupertinoIcons.person),
              // ),
              trailing: const Text(
                "12:06:12",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            )));
  }
}
