import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';
import 'package:lcrealtime/Widgets/MessageList.dart';
import 'package:lcrealtime/Widgets/InputMessageView.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';

class ConversationDetailPage extends StatefulWidget {
  final Conversation conversation;

  ConversationDetailPage({Key key, @required this.conversation})
      : super(key: key);
  @override
  _ConversationDetailPageState createState() =>
      new _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  ScrollController _scrollController = ScrollController();

  Message _firstMessage;
  List<Message> _firstPageMessages;

  @override
  void initState() {
    super.initState();
    print(this.widget.conversation.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(this.widget.conversation.name),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
//              onPressed: 跳转到设置页面,
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: FutureBuilder<List<Message>>(
            future: queryMessages(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // 请求已结束
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return Column(
                    children: <Widget>[
                      MessageList(
                          scrollController: _scrollController,
                          conversation: this.widget.conversation,
                          firstPageMessages: snapshot.data,
                          firstMessage: _firstMessage),
                      InputMessageView(
                          scrollController: _scrollController,
                          conversation: this.widget.conversation),
                    ],
                  );
                }
              } else {
                // 请求未结束，显示loading
                return CircularProgressIndicator();
              }
            },
          ),
        ));
  }

//  void slideToEnd() {
//    _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 40);
//  }
  Future<List<Message>> queryMessages() async {
    List<Message> messages;
    try {
      messages = await this.widget.conversation.queryMessage(
            limit: 10,
          );
      print(messages.length);
      _firstMessage = messages.first;
    } catch (e) {
      print(e.message);
    }
    return messages;
  }
}
