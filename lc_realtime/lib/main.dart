import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

Future<List> fetchPost() async {
  // new an IM client
  Client client = Client(id: 'Tom');
// open it
  await client.open();

  List<String> objectIDs = ['5ea1084490aef5aa84d679f2'];
// new query from an opened client
  ConversationQuery query = client.conversationQuery();
// set query condition
  Map whereMap = {
    'objectId': {
      '\$in': objectIDs,
    }
  };
  query.whereString = jsonEncode(whereMap);
  query.limit = objectIDs.length;
// do the query
  List<Conversation> conversations = await query.find();
  print(conversations.length);

// 构建对象

//LCObject object = new LCObject('Todo');
//  object['intValue'] = 123;
//  object['boolValue'] = true;
//  object['stringValue'] = 'hello, world';
//  object['time'] = DateTime.now();
//  object['intList'] = [1, 1, 2, 3, 5, 8];
//  object['stringMap'] = {'k1': 111, 'k2': true, 'k3': 'Hi'};
//  LCObject nestedObj = new LCObject('World');
//  nestedObj['content'] = '7788';
//  object['objectValue'] = nestedObj;
//  object['pointerList'] = [new LCObject('World'), nestedObj];

  return conversations;
}

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Fetch Data Example',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Fetch Data Example'),
        ),
        body: new Center(
          child: new FutureBuilder<List>(
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new Text(snapshot.data.length.toString());
              } else if (snapshot.hasError) {
                return new Text('${snapshot.error}');
              }
              return new CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
