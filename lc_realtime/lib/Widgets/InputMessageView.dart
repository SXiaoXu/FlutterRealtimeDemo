import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/ConversationModel.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:lcrealtime/States/ChangeNotifierProvider.dart';

class InputMessageView extends StatefulWidget {
  final Conversation conversation;
  InputMessageView(
      {Key key,
      @required
//      this.scrollController,
          this.conversation})
      : super(key: key);

  @override
  _InputMessageViewState createState() => new _InputMessageViewState();
}

class _InputMessageViewState extends State<InputMessageView> {
  TextEditingController _messController = new TextEditingController();
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool _canSend = false;
  FocusNode myFocusNode;
  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
    mess.on(MyEvent.ScrollviewDidScroll, (arg) {
      myFocusNode.unfocus(); // 失去焦点
//      FocusScope.of(context).requestFocus(myFocusNode);     // 获取焦点
    });
    // 监听焦点变化，获得焦点时focusNode.hasFocus 值为true，失去焦点时为false。
    myFocusNode.addListener(() {
//      if (myFocusNode.hasFocus) {
//        //列表滚动到底部
//        mess.emit(MyEvent.EditingMessage);
//      }
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
    //取消订阅
    mess.off(
      MyEvent.ScrollviewDidScroll,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
//            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            color: Colors.white,
            child: TextFormField(
//              autofocus: true,
              focusNode: myFocusNode,
              controller: _messController,
              onChanged: validateInput,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                icon: Icon(Icons.send,
                    color: _canSend ? Colors.blue : Colors.grey),
                onPressed: sendMessage,
              )),
            )));
  }

  void validateInput(String test) {
    setState(() {
      _canSend = test.length > 0;
    });
  }

  Future sendMessage() async {
    if (_messController.text != null && _messController.text != '') {
      try {
        TextMessage textMessage = TextMessage();
        textMessage.text = _messController.text;
        await this.widget.conversation.send(message: textMessage);
        showToastGreen('发送成功');
        mess.emit(MyEvent.NewMessage, textMessage);
        _messController.clear();
        FocusScope.of(context).requestFocus(FocusNode());
        _canSend = false;
      } catch (e) {
        showToastRed(e.toString());
        print(e.toString());
      }
    } else {
      showToastRed('未输入消息内容');
      return;
    }
  }
}
