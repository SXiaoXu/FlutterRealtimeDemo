import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/ConversationModel.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/ChangeNotifierProvider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';

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
//  ItemScrollController _scrollController = ItemScrollController();


  List<Message> _showMessageList;
  bool _isMessagePositionLest = false;
  CurrentClient currentClint;

  //翻页位置的第一条消息
  Message _oldMessage;
  //当前页的最大可滚动范围
  double _maxScrollExtent;
  //用于记录每一页消息的高度
  Map<int, double> _heightMap = new Map();
  //用于记录当前页数
  int _currentPages = 0;
  double _lastpagePosition;

  @override
  void initState() {
    super.initState();
    _oldMessage = widget.firstMessage;
    _showMessageList = widget.firstPageMessages;

    //第一次进来滚到底
    Timer(Duration(milliseconds: 100), () {
      widget.scrollController
          .jumpTo(widget.scrollController.position.maxScrollExtent);
//      _maxScrollExtent = widget.scrollController.position.maxScrollExtent;
      print('init------------->--' + _maxScrollExtent.toString());
//          _heightMap[_currentPages] = _maxScrollExtent;

      //第0页的高度；
//          _maxScrollExtent  = widget.scrollController.position.pixels;
//          _heightMap[_currentPages] = _maxScrollExtent;

//              _list.forEach((item) {
//                //index:_list.indexOf(item)
//                _checkboxSelectedList[item] = false;
//              });
//          _checkboxSelectedList.forEach((key, value) {
//            if (value == true) {
//              _selectedClientList.add(key);
//            }
//          });
    });

    mess.on(MyEvent.NewMessage, (arg) {
      if (mounted) {
        print('我发送了新消息' + getMessageString(arg));
        setState(() {
          _showMessageList.add(arg);
          widget.scrollController
              .jumpTo(widget.scrollController.position.maxScrollExtent+ 60);
        });
      }
    });

    currentClint = CurrentClient();
    currentClint.client.onMessage = ({
      Client client,
      Conversation conversation,
      Message message,
    }) {
      if (message != null) {
        print('收到的消息是：${getMessageString(message)}');
        setState(() {
          _showMessageList.add(message);
          widget.scrollController
              .jumpTo(widget.scrollController.position.maxScrollExtent + 60 );
        });
      }
    };

//    监听滚动事件
//    metrics.extentAfter - widget 底部距离列表底部有多大
//    metrics.extentBefore - widget 顶部距离列表顶部有多大
//    metrics.extentInside - widget 范围内的列表长度
//    metrics.maxScrollExtent - 最大滚动距离，列表长度 - widget 长度
//    metrics.minScrollExtent - 最小滚动距离
//    metrics.viewportDimension - widget 长度

    //extentAfter + extentBefore 的确= maxScrollExtent
    widget.scrollController.addListener(() {
//      _maxScrollExtent = widget.scrollController.position.maxScrollExtent;
//      print('-----addListener:' +
//          widget.scrollController.position.pixels.toString()); //打印滚动位置
////      _maxScrollExtent = widget.scrollController.position.maxScrollExtent;
//      print('-----_maxScrollExtent:' + _maxScrollExtent.toString()); //打印滚动位置
////     double  viewportDimension = widget.scrollController.position.viewportDimension;
////      print('-----viewportDimension:'+ viewportDimension.toString()); //widget 长度
//double extentAfter =widget.scrollController.position.extentAfter;
//      double extentBefore =widget.scrollController.position.extentBefore;
//      print('-----extentAfter:'+ extentAfter.toString() +'-----extentBefore:'+ extentBefore.toString()); //打印滚动位置
//      double extentInside =widget.scrollController.position.extentInside;
//      print('-----extentInside:'+ extentInside.toString()); //打印滚动位置
    });
  }


  void _onRefresh() async {
    _lastpagePosition = _heightMap[_currentPages];

//    print('_lastpagePosition----》' + _lastpagePosition.toString());
    print('_onRefresh-----_maxScrollExtent-------->--' +
        _maxScrollExtent.toString());

    if (_showMessageList.length == 0) {
      _refreshController.refreshCompleted();
      return;
    }
    //每次查询 10 条消息
    try {
      // 以上一页的最早的消息作为开始，继续向前拉取消息
      List<Message> messages2 = await this.widget.conversation.queryMessage(
            startTimestamp: _oldMessage.sentTimestamp,
            startMessageID: _oldMessage.id,
            startClosed: false,
            limit: 10,
          );
      if (messages2.length == 0) {
        _refreshController.refreshCompleted();
        return;
      }
      _oldMessage = messages2.first;
      _showMessageList.insertAll(0, messages2);
    } catch (e) {
      print(e);
    }
    if(mounted)
      setState(() {
      });
    _refreshController.refreshCompleted();
//    _currentPages++;
//    _heightMap[_currentPages] = _maxScrollExtent;

  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
        onNotification: (ScrollNotification notification) {
          print("pixels:${notification.metrics.pixels}");
          print("atEdge:${notification.metrics.atEdge}");
          print("axis:${notification.metrics.axis}");
          print("axisDirection:${notification.metrics.axisDirection}");
          print("extentAfter:${notification.metrics.extentAfter}");
          print("extentBefore:${notification.metrics.extentBefore}");
          print("extentInside:${notification.metrics.extentInside}");
          print("maxScrollExtent:${notification.metrics.maxScrollExtent}");
          _maxScrollExtent = notification.metrics.maxScrollExtent;
          print("minScrollExtent:${notification.metrics.minScrollExtent}");
          print("viewportDimension:${notification.metrics.viewportDimension}");
          print("outOfRange:${notification.metrics.outOfRange}");
          print("____________________________________________");
          return true;
        },
        child: Expanded(
            child: Container(
                child: SmartRefresher(
                    enablePullDown: true,
                    header: CustomHeader(
//                      completeDuration: Duration(milliseconds: 200),
                          builder: (context,mode){
                            Widget body;
                            if(mode==RefreshStatus.idle){
                              body = Text("pull down refresh");
                            }
                            else if(mode==RefreshStatus.refreshing){
                              body = CupertinoActivityIndicator();
                            }
                            else if(mode==RefreshStatus.canRefresh){
//                              body = Text("release to refresh");
                              body = CupertinoActivityIndicator();

                            }
                            else if(mode==RefreshStatus.completed){
//                              body = Text("refreshCompleted!");
//                              widget.scrollController.animateTo(680,
//                                  duration: Duration(milliseconds: 500),
//                                  curve: Curves.ease
//                              );
                              widget.scrollController.jumpTo(680,
                              );
                            }
                            return Container(
                              height: 60.0,
                              child: Center(
                                child: body,
                              ),
                            );
                          },

                    ),
                    onRefresh: _onRefresh,
                    controller: _refreshController,
                    child: ListView.builder(
                      shrinkWrap: true,

//                  addAutomaticKeepAlives: false,
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: widget.scrollController,
                      itemCount: _showMessageList.length,
                      itemBuilder: (context, index) {

//                    if (_showMessageList.length == 0) {
//                      return Text('还没有消息');
//                    } else {
                        Message message = _showMessageList[index];
                        String fromClientID = message.fromClientID;
                        // string time = message.sentDate;//
//                  var conNew = ChangeNotifierProvider.of<ConversationModel>(context);
                        _isMessagePositionLest = false;

                        if (fromClientID != currentClint.client.id) {
                          _isMessagePositionLest = true;
                        }
                        return Container(
//                    color: Color(0xfff5f5f5),
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            children: <Widget>[
                              new Expanded(
                                child: new Column(
                                  crossAxisAlignment: _isMessagePositionLest
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                                  children: [
                                    new Container(
                                      padding: const EdgeInsets.only(
                                          right: 8, left: 8),
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
                                        mainAxisAlignment:
                                            _isMessagePositionLest
                                                ? MainAxisAlignment.start
                                                : MainAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                              ),
                                              decoration: _isMessagePositionLest
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
                                                    color:
                                                        _isMessagePositionLest
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
                    )))));
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
//    widget.scrollController.dispose();

    //取消订阅
    mess.off(
      MyEvent.NewMessage,
    );
  }
}
