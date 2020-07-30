import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/ConversationModel.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/ChangeNotifierProvider.dart';

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
  void initState() {
    super.initState();
    mess.on(MyEvent.NewMessage, (arg) {
      if(mounted){
        setState(() {});
        print('监听到新的消息。。');
      }
    });

//
    Client client = Client(id: Global.clientID);
    client.onMessage = ({
      Client client,
      Conversation conversation,
      Message message,
    }) {
      if (message != null) {
        print('收到的消息是：${getMessageString(message)}');
        setState(() {});
      }
    };
  }

//  _getMoreMessage() async {
//    if (!isLoading) {
//      if (acculateReqLength == 0) {
//        return;
//      }
//      setState(() {
//        isLoading = true;
//      });
//      SingleMesCollection collection = cTalkingCol(context);
//      var res = await Network.get('getMoreMessage', {
//        'currentLength': collection.message.length,
//        'toFriend': cSayto(context),
//        'userName': cUser(context),
//        'length': acculateReqLength
//      });
//      List<SingleMessage> addList = res.data['message'].map<SingleMessage>((item) {
//        return SingleMessage.fromJson(item);
//      }).toList();
//      collection.message.insertAll(0, addList);
//      setState(() {
//        isLoading = false;
//      });
//    }
//  }

  @override
  Widget build(BuildContext context) {
//    );
//    SingleMesCollection mesCol = cTalkingCol(context);
    return Expanded(
      child: Container(
//      child: NotificationListener<OverscrollNotification>(

//      color: Color(0xfff5f5f5),
        //    通过NotificationListener实现下拉操作拉取更多消息
//            child: NotificationListener<OverscrollNotification>(

//            child: ChangeNotifierProvider<ConversationModel>(
//      data: ConversationModel(),
        child: FutureBuilder<List<Message>>(
          future: queryessages(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // 请求已结束
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.data.length == 0) {
                return Text("暂无聊天记录");
              } else {
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: widget.scrollController,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Message message = snapshot.data[index];
                    String fromClientID = message.fromClientID;
                    // string time = message.sentDate;//
//                  var conNew = ChangeNotifierProvider.of<ConversationModel>(context);
                    return Container(
//                    color: Color(0xfff5f5f5),
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Column(
                              crossAxisAlignment: index % 2 == 0
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                new Container(
                                  padding:
                                      const EdgeInsets.only(right: 8, left: 8),
                                  child: new Text(
                                    fromClientID,
                                    style: new TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    mainAxisAlignment: index % 2 == 0
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                          padding: const EdgeInsets.all(8.0),
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                          ),
                                          decoration: index % 2 == 0
                                              ? BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(12.0),
                                                  ),
                                                )
                                              : BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(12.0),
                                                  ),
                                                ),
                                          child: new Text(
                                            getMessageString(message),
//                                          'Run `aqueduct serve` from this directory to run the application',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: index % 2 == 0
                                                    ? Colors.white
                                                    : Colors.blue),
                                          ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
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
//          onNotification: (OverscrollNotification notification) {
//            if (widget.scrollController.position.pixels <= 10) {
////            _getMoreMessage();
//            }
//            return true;
//          }
      ),

      //  注册通知函数
//              onNotification: (OverscrollNotification notification) {
//                if (widget.scrollController.position.pixels <= 10) {
//                  _getMoreMessage();
//                }
//                return true;
//              },
//            )
    );
  }

  Future<List<Message>> queryessages() async {
    List<Message> messages;
    try {
      messages = await this.widget.conversation.queryMessage(
            limit: 100,
          );
      print(messages.length);
    } catch (e) {
      print(e.message);
    }
    return messages;
  }

//  时间显示规则：
//      当天的消息，以每 5 分钟为一个跨度显示时间
//      消息超过 1 天、小于 1 周，显示为「星期 消息发送时间」
//      消息大于 1 周，显示「日期 消息发送时间」

//  calculateTimeVisibility(List<Message> list) {
//    if (list.isEmpty) {
//      return;
//    }
//    DateTime lastVisiableTime = list.last.sendTime;
//    list.last.timeVisility = true;
//
//    //倒序遍历
//    for (int i = list.length - 1; i >= 0; i--) {
//      Message message = list[i];
////    print(
////        "message.sendTime.difference(DateTime.now()).inDays:${message.sendTime.difference(DateTime.now()).inDays}");
//
//      int diffDays = lastVisiableTime.difference(message.sendTime).inDays;
//      if (diffDays == 0) {
//        //同一天
//        if (lastVisiableTime.difference(message.sendTime).inMinutes < 5) {
//          //间隔小于上一次5分钟
//          message.timeVisility = false;
//        } else {
//          //间隔大于上一次5分钟
//          lastVisiableTime = message.sendTime;
//          message.timeVisility = true;
//        }
//      } else if (diffDays < 7) {
//        //超过1天、小于1周
//        message.timeVisility = true;
//        lastVisiableTime = message.sendTime;
//      } else {
//        //消息大于1周
//        message.timeVisility = true;
//        lastVisiableTime = message.sendTime;
//      }
//    }
//  }
  @override
  void dispose() {
    super.dispose();

    //取消订阅
    mess.off(
      MyEvent.NewMessage,
    );
  }
}
