import 'package:flutter/material.dart';

class UserProtocolPage extends StatefulWidget {
  @override
  _UserProtocolPageState createState() => new _UserProtocolPageState();
}

class _UserProtocolPageState extends State<UserProtocolPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String str = '''

本软件是一款为移动通信设备提供即时通信的应用软件。用户使用本应用需接受本协议的全部条款。

1.您使用本应用的行为必须合法。

2.我们将保留基于我们的判断检查用户内容的权利。

3.您在应用内上传与发布的内容必须合法，您将承担因下述行为所造成的风险而产生的全部法律责任

3.1 破坏先发所确认的基本原则的；

3.2 危害国家安全、泄露国家机密、破坏国家统一的；

3.3 损害国家荣誉和利益的；

3.4 煽动民族仇恨、民族歧视，破坏民族团结的；

3.5 破坏国家宗教政策，宣扬邪教和封建迷信的；

3.6 散布谣言，扰乱社会秩序，破坏社会稳定的；

3.7 散步淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪的；

3.8 侮辱或者诽谤他人，侵害他人合法权益的；

3.9 含有法律、行政法规禁止的其他内容的。
    ''';
    return Scaffold(
        appBar: AppBar(
          //导航栏
          title: Text("用户协议"),
          centerTitle: true,
        ),
        body: Scrollbar(
          // 显示进度条
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(str),
                ],

              ),
            ))
    );
  }
}