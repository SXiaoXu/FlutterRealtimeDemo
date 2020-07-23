import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';

class InputMessageView extends StatefulWidget {
  final ScrollController scrollController;

  InputMessageView({Key key, @required this.scrollController})
      : super(key: key);

  @override
  _InputMessageViewState createState() => new _InputMessageViewState();
}

class _InputMessageViewState extends State<InputMessageView> {
  TextEditingController _messController = new TextEditingController();
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool canSend = false;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
//            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),

            color: Colors.white,
            child: TextFormField(
              autofocus: true,
              controller: _messController,
//              onChanged: validateInput,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                icon: Icon(Icons.send,
                    color: canSend ? Colors.blue : Colors.grey),
//                onPressed: sendMess,
              )),
            )));
  }

//  void validateInput(String test) {
//    setState(() {
//      canSend = test.length > 0;
//    });
//  }
//
//  void sendMess() {
//    if (!canSend) {
//      return;
//    }

    // 保证在组件build的第一帧时才去触发取消清空内容
//    WidgetsBinding.instance.addPostFrameCallback((_) {
//      _messController.clear();
//    });
    //  键盘自动收起
    //FocusScope.of(context).requestFocus(FocusNode());
//    widget.scrollController
//        .jumpTo(widget.scrollController.position.maxScrollExtent + 50);
//    setState(() {
//      canSend = false;
//    });
//  }
}
