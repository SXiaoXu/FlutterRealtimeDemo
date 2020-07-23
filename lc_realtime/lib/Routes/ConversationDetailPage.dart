import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/Widgets/MessageList.dart';
import 'package:lcrealtime/Widgets/InputMessageView.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';

class ConversationDetailPage extends StatefulWidget {
  final Conversation conversation;

  ConversationDetailPage({Key key, @required this.conversation}) : super(key: key);
  @override
  _ConversationDetailPageState createState() =>
      new _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  ScrollController _scrollController =
      ScrollController(initialScrollOffset: 18000);

  @override
  Widget build(BuildContext context) {
//    UserModle myInfo = Provider.of<UserModle>(context);
//    String sayTo = myInfo.sayTo;
//    cUsermodal(context).toastContext = context;
//    //  更新桌面icon
//    updateBadger(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('name'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: toFriendInfo,
            )
          ],
        ),
        body: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 20),

          child: Column(
            children: <Widget>[
              MessageList(scrollController: _scrollController,conversation: this.widget.conversation),
              InputMessageView(scrollController: _scrollController)
            ],
          ),
        ));
  }

  //    点击跳转好友详情页
  void toFriendInfo() {
    Navigator.pushNamed(context, 'friendInfo');
  }

  void slideToEnd() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 40);
  }
}
