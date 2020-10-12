import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';
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
//  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  TextEditingController renameController = TextEditingController();

  Message _firstMessage;
  CurrentClient currentClint;

  @override
  void initState() {
    super.initState();
    currentClint = CurrentClient();
    //进入会话详情页面，标记会话已读
    this.widget.conversation.read();
    print(this.widget.conversation.id);





  }

  @override
  void deactivate() async {
    super.deactivate();
//    //刷新列表
//    mess.emit(MyEvent.ConversationRefresh);
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
              onPressed: () {
                showConfirmDialog();
              },
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
                  return Container(
                    height: 60.0,
                    child: Center(
                      child: Text("Error: ${snapshot.error}"),
                    ),
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      MessageList(
//                          scrollController: _scrollController,
                          conversation: this.widget.conversation,
                          firstPageMessages: snapshot.data,
                          firstMessage: _firstMessage),
                      InputMessageView(
//                          scrollController: _scrollController,
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

  void updateConInfo() async {
    if (renameController.text != null && renameController.text != '') {
      await widget.conversation.updateInfo(attributes: {
        'name': renameController.text,
      });
//      setState(() {});


      List conversations;
      ConversationQuery query = currentClint.client.conversationQuery();
      query.whereEqualTo('objectId', widget.conversation.id);

      conversations = await query.find();
      Conversation conversationFirst = conversations.first;
      print('name--->' + conversationFirst.name);


    } else {
      showToastRed('名称不能为空');
    }
  }

  Future<bool> showConfirmDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "修改会话名称：",
            style: new TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          content: TextField(
            controller: renameController,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("确认"),
              onPressed: () {
                updateConInfo();
                //关闭对话框并返回true
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Message>> queryMessages() async {
    List<Message> messages;
    try {
      messages = await this.widget.conversation.queryMessage(
            limit: 10,
          );
      _firstMessage = messages.first;
    } catch (e) {
      print(e.message);
    }
    return messages;
  }
}
