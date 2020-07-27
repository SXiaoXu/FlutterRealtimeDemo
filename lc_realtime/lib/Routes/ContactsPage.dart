import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
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

//  @override
//  Widget build(BuildContext context) {
//    return Column(children: <Widget>[
//      Expanded(
//        child: ListView.separated(
//          //添加分割线
//            separatorBuilder: (BuildContext context, int index) {
//              return new Divider(
//                height: 0.8,
//                color: Colors.grey,
//              );
//            },
//            itemCount: _list.length,
////            itemExtent: 50.0, //强制高度为50.0
//            itemBuilder: (BuildContext context, int index) {
//              return ListTile(title: Text(_list[index]));
//            }),
//      ),
//    ]);
//  }
  @override
  Widget build(BuildContext context) {
    final messages = [
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      'This is a short message.',
      'This is a relatively longer line of text.',
      'Hi!'
    ];
    return Scaffold(
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {


          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: index % 2 == 0
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20.0),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: index % 2 == 0
                      ? BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  )
                      : BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  child: Text(messages[index],
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
