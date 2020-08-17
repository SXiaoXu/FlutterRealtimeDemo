import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';
import 'package:lcrealtime/Widgets/ImageWidget.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MessageList extends StatefulWidget {
  final Conversation conversation;
  final List<Message> firstPageMessages;
  final Message firstMessage;

  MessageList(
      {Key key,
      @required this.conversation,
      this.firstPageMessages,
      this.firstMessage})
      : super(key: key);

  @override
  _MessageListState createState() => new _MessageListState();
}

class _MessageListState extends State<MessageList> {
  double _textMessageMaxWidth;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AutoScrollController _autoScrollController;

  List<Message> _showMessageList;
  bool _isMessagePositionLeft = false;
  CurrentClient currentClint;
  final double newImageMessageHeight = 100;

  //翻页位置的第一条消息
  Message _oldMessage;
  //翻页最后一页长度小于 10 特殊处理
  int _lastPageLength = 0;
  bool _isNeedScrollToNewPage = false;

  @override
  void initState() {
    super.initState();
    _oldMessage = widget.firstMessage;
    _showMessageList = widget.firstPageMessages;

    _autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    //第一次进来滚到底
    if (_showMessageList.length >= 10) {
      _scrollToIndex(10);
    }
    //监听滚动
    _autoScrollController.addListener(() {
      //通知收起键盘
      mess.emit(MyEvent.ScrollviewDidScroll);
    });

    //监听自己发送了新消息
    mess.on(MyEvent.NewMessage, (arg) {
      if (arg != null) {
        receiveNewMessage(arg);
      }
    });

    //收到新消息
    currentClint = CurrentClient();
    currentClint.client.onMessage = ({
      Client client,
      Conversation conversation,
      Message message,
    }) {
      if (message != null) {
        receiveNewMessage(message);
      }
    };
    //监听正在编辑消息
//    mess.on(MyEvent.EditingMessage, (arg) {
//      _autoScrollController
//          .jumpTo(_autoScrollController.position.maxScrollExtent);
//    });
  }

  void receiveNewMessage(Message message) {
    double height;
//    mess.on(MyEvent.ImageMessageHeight, (arg) {
////      height = arg;
//    });
    if (message is TextMessage) {
      height = calculateTextHeight(getMessageString(message), 14.0,
              FontWeight.bold, _textMessageMaxWidth - 16, 100) +
          16 +
          30;
    }
    if (message is ImageMessage) {
      height = newImageMessageHeight + 40;
    }
    setState(() {
      _showMessageList.add(message);
      _scrollToIndex(_showMessageList.length);
//      _autoScrollController
//          .jumpTo(_autoScrollController.position.maxScrollExtent );
    });
  }

  Future _scrollToIndex(int index) async {
    await _autoScrollController.scrollToIndex(index,
        duration: Duration(milliseconds: 100),
        preferPosition: AutoScrollPosition.begin);
  }

  void _onRefresh() async {
    _isNeedScrollToNewPage = true;

    if (_showMessageList.length == 0) {
      _refreshController.refreshCompleted();
      _isNeedScrollToNewPage = false;
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
        _isNeedScrollToNewPage = false;
        return;
      } else if (messages2.length < 10) {
        _lastPageLength = messages2.length;
      }
      _oldMessage = messages2.first;
      _showMessageList.insertAll(0, messages2);
    } catch (e) {
      print(e);
    }
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
            //点击页面通知收起键盘
            onTap: () => mess.emit(MyEvent.ScrollviewDidScroll),
            onDoubleTap: () => mess.emit(MyEvent.ScrollviewDidScroll),
            child: Container(
                child: SmartRefresher(
                    enablePullDown: true,
                    header: CustomHeader(
//                      completeDuration: Duration(milliseconds: 200),
                      builder: (context, mode) {
                        Widget body;
                        if (mode == RefreshStatus.idle) {
                          body = Text("pull down refresh");
                        } else if (mode == RefreshStatus.refreshing) {
                          body = CupertinoActivityIndicator();
                        } else if (mode == RefreshStatus.canRefresh) {
//                              body = Text("release to refresh");
                          body = CupertinoActivityIndicator();
                        } else if (mode == RefreshStatus.completed) {
//                              body = Text("refreshCompleted!");
                          if (_isNeedScrollToNewPage) {
                            _lastPageLength != 0
                                ? _scrollToIndex(_lastPageLength)
                                : _scrollToIndex(10);
                          }
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
                      //根据子组件的总长度来设置ListView的长度
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _autoScrollController,
                      itemCount: _showMessageList.length,
                      itemBuilder: (context, index) {
                        _textMessageMaxWidth =
                            MediaQuery.of(context).size.width * 0.7;
                        Message message = _showMessageList[index];

                        String fromClientID = message.fromClientID;
                        // string time = message.sentDate;//
                        _isMessagePositionLeft = false;
                        if (fromClientID != currentClint.client.id) {
                          _isMessagePositionLeft = true;
                        }
                        return AutoScrollTag(
                            key: ValueKey(index),
                            controller: _autoScrollController,
                            index: index,
                            child: Container(
//                    color: Color(0xfff5f5f5),
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: new Column(
                                      crossAxisAlignment: _isMessagePositionLeft
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
                                                _isMessagePositionLeft
                                                    ? MainAxisAlignment.start
                                                    : MainAxisAlignment.end,
                                            children: <Widget>[
                                              typeMessageView(message),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      },
                    )))));
  }

  //展示不同的消息类型
  Widget typeMessageView(Message message) {
    if (message is TextMessage) {
      return Container(
          padding: const EdgeInsets.all(8.0),
          constraints: BoxConstraints(
            maxWidth: _textMessageMaxWidth,
          ),
          decoration: _isMessagePositionLeft
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
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                color: _isMessagePositionLeft ? Colors.white : Colors.blue),
          ));
    } else if (message is FileMessage) {
      if (message is ImageMessage) {
        return Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.4,
            ),
            child: ImageWidget(
                url: message.url,
                width: MediaQuery.of(context).size.width * 0.4));
      } else if (message is AudioMessage) {}
    } else {
      return Text('暂未支持的消息类型。。。');
    }
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

  ///value: 文本内容；fontSize : 文字的大小；fontWeight：文字权重；maxWidth：文本框的最大宽度；maxLines：文本支持最大多少行
  static double calculateTextHeight(String value, fontSize,
      FontWeight fontWeight, double maxWidth, int maxLines) {
    TextPainter painter = TextPainter(
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            )));
    painter.layout(maxWidth: maxWidth);

    ///文字的宽度:painter.width
    return painter.height;
  }

  @override
  void dispose() {
    super.dispose();

    //取消订阅
    mess.off(MyEvent.NewMessage);
    mess.off(MyEvent.ImageMessageHeight);

//    mess.off(MyEvent.EditingMessage);
  }
}
