import 'package:flutter/material.dart';
import '../Common/Global.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';

class ConversationListPage extends StatefulWidget {
  @override
  _ConversationListPageState createState() => new _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  Client _client;
  String _clientID;

  @override
  void initState() {
    super.initState();
    if (Global.clientID != null) {
      _client = Client(id: Global.clientID);
      setState(() {});
    } else {
      showToastRed('用户未登录');
    }
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
//                    print(con.id);
                    String name = con.name;
                    List members = con.members;
                    String lastMessage;
                    String time;
                    String lastMessageFrom = '';
                    String lastMessageString = '暂无新消息';

                    if (con.lastMessage == null) {
                      time = getFormatDate(con.updatedAt.toString());
                    } else {
                      Message message = con.lastMessage;
                      if (message.binaryContent != null) {
                        print('收到二进制消息：${message.binaryContent.toString()}');
                        lastMessage = '收到二进制消息';
                      } else if (message is TextMessage) {
                        print('收到文本类型消息：${message.text}');
                        lastMessage = message.text;
                      } else if (message is LocationMessage) {
                        print(
                            '收到地理位置消息，坐标：${message.latitude},${message.longitude}');
                        lastMessage = '地理位置消息';
                      } else if (message is FileMessage) {
                        if (message is ImageMessage) {
                          print('收到图像消息，图像 URL：${message.url}');
                          lastMessage = '收到图像消息';
                        } else if (message is AudioMessage) {
                          print('收到音频消息，消息时长：${message.duration}');
                          lastMessage = '收到音频消息';
                        } else if (message is VideoMessage) {
                          print('收到视频消息，消息时长：${message.duration}');
                          lastMessage = '收到视频消息';
                        } else {
                          print(
                              '收到.txt/.doc/.md 等各种类型的普通文件消息，URL：${message.url}');
                          lastMessage = '收到文件消息';
                        }
                      }
//                      else if (message is CustomMessage) {
//                        // CustomMessage 是自定义的消息类型
//                        print('收到自定义类型消息');
//                      }
                      else {
                        // 这里可以继续添加自定义类型的判断条件
                        print('收到未知消息类型');
                        lastMessage = '未知消息类型';
//                        if (message.stringContent != null) {
//                          print('收到普通消息：${message.stringContent}');
//                          lastMessage = message.stringContent;
//                        }
                      }

                      time = getFormatDate(con.lastMessageDate.toString());
                      lastMessageFrom = con.lastMessage.fromClientID;
                      lastMessageString = '$lastMessageFrom：$lastMessage';
                    }
                    return Container(
                      padding: const EdgeInsets.all(10),
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
                                  child: new Text(
                                    name,
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                new Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, right: 8, left: 10),
                                  child: new Text(
                                    members.toString(),
                                    style: new TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                                new Container(
                                  padding:
                                      const EdgeInsets.only(right: 8, left: 10),
                                  child: new Text(
                                    lastMessageString,
                                    style: new TextStyle(
                                      color: Colors.black54,
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
      ),
    );
  }

  Future<List<Conversation>> retrieveData() async {
    List<Conversation> conversations;
    try {
      ConversationQuery query = _client.conversationQuery();
      query.orderByDescending('updatedAt');
      //让查询结果附带一条最新消息
      query.includeLastMessage = true;
      conversations = await query.find();
    } catch (e) {
      print(e);
      showToastRed(e.message);
    }
    return conversations;
  }
}
