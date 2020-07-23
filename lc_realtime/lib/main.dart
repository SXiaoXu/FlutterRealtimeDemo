import 'package:flutter/material.dart';
import 'Common/Global.dart';
import 'package:lcrealtime/routes/LoginPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Global.init().then((e) => runApp(MyApp()));
}

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
