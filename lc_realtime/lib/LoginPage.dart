import 'package:flutter/material.dart';
import 'Common/Global.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerName = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _userName, _password;

  @override
  void initState() {
    super.initState();
  }

  Future userLogin(String name, String password) async {
//    CommonUtil.showLoadingDialog(context); //发起请求前弹出loading
//
//    initLeanCloud().then((response) {
//      saveUserType(this._userIfLeancloud);
//      saveUserProfile();
//      login(name, password).then((value) {
//        Navigator.pop(context); //销毁 loading
//        Navigator.pushAndRemoveUntil(
//            context,
//            new MaterialPageRoute(builder: (context) => HomeBottomBarPage()),
//            (_) => false);
//      }).catchError((error) {
//        showToastRed(error.message);
//        Navigator.pop(context); //销毁 loading
//      });
//    }).catchError((error) {
//      showToastRed(error.message);
//      Navigator.pop(context); //销毁 loading
//    });
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
                buildTitle(),
                SizedBox(height: 20.0),
                SizedBox(height: 30.0),
                buildOpenIDTextField(),
                SizedBox(height: 30.0),
                SizedBox(height: 60.0),
                buildClientOpenButton(context),
                SizedBox(height: 30.0),
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
            style: Theme.of(context).primaryTextTheme.headline,
          ),
          color: Colors.blue,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              //只有输入的内容符合要求通过才会到达此处
              _formKey.currentState.save();
              userLogin(_userName, _password);
            }
          },
//          shape: StadiumBorder(side: BorderSide()),
        ),
      ),
    );
  }

  TextFormField buildOpenIDTextField() {
    return TextFormField(
      controller: _controllerName,
      decoration: InputDecoration(
        labelText: 'ID：',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return '请输入用户名';
        }
        return null;
      },
      onSaved: (String value) => _userName = value,
    );
  }

  Padding buildTitle() {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            'LeanMessage',
            style: TextStyle(fontSize: 28.0, color: Colors.blue),
          ),
        ));
  }

  Future login(String name, String password) async {}
}
