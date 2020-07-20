import 'package:flutter/material.dart';
import 'package:lcrealtime/ConversationListPage.dart';
import 'Common/Global.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'HomeBottomBar.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerClientId = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _clientID;
  Client _client;

  @override
  void initState() {
    super.initState();
    saveProfile();
  }

  saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String clientID = prefs.getString('clientID');
    if (clientID != null || clientID != '') {
      _controllerClientId.text = clientID;
      setState(() {});
    }
  }

  Future userLogin(String clientID) async {
    CommonUtil.showLoadingDialog(context); //发起请求前弹出loading
    saveClientID(clientID);


    login(clientID).then((value) {
      Navigator.pop(context); //销毁 loading
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => HomeBottomBarPage()),
          (_) => false);
    }).catchError((error) {
      showToastRed(error.message);
      print(error.message);
      Navigator.pop(context); //销毁 loading
    });



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              children: <Widget>[
                SizedBox(
                  height: kToolbarHeight,
                ),
                SizedBox(height: 80.0),
                buildTitle(),
                SizedBox(height: 20.0),
                buildOpenIDTextField(),
                SizedBox(height: 30.0),
                buildClientOpenButton(context),
              ],
            )));
  }

  Align buildClientOpenButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45.0,
        width: 270.0,
        child: RaisedButton(
          child: Text(
            '开始聊天',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          color: Colors.blue,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              //只有输入的内容符合要求通过才会到达此处
              _formKey.currentState.save();
              userLogin(_clientID);
            }
          },
        ),
      ),
    );
  }

  TextFormField buildOpenIDTextField() {
    return TextFormField(
      controller: _controllerClientId,
      decoration: InputDecoration(
        labelText: 'ID：',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return '请输入用户名';
        }
        return null;
      },
      onSaved: (String value) => _clientID = value,
    );
  }

  Padding buildTitle() {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            'LeanMessage',
            style: TextStyle(fontSize: 26.0, color: Colors.blue),
          ),
        ));
  }

  Future login(String clintID) async {
    _client = Client(id: clintID);
    await _client.open();
  }

  Future saveClientID(String clientID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clientID', clientID);
  }
}
