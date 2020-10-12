import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  double _textMessageMaxWidth = 200;
  double _imageMessageHeight = 250;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AutoScrollController _autoScrollController;

  List<Message> _showMessageList = List<Message>();
  bool _isMessagePositionLeft = false;
  CurrentClient currentClint;
  bool isImageMessageSendBySelf = false;

  //翻页位置的第一条消息
  Message _oldMessage = Message();
  //翻页最后一页长度小于 10 特殊处理
  int _lastPageLength = 0;
  bool _isNeedScrollToNewPage = false;

  FlutterPluginRecord recordPlugin;
  Map<String, bool> _checkboxSelectedList = new Map();
  List<String> _selectList;
  Set<String> _selectedReportList = new Set();
  @override
  void initState() {
    super.initState();
    _selectList = [
      '含有辱骂、人生攻击内容',
      '不友善内容'
          '垃圾广告内容',
      '有害内容',
      '违法内容',
      '不实内容',
      '其他',
    ];
    _selectList.forEach((item) {
      //index:_list.indexOf(item)
      _checkboxSelectedList[item] = false;
    });
    _oldMessage = widget.firstMessage;
    if (widget.firstPageMessages != null) {
      _showMessageList = widget.firstPageMessages;
    }

    _autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    //第一次进来滚到底
    if (_showMessageList.length >= 10) {
      _scrollToIndex(10);
    } else {
      _scrollToIndex(_showMessageList.length);
    }

    //监听滚动
    _autoScrollController.addListener(() {
      //通知收起键盘
      mess.emit(MyEvent.ScrollviewDidScroll);
    });

    //监听自己发送了新消息
    mess.on(MyEvent.NewMessage, (message) {
      if (message != null) {
        receiveNewMessage(message);
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
        //用户正在某个对话页面聊天，并在这个对话中收到了消息时，需要将会话标记为已读
        if (conversation.id == widget.conversation.id) {
          conversation.read();
          receiveNewMessage(message);
        }
      }
    };
    mess.on(MyEvent.ImageMessageHeight, (height) {
      _imageMessageHeight = height;
    });
    recordPlugin = new FlutterPluginRecord();
//    初始化
    recordPlugin.init();
    recordPlugin.responsePlayStateController.listen((data) {
      print("播放路径   " + data.playPath);
      print("播放状态   " + data.playState);
    });
  }

  void playAudio(String url) {
    print('play...');
    recordPlugin.playByPath(url, 'url');
  }

  void receiveNewMessage(Message message) {
    if (message is TextMessage) {
      double height = calculateTextHeight(getMessageString(message), 14.0,
              FontWeight.bold, _textMessageMaxWidth - 16, 100) +
          16 +
          30;
      setState(() {
        _showMessageList.add(message);
        _autoScrollController
            .jumpTo(_autoScrollController.position.maxScrollExtent + height);
      });
    }
    if (message is ImageMessage) {
      setState(() {
        _showMessageList.add(message);
        _autoScrollController.animateTo(
            _autoScrollController.position.maxScrollExtent +
                _imageMessageHeight,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease);
      });
    }
    if (message is AudioMessage) {
      double height = 40.0 + 16 + 30;
      setState(() {
        _showMessageList.add(message);
        _autoScrollController
            .jumpTo(_autoScrollController.position.maxScrollExtent + height);
      });
    }
    //收到新消息以后再刷新列表
    mess.emit(MyEvent.ConversationRefresh);
  }

  Future _scrollToIndex(int index) async {
    await _autoScrollController.scrollToIndex(index,
        duration: Duration(milliseconds: 100),
        preferPosition: AutoScrollPosition.end);
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
                                        GestureDetector(
                                            onLongPress: () {
                                              //TODO：禁言
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  right: 8, left: 8),
                                              child: new Text(
                                                fromClientID,
                                                style: new TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            )),
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
      return GestureDetector(
          onLongPress: () {
            showReportDialog(message.id);
          },
          child: Container(
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
              )));
    } else if (message is FileMessage) {
      if (message is ImageMessage) {
        return GestureDetector(
            onLongPress: () {
              showReportDialog(message.id);
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.4,
              ),
              child: CachedNetworkImage(
                imageUrl: message.url,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ));
      } else if (message is AudioMessage) {
        int duration = message.duration.toInt();
        double width = _textMessageMaxWidth * (duration / 20);
        if (duration >= 20) {
          width = _textMessageMaxWidth;
        }
        if (duration <= 3) {
          width = _textMessageMaxWidth * (3 / 20);
        }
        return GestureDetector(
            onLongPress: () {
              showReportDialog(message.id);
            },
            onTap: () {
              if (message.url != null) {
//                mess.emit(MyEvent.PlayAudioMessage, message.url);
//                showToastGreen('消息正在播放');
//                recordPlugin.playByPath(message.url,'url');

                playAudio(message.url);
              } else {
                showToastGreen('消息无法播放');
              }
            },
            child: Container(
                padding: const EdgeInsets.all(8.0),
                width: width,
                constraints: BoxConstraints(
//              maxWidth: width,
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
                  '${duration.toString()}"',
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          _isMessagePositionLeft ? Colors.white : Colors.blue),
                )));
      }
    } else {
      return Text('暂未支持的消息类型。。。');
    }
  }
  Future<bool> showlacklistDialog(String name) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("加入黑名单"),
          content: Text("确认拉黑 $name，不再接受来自 $name 的消息吗"),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("确认"),
              onPressed: () {
                //

                //关闭对话框并返回true
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<bool> showReportDialog(String messageID) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "举报",
            textAlign: TextAlign.center,
          ),
          content:
              new StatefulBuilder(builder: (context, StateSetter setState) {
            return Container(
//            padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 10),
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(
                        bottom: 15,
                      ),
                      child: Text(
                        '请选择举报理由',
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Expanded(
                      child: ListView.separated(
                          //添加分割线
                          separatorBuilder: (BuildContext context, int index) {
                            return new Divider(
                              height: 0.5,
                              color: Colors.grey,
                            );
                          },
                          itemCount: _selectList.length,
//            itemExtent: 50.0, //强制高度为50.0
                          itemBuilder: (BuildContext context, int index) {
                            return CheckboxListTile(
                              onChanged: (isCheck) {
                                setState(() {
                                  _checkboxSelectedList[_selectList[index]] =
                                      isCheck;
                                });
                              },
                              selected: false,
                              value: _checkboxSelectedList[_selectList[index]],
                              title: Text(_selectList[index],
                                  style: new TextStyle(
                                    fontSize: 12,
                                  )),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }))
                ],
              ),
            );
          }),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("确认"),
              onPressed: () {
                saveReports(messageID);
                //关闭对话框并返回true
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
//TODO:禁言
  Future addBlackList(String name)async{

  }
  Future saveReports(String messageID) async {
    _checkboxSelectedList.forEach((key, value) {
      if (value == true) {
        _selectedReportList.add(key);
      }
    });
    if (_selectedReportList.length == 0) {
      showToastRed('请选择举报理由！');
      return;
    }
LCObject report = LCObject('Report');
report['clientID'] = Global.clientID;
report['messageID'] = messageID;
report['conversationID'] = this.widget.conversation.id;
report['content'] = _selectedReportList.toString();
await report.save();
    showToastGreen('提交成功！');
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
    recordPlugin.dispose();
    //取消订阅
    mess.off(MyEvent.NewMessage);
    mess.off(MyEvent.ImageMessageHeight);
//    mess.off(MyEvent.EditingMessage);
  }

  @override
  void deactivate() async {
    print('结束');
//    int result = await audioPlayer.release();
//    if (result == 1) {
//      print('release success');
//    } else {
//      print('release failed');
//    }
    super.deactivate();
    recordPlugin.stopPlay();
    recordPlugin.dispose();
  }
}
