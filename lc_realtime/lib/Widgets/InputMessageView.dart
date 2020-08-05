import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/ConversationModel.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:lcrealtime/States/ChangeNotifierProvider.dart';

class InputMessageView extends StatefulWidget {
  final ScrollController scrollController;
  final Conversation conversation;

  InputMessageView(
      {Key key, @required this.scrollController, this.conversation})
      : super(key: key);

  @override
  _InputMessageViewState createState() => new _InputMessageViewState();
}

class _InputMessageViewState extends State<InputMessageView> {
  TextEditingController _messController = new TextEditingController();
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool _canSend = false;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
//            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            color: Colors.white,
            child: TextFormField(
//              autofocus: true,
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
        mess.emit(MyEvent.NewMessage,textMessage);
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

