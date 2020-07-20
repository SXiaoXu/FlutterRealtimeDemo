import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:leancloud_storage/leancloud.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'Common/Global.dart';
import 'package:lcrealtime/LoginPage.dart';

void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'LeanCloud',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
