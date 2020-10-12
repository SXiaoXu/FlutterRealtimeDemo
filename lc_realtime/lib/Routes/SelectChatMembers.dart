import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'ConversationDetailPage.dart';

class SelectChatMembers extends StatefulWidget {
  @override
  _SelectChatMembersState createState() => new _SelectChatMembersState();
}

class _SelectChatMembersState extends State<SelectChatMembers> {
  List<String> _list = allClients();
  Map<String, bool> _checkboxSelectedList = new Map();
  Set<String> _selectedClientList = new Set();

  @override
  void initState() {
    super.initState();
    removeCurrentClient();
  }
  removeCurrentClient() {
    _list.remove(Global.clientID);
    _list.forEach((item) {
      //index:_list.indexOf(item)
      _checkboxSelectedList[item] = false;
    });
//    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            //导航栏
            title: Text("选择联系人"),
            centerTitle: true,
            //导航栏右侧菜单
            actions: <Widget>[
              navRightButton(context),
            ]),
        body: Container(
            child: Column(children: <Widget>[
          Expanded(
            child: ListView.separated(
                //添加分割线
                separatorBuilder: (BuildContext context, int index) {
                  return new Divider(
                    height: 0.8,
                    color: Colors.grey,
                  );
                },
                itemCount: _list.length,
//            itemExtent: 50.0, //强制高度为50.0
                itemBuilder: (BuildContext context, int index) {
                  return CheckboxListTile(
                    onChanged: (isCheck) {
                      setState(() {
                        _checkboxSelectedList[_list[index]] = isCheck;
                      });
                    },
                    selected: false,
                    value: _checkboxSelectedList[_list[index]],
                    title: Text(_list[index]),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
          ),
        ])));
  }

  Align navRightButton(BuildContext context) {
    Align content;
    content = Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 0.0),
        child: RaisedButton(
            textColor: Colors.white,
            child: Text("完成", style: TextStyle(fontSize: 16.0)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            color: Colors.blue,
            highlightColor: Colors.blue[900],
            colorBrightness: Brightness.dark,
            splashColor: Colors.grey,
            onPressed: () {
              createConversation();
            }),
      ),
    );
    return content;
  }

  void createConversation() async {
    _checkboxSelectedList.forEach((key, value) {
      if (value == true) {
        _selectedClientList.add(key);
      }
    });
    if (_selectedClientList.length == 0) {
      showToastRed('请选择成员！');
      return;
    }

    if (Global.clientID != null) {
      Client currentClient = Client(id: Global.clientID);
      try {
        Conversation conversation = await currentClient.createConversation(
            isUnique: true,
            members: _selectedClientList,
            name: Global.clientID + '发起群聊');

        Navigator.pop(context);
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) =>
                new ConversationDetailPage(conversation: conversation),
          ),
        );
      } catch (e) {
        showToastRed('创建会话失败:${e.message}');
      }
    } else {
      showToastRed('用户未登录');
      return;
    }
  }
}
