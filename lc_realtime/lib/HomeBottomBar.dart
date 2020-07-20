import 'package:flutter/material.dart';
import 'package:lcrealtime/ConversationListPage.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'ContactsPage.dart';

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

  Align navRightButton(BuildContext context) {
    Align content;

    content = Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 0.0),
        child: IconButton(icon: Icon(Icons.settings), onPressed: () {}),
      ),
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //导航栏
        title: Text("LeanMessage"),
        centerTitle: true,
        //导航栏右侧菜单
        actions: <Widget>[
          navRightButton(context),
        ],
      ),
//      drawer: new MyInformationPage(), //抽屉
      body: this._pages[this._currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // 底部导航
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.message), title: Text('会话')),
          BottomNavigationBarItem(icon: Icon(Icons.perm_contact_calendar), title: Text('联系人')),
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
}
