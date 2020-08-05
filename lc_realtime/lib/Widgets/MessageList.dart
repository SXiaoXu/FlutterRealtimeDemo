import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/ConversationModel.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/ChangeNotifierProvider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessageList extends StatefulWidget {
  final ScrollController scrollController;
  final Conversation conversation;
  final List<Message> firstPageMessages;
  final Message firstMessage;

  MessageList(
      {Key key,
      @required this.scrollController,
      this.conversation,
      this.firstPageMessages,
      this.firstMessage})
      : super(key: key);

  @override
  _MessageListState createState() => new _MessageListState();
}

class _MessageListState extends State<MessageList> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  //用于翻页
  Message _oldMessage;
  List<Message> _showMessageList;

  @override
  void initState() {
    super.initState();
    _oldMessage =widget.firstMessage;
    _showMessageList = widget.firstPageMessages;

    //第一次进来滚到底
    Timer(
        Duration(milliseconds: 100),
        () => widget.scrollController
            .jumpTo(widget.scrollController.position.maxScrollExtent));

    mess.on(MyEvent.NewMessage, (arg) {
      if (mounted) {
        print('我发送了新消息' + getMessageString(arg));
        setState(() {
          _showMessageList.add(arg);
          widget.scrollController
              .jumpTo(widget.scrollController.position.maxScrollExtent + 50);
        });
      }
    });

    Client client = Client(id: Global.clientID);
    client.onMessage = ({
      Client client,
      Conversation conversation,
      Message message,
    }) {
      if (message != null) {
        print('收到的消息是：${getMessageString(message)}');
        setState(() {
          _showMessageList.add(message);
          widget.scrollController
              .jumpTo(widget.scrollController.position.maxScrollExtent + 50);
        });
      }
    };
  }

  void _onRefresh() async {
    //每次查询 10 条消息
    try {
      // 以上一页的最早的消息作为开始，继续向前拉取消息
      List<Message> messages2 = await this.widget.conversation.queryMessage(
            startTimestamp: _oldMessage.sentTimestamp,
            startMessageID: _oldMessage.id,
            startClosed: false,
            limit: 10,
          );
      _oldMessage = messages2.first;
      _showMessageList.insertAll(0, messages2);
      setState(() {});
    } catch (e) {
      print(e);
    }
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      child: SmartRefresher(
          enablePullDown: true,
          header: ClassicHeader(),
          onRefresh: _onRefresh,
          controller: _refreshController,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: widget.scrollController,
            itemCount: _showMessageList.length,
            itemBuilder: (context, index) {
              if (_showMessageList.length == 0) {
                return Text("暂无聊天记录");
              }
              Message message = _showMessageList[index];
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
                            padding: const EdgeInsets.only(right: 8, left: 8),
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
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.7,
                                    ),
                                    decoration: index % 2 == 0
                                        ? BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(12.0),
                                            ),
                                          )
                                        : BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.all(
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
//                } else {
//                  // 请求未结束，显示loading
////                  return CircularProgressIndicator();
//                  return Text("暂无聊天记录");
//                }
            },
          )
//                  }
//                } else {
//                  // 请求未结束，显示loading
//                  return CircularProgressIndicator();
//                }
//              },
//            ),
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
//
    ));
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
