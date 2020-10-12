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

3.您在应用内上传与发布的内容必须合法，否则您将承担全部法律责任。

4.一旦发现您上传的内容非法，我们会删除您账号下的全部数据，并禁止继续访问。

5. 禁止发布危害国家安全、泄露国家机密、破坏国家统一的内容。

6. 禁止发布煽动民族仇恨、民族歧视，破坏民族团结的内容。

7. 禁止发布破坏国家宗教政策，宣扬邪教和封建迷信的内容。

8. 禁止发布扰乱社会秩序，破坏社会稳定的谣言。

9. 禁止散步淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪的内容

10. 禁止发布侮辱或者诽谤他人，侵害他人合法权益的内容

11. 禁止发布含有法律、行政法规禁止的其他内容的。
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