import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';

class MessageList extends StatefulWidget {
  final ScrollController scrollController;
  final Conversation conversation;

  MessageList({Key key, @required this.scrollController, this.conversation})
      : super(key: key);

  @override
  _MessageListState createState() => new _MessageListState();
}

class _MessageListState extends State<MessageList> {

  @override
  Widget build(BuildContext context) {
//    );
//    SingleMesCollection mesCol = cTalkingCol(context);
    return Expanded(
        child: Container(
      color: Color(0xfff5f5f5),
      //    通过NotificationListener实现下拉操作拉取更多消息
//            child: NotificationListener<OverscrollNotification>(

      child: FutureBuilder<List<Message>>(
        future: queryessages(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // 请求已结束
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Message message = snapshot.data[index];
                  String messageId = '消息ID：${message.id}';

                  return Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        new Text(
                          messageId,
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
//                            new Expanded(
//                              child: new Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                children: [
//                                  new Container(
//                                    padding: const EdgeInsets.only(
//                                        bottom: 8.0, right: 8, left: 10),
//                                    child: new Text(
//                                      'name',
//                                      style: new TextStyle(
//                                        fontWeight: FontWeight.bold,
//                                      ),
//                                    ),
//                                  ),
//                                  new Container(
//                                    padding: const EdgeInsets.only(
//                                        bottom: 8.0, right: 8, left: 10),
//                                    child: new Text(
//                                      'phoneNum',
//                                      style: new TextStyle(
//                                        color: Colors.grey[500],
//                                      ),
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ),
                      ],
                    ),
                  );
                },
              );
            }
          } else {
            // 请求未结束，显示loading
            return CircularProgressIndicator();
          }
        },
      ),
      //  注册通知函数
//              onNotification: (OverscrollNotification notification) {
//                if (widget.scrollController.position.pixels <= 10) {
//                  _getMoreMessage();
//                }
//                return true;
//              },
//            )
    ));
  }
  Future<List<Message>> queryessages() async {

    // limit 取值范围 1~100，如调用 queryMessage 时不带 limit 参数，默认获取 20 条消息记录
    List<Message> messages;
    try {
      messages  = await this.widget.conversation.queryMessage(
        limit: 10,
      );
      print(messages.length);

    } catch (e) {
      print(e.message);
    }
    return messages;
  }

}
