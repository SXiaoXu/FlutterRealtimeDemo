import 'package:flutter/material.dart';
//TODO 联系人列表-点击某个联系人就跳转到单独的聊天页面

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => new _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
//        padding: EdgeInsets.all(2.0),
        child: FutureBuilder<Map<String, dynamic>>(
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
//                    var data = snapshot.data[index];
//                    int type = data['type'];
//                    String name;
//                    String username = data['username'];
//                    String realName = data['realName'];
//                    if (realName == null || realName == '') {
//                      name = username;
//                    } else {
//                      name = realName;
//                    }
//                    var duration = data['duration'];
//                    String note;
//                    if (data['note'] == null || data['note'] == '') {
//                      note = getEmojiString();
//                    } else {
//                      note = data['note'];
//                    }
//                    DateTime startDate = data['startDate'];
//                    String startDateString =
//                    formatDate(startDate, [mm, "-", dd, " "]);
//                    DateTime endDate = data['endDate'];
//                    String endDateString =
//                    formatDate(endDate, [mm, "-", dd, " "]);
//                    String startTime = data['startTime'];
//                    String endTime = data['endTime'];
//
//                    String leaveMessageString =
//                        '$startDateString$startTime - $endDateString$endTime';
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
                                    '1111111111111111',
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                new Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, right: 8, left: 10),
                                  child: new Text(
                                    'note',
                                    style: new TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                                new Container(
                                  padding:
                                      const EdgeInsets.only(right: 8, left: 10),
                                  child: new Text(
                                    'leaveMessageString',
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
                                      bottom: 8.0, right: 15),
                                  child: new Text(
                                    '天',
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
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

  Future<Map<String, dynamic>> retrieveData() async {
    List list = ['123', '2323', 'wewe'];
    Map<String, dynamic> stringMap = {
      'year': 1780,
      'first': 'partridge',
      'second': 'turtledoves',
      'fifth': 'golden rings'
    };
    return stringMap;
  }
}
