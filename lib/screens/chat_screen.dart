import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:umechat/api/apis.dart';
import 'package:umechat/main.dart';
import 'package:umechat/models/message_model.dart';
import 'package:umechat/models/user_model.dart';
import 'package:umechat/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;
  ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  TextEditingController _controller = TextEditingController();

  FilePickerResult? _file;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _file = result;
        log(_file.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false, flexibleSpace: _appBar()),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(child: SizedBox());

                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map(
                                        (e) => MessageModel.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  padding:
                                      EdgeInsets.only(top: mq.height * 0.01),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _list.length,
                                  itemBuilder: (context, index) {
                                    return MessageCard(message: _list[index]);
                                  });
                            } else {
                              return const Center(
                                child: Text(
                                  'Say Hi..👋',
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }
                        }
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: mq.height * 0.04, left: 10, right: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showEmojiPicker(context);
                                },
                                icon: const Icon(
                                  CupertinoIcons.smiley,
                                  color: Colors.indigo,
                                ),
                              ),
                              Expanded(
                                  child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'write something',
                                    hintStyle: TextStyle(
                                        color: Colors.indigoAccent
                                            .withOpacity(0.4))),
                              )),
                              IconButton(
                                onPressed: () {
                                  _openFilePicker();
                                },
                                icon: const Icon(
                                  CupertinoIcons.photo,
                                  color: Colors.indigo,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  CupertinoIcons.camera,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            if (_controller.text != '') {
                              APIs.sendMessage(widget.user, _controller.text);
                              _controller.clear();
                            }
                          },
                          icon: const Icon(
                            CupertinoIcons.paperplane,
                            color: Colors.indigo,
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _appBar() {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.5),
            child: CachedNetworkImage(
              imageUrl: widget.user.image,
              height: mq.height * 0.045,
              width: mq.height * 0.045,
              fit: BoxFit.fill,
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(Icons.person)),
            )),
        const SizedBox(
          width: 20,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54),
            ),
            Text(
              widget.user.lastActive,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54),
            ),
          ],
        )
      ],
    );
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allow the bottom sheet to take the full screen height
      builder: (context) {
        return SingleChildScrollView(
          reverse:
              true, // Reverse the scroll direction to keep the Emoji Picker at the bottom
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: EmojiPicker(
              // Pass your configuration
              onEmojiSelected: (category, emoji) {
                setState(() {
                  _controller.text += emoji.emoji;
                });
              },
              onBackspacePressed: () {
                setState(() {
                  _controller.text = _controller.text
                      .substring(0, _controller.text.length - 1);
                });
              },
            ),
          ),
        );
      },
    );
  }
}
