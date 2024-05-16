import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:umechat/api/apis.dart';
import 'package:umechat/main.dart';
import 'package:umechat/models/user_model.dart';
import 'package:umechat/screens/contacts_screen.dart';
import 'package:umechat/screens/profile_screen.dart';
import 'package:umechat/widgets/users_chat_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<UserModel> _list = [];
  List<UserModel> searchList = [];
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _isSearching = false;
  bool canPop = false;

  // _HomePageState();
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: canPop,
        onPopInvoked: (bool didPop) {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
              canPop = !didPop;
            });
          } else {
            setState(() {
              canPop = true;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.home),
            title: !_isSearching
                ? const Text('U & ME Chat')
                : TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Email,name...'),
                    onChanged: (val) {
                      searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          searchList.add(i);
                        }
                        setState(() {
                          searchList;
                        });
                      }
                    },
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(!_isSearching ? Icons.search : Icons.clear),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                                user: APIs.me,
                              )));
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list =
                      data?.map((e) => UserModel.fromJson(e.data())).toList() ??
                          [];
              }

              if (_list.isNotEmpty) {
                return ListView.builder(
                    padding: EdgeInsets.only(top: mq.height * 0.01),
                    itemCount: _isSearching ? searchList.length : _list.length,
                    itemBuilder: (context, index) {
                      return ChatCard(
                          user:
                              _isSearching ? searchList[index] : _list[index]);
                    });
              } else {
                return const Center(
                  child: Text(
                    'No User Found!',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ContactScreen()));
            },
            child: const Icon(Icons.add_comment_rounded),
          ),
        ),
      ),
    );
  }
}
