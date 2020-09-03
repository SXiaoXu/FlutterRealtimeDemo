import 'package:flutter/material.dart';
import 'package:lcrealtime/routes/ConversationListPage.dart';
import 'package:lcrealtime/routes/LoginPage.dart';
import 'ContactsPage.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import '../Common/Global.dart';
import 'SelectChatMembers.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';

class HomeBottomBarPage extends StatefulWidget {
  @override
  _HomeBottomBarPageState createState() => _HomeBottomBarPageState();
}

class _HomeBottomBarPageState extends State<HomeBottomBarPage> {
  int _currentIndex = 0; //记录当前选中的页面

  List<Widget> _pages = [
    ConversationListPage(),
    ContactsPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  //退出
  Future clientClose() async {
    CommonUtil.showLoadingDialog(context); //发起请求前弹出loading

    close().then((value) {
      Navigator.pop(context); //销毁 loading
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => LoginPage()),
          (_) => false);
    }).catchError((error) {
      showToastRed(error.message);
      Navigator.pop(context); //销毁 loading
    });
  }

  Future<bool> showConfirmDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("确认退出登录"),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("确认"),
              onPressed: () {
                //Client close；
                //关闭对话框并返回true
                clientClose();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

    Align navRightButton(BuildContext context) {
      Align content;
      content = Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: 0.0),
          child: IconButton(
              icon: Icon(Icons.directions_run),
              onPressed: () {
                showConfirmDialog();
              }),
        ),
      );
      return content;
  }

  Align navLeftButton(BuildContext context) {
    Align content;
    content = Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 0.0),
        child: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new SelectChatMembers(),
                  ),
                );
            }),
      ),
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //导航栏
        title: Text("当前用户：${Global.clientID}"),
        centerTitle: true,
        //导航栏右侧菜单
        actions: <Widget>[
          navRightButton(context),
        ],
        leading: navLeftButton(context), //导航栏左侧菜单
      ),
      body: this._pages[this._currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // 底部导航
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('会话')),
          BottomNavigationBarItem(
              icon: Icon(Icons.perm_contact_calendar), title: Text('联系人')),
        ],
        currentIndex: this._currentIndex,
        fixedColor: Colors.blue,
        onTap: (index) {
          setState(() {
            //设置点击底部Tab的时候的页面跳转
            this._currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Future close() async {
    if (Global.clientID != null) {
      CurrentClient currentClint = CurrentClient();
      await currentClint.client.close();
      Global.removeClientID();
    } else {
      showToastRed('有 BUG，重启一下试试。。。');
    }
  }
}
