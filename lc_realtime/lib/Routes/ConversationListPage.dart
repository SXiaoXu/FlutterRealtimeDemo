import 'package:flutter/material.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';
import 'package:lcrealtime/Routes/ConversationDetailPage.dart';
import '../Common/Global.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';

class ConversationListPage extends StatefulWidget {
  @override
  _ConversationListPageState createState() => new _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {

  @override
  void initState() {
    super.initState();
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
                    con.fetchReceiptTimestamps();

                    print(con.id);

                    String name = con.name;
                    List members = con.members;

                    String time;
                    String lastMessageString = '暂无新消息';

                    if (con.lastMessage == null) {
                      print('-------------------->' + con.updatedAt.toString());
                      time = getFormatDate(con.updatedAt.toString());
                    } else {
                      time = getFormatDate(con.lastMessageDate.toString());
                      lastMessageString = con.lastMessage.fromClientID +
                          ':' +
                          getMessageString(con.lastMessage);
                    }

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
                                      padding: const EdgeInsets.only(
                                          right: 8, left: 10),
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

  void onTapEvent(Conversation con) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new ConversationDetailPage(conversation: con),
      ),
    );
  }

  Future<List<Conversation>> retrieveData() async {
    CurrentClient currentClient  = CurrentClient();
    List<Conversation> conversations;
    try {
      ConversationQuery query = currentClient.client.conversationQuery();
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
