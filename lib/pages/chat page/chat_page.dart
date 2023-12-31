import 'package:chatapp/pages/bottomnav_bar.dart';
import 'package:chatapp/pages/chat%20page/message_bubble.dart';
import 'package:chatapp/pages/group_details.dart';
import 'package:chatapp/shared/local_parameters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../services/database_service.dart';
import '../snack_bar.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  bool sendButton = false;
  bool emojiShowing = false;

  String lastMessage = "";

  @override
  void initState() {
    getChatandAdmin();
    getLastMessage();

    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _scrollDown();
      });
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollDown();
    });
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  getLastMessage() async {
    DatabaseService().getLastMessage(widget.groupId).then((value) {
      setState(() {
        if (value == null) {
          lastMessage = "";
        } else {
          if (value.length >= 20) {
            lastMessage = value.substring(1, 20) + "...";
          } else {
            lastMessage = value;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => NavBar(
                          finalindex: 0,
                        )),
                (Route<dynamic> route) => false);
          },
        ),
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        centerTitle: false,
        backgroundColor: Parameters().appbar_BColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 8),
            GestureDetector(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage("lib/images/Kedy.jpg"),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.groupName,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return GroupDetails(
                      adminName: admin,
                      groupId: widget.groupId,
                      groupName: widget.groupName);
                }));
              },
            )
          ],
        ),
        actions: <Widget>[
          IconButton(
            padding: const EdgeInsets.only(right: 15),
            icon: const Icon(Icons.call),
            tooltip: 'ARAMA',
            onPressed: () {
              mySnackBar(context, "ARAMA YAPILCAK EMIN MISIN?");
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/images/background.jpeg"),
                fit: BoxFit.cover)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: <Widget>[
                // chat messages here
                Expanded(flex: 10, child: chatMessages(false)),
                Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                    child: SizedBox(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(35.0),
                                boxShadow: const [
                                  BoxShadow(
                                      offset: Offset(0, 3),
                                      blurRadius: 5,
                                      color: Colors.grey)
                                ],
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                      icon: Icon(
                                        Icons.emoji_emotions,
                                        color: Parameters().mIButton_Color,
                                      ),
                                      onPressed: () {
                                        emojiShowing = !emojiShowing;
                                      }),
                                  Expanded(
                                      child: TextFormField(
                                    onTap: () {
                                      Future.delayed(
                                          const Duration(milliseconds: 700),
                                          () {
                                        setState(() {
                                          _scrollDown();
                                        });
                                      });
                                    },
                                    onChanged: (value) {
                                      _scrollDown();
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          sendButton = true;
                                        });
                                      } else {
                                        setState(() {
                                          sendButton = false;
                                        });
                                      }
                                    },
                                    maxLines: 5,
                                    minLines: 1,
                                    controller: messageController,
                                    style: TextStyle(
                                        color: Parameters().mIButton_Color),
                                    decoration: InputDecoration(
                                      hintText: "Send a message...",
                                      hintStyle: TextStyle(
                                          color: Parameters().mIButton_Color,
                                          fontSize: 16),
                                      border: InputBorder.none,
                                    ),
                                  )),
                                  IconButton(
                                    icon: Icon(Icons.photo_camera,
                                        color: Parameters().mIButton_Color),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.attach_file,
                                        color: Parameters().mIButton_Color),
                                    onPressed: () {},
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Parameters().mIButton_Color,
                              child: IconButton(
                                iconSize: 25,
                                icon: Icon(
                                  sendButton ? Icons.send : Icons.mic,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (sendButton) {
                                    sendMessage();
                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      setState(() {
                                        _scrollDown();
                                      });
                                    });
                                    setState(() {
                                      sendButton = false;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  chatMessages(bool showAllMessages) {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                controller: _controller,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  if (!showAllMessages) {
                    if (index != 0) {
                      return MessageBubble(
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender'],
                        lastSender: snapshot.data.docs[index - 1]['sender'],
                        time: snapshot.data.docs[index]['time'],
                      );
                    } else {
                      return MessageBubble(
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender'],
                        lastSender: "",
                        time: snapshot.data.docs[index]['time'],
                      );
                    }
                  } else {
                    if (index > snapshot.data.docs.length - 20) {
                      if (index != 0) {
                        return MessageBubble(
                          message: snapshot.data.docs[index]['message'],
                          sender: snapshot.data.docs[index]['sender'],
                          sentByMe: widget.userName ==
                              snapshot.data.docs[index]['sender'],
                          lastSender: snapshot.data.docs[index - 1]['sender'],
                          time: snapshot.data.docs[index]['time'],
                        );
                      } else {
                        return MessageBubble(
                          message: snapshot.data.docs[index]['message'],
                          sender: snapshot.data.docs[index]['sender'],
                          sentByMe: widget.userName ==
                              snapshot.data.docs[index]['sender'],
                          lastSender: "",
                          time: snapshot.data.docs[index]['time'],
                        );
                      }
                    } else {
                      return const SizedBox(
                        height: 0.1,
                      );
                    }
                  }
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}

final ScrollController _controller = ScrollController();
_scrollDown() {
  _controller.jumpTo(_controller.position.maxScrollExtent);
}
