import 'package:flutter/material.dart';

// 封装的文本组件Widget
class TextWidget extends StatefulWidget {
  final Key key;
//  final int count;

  // 接收一个Key
  TextWidget(this.key);
  @override
  State<StatefulWidget> createState() => TextWidgetState();
}

class TextWidgetState extends State<TextWidget> {
  static int _count;

  @override
  void initState() {
    super.initState();
    _count = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_count > 0) {
      String showNum = '';
      if (_count < 10) {
        showNum = ''' ''' + _count.toString() + ''' ''';
      } else {
        showNum = _count.toString();
      }
      return Text(
        showNum,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  void onPressed(int unreadCount) {
    setState(() => _count = unreadCount);
  }
}
