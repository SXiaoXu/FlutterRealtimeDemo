import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
//TODO 联系人列表-点击某个联系人就跳转到单独的聊天页面

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => new _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<String> _list = allClients();
  @override
  void initState() {
    super.initState();
    removeCurrentClient();
  }

  removeCurrentClient() {
    _list.remove(Global.clientID);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(title: Text("ClientID：")),
      Expanded(
        child: ListView.builder(
            itemCount: _list.length,
            itemExtent: 50.0, //强制高度为50.0
            itemBuilder: (BuildContext context, int index) {
              return ListTile(title: Text(_list[index]));
            }),
      ),
    ]);
  }

  Future<Map<String, dynamic>> retrieveData() async {
    Map<String, dynamic> stringMap = {
      'year': 1780,
      'first': 'partridge',
      'second': 'turtledoves',
      'fifth': 'golden rings'
    };
    return stringMap;
  }
}
