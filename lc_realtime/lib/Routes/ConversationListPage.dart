import 'package:flutter/material.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';
import 'package:lcrealtime/Routes/ConversationDetailPage.dart';
import 'package:lcrealtime/Widgets/TextWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/Global.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';

class ConversationListPage extends StatefulWidget {
  @override
  _ConversationListPageState createState() => new _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  CurrentClient currentClint;

  Map<String, int> unreadCountMap = Map();
  Map<String, int> conversationIDToIndexMap = Map();

  @override
  void initState() {
    super.initState();
    currentClint = CurrentClient();

    //收到新消息
    currentClint.client.onMessage = ({
      Client client,
      Conversation conversation,
      Message message,
    }) {
      if (message != null) {
        receiveNewMessage(message);
        print('收到信息---');
      }
    };
    //
    mess.on(MyEvent.ConversationRefresh, (arg) {
      setState(() {});
    });
    //未读数更新通知
    currentClint.client.onUnreadMessageCountUpdated = ({
      Client client,
      Conversation conversation,
    }) {
      print('onUnreadMessageCountUpdated-----:' +
          conversation.unreadMessageCount.toString());
//      final prefs = await SharedPreferences.getInstance();
      if (conversation.unreadMessageCount != null) {
//        prefs.setInt(conversation.id, conversation.unreadMessageCount);
        unreadCountMap[conversation.id] = conversation.unreadMessageCount;
      } else {
//        prefs.setInt(conversation.id, 0);
        unreadCountMap[conversation.id] = 0;
      }
      setState(() {});
      //TODO 局部刷新
//      int count = unreadCountMap[conversation.id];
//      int index = conversationIDToIndexMap[conversation.id];
//      print(index.toString()+'index--');
//      if (count != null && index != null) {
//        _keyList[index].currentState.onPressed(count);
//      }
    };
  }

  void receiveNewMessage(Message message) {
    //收到新消息刷新页面
//    setState(() {});
  }
//  Future<int> getUnReadMessageCount(String conversationId) async {
//    final prefs = await SharedPreferences.getInstance();
//    int counter = prefs.getInt(conversationId) ?? 0;
//    print('counter:-----:' + counter.toString());
//    return counter;
//  }
//根据ID获取index
  @override
  void dispose() {
    super.dispose();
    //取消订阅
    mess.off(MyEvent.ConversationRefresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
//        padding: EdgeInsets.all(2.0),
        child: FutureBuilder<List<Conversation>>(
          future: retrieveData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // 请求已结束
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return ListView.separated(
                  //添加分割线
                  separatorBuilder: (BuildContext context, int index) {
                    return new Divider(
                      height: 0.8,
                      color: Colors.grey,
                    );
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Conversation con = snapshot.data[index];
                    String name = con.name;
                    List members = con.members;
                    String time;
                    String lastMessageString = '暂无新消息';
                    if (con.lastMessage == null) {
                      time = getFormatDate(con.updatedAt.toString());
                    } else {
                      time = getFormatDate(con.lastMessageDate.toString());
                      lastMessageString = con.lastMessage.fromClientID +
                          ':' +
                          getMessageString(con.lastMessage);
                    }
                    int unreadCount = 0;
                    if (unreadCountMap[con.id] != null) {
                      unreadCount = unreadCountMap[con.id];
                    }
//                    conversationIDToIndexMap[con.id] = index;
                    print('unreadCount:-----:' + unreadCount.toString());

                    return GestureDetector(
                        onTap: () {
                          Conversation con = snapshot.data[index];
                          onTapEvent(con);
                        }, //点击
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          color: Colors.white,
                          child: Row(
                            children: <Widget>[
                              new Expanded(
                                flex: 2,
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, right: 8, left: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            padding: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            child: Text(
                                              name,
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          buildUnReadCountView(unreadCount),
                                        ],
                                      ),
                                    ),
                                    new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, right: 8, left: 10),
                                      child: new Text(
                                        members.toString(),
                                        style: new TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    new Container(
                                      padding: const EdgeInsets.only(
                                          right: 8, left: 10),
                                      child: new Text(
                                        lastMessageString,
                                        style: new TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              new Expanded(
                                flex: 1,
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 0, right: 0),
                                      child: new Text(
                                        time,
                                        style: new TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                );
              }
            } else {
              // 请求未结束，显示loading
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget buildUnReadCountView(int count) {
    if (count > 0) {
      String showNum = '';
      if (count < 10) {
        showNum = ''' ''' + count.toString() + ''' ''';
      } else {
        showNum = count.toString();
      }
      return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red, Colors.red]),
            borderRadius: BorderRadius.circular(16.0), //圆角
          ),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
//              child: TextWidget(_keyList[index])));
              child: Text(
                showNum,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              )));
    } else {
      return Container(
        height: 0,
      );
    }
  }

  void onTapEvent(Conversation con) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new ConversationDetailPage(conversation: con),
      ),
    );
  }

  Future<List<Conversation>> retrieveData() async {
    CurrentClient currentClient = CurrentClient();
    List<Conversation> conversations;
    try {
      ConversationQuery query = currentClient.client.conversationQuery();
      //TODO：上拉加载更多
      query.limit = 20;
      query.orderByDescending('updatedAt');
      //让查询结果附带一条最新消息
      query.includeLastMessage = true;
      conversations = await query.find();

      //记录未读消息数
      final prefs = await SharedPreferences.getInstance();
      conversations.forEach((item) {
        if (item.unreadMessageCount != null) {
//        prefs.setInt(conversation.id, conversation.unreadMessageCount);
          unreadCountMap[item.id] = item.unreadMessageCount;
        } else {
//        prefs.setInt(conversation.id, 0);
          unreadCountMap[item.id] = 0;
        }

//        //之前没有值，存储一份
//        if (prefs.getInt(item.id) == null) {
//          if (item.unreadMessageCount != null) {
//            prefs.setInt(item.id, item.unreadMessageCount);
//            unreadCountMap[item.id] = item.unreadMessageCount;
//          } else {
//            prefs.setInt(item.id, 0);
//            unreadCountMap[item.id] = 0;
//          }
//        } else {
//          unreadCountMap[item.id] = prefs.getInt(item.id);
//        }
      });
    } catch (e) {
      print(e);
      showToastRed(e.message);
    }
    return conversations;
  }
}
