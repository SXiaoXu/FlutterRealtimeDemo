import 'package:flutter/material.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';
import '../Common/Global.dart';
import 'HomeBottomBar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
//  GlobalKey<FormState> _formKey =  GlobalKeys.formKey;
//  final GlobalKey<FormState> _formKey =
//  new GlobalKey<FormState>(debugLabel: '_LoginFormState');
  String _clientID;

  @override
  void initState() {
    super.initState();
    if (Global.clientID != null) {
      _clientID = Global.clientID;
      setState(() {});
    }
  }

  Future userLogin(String clientID) async {
    CommonUtil.showLoadingDialog(context); //发起请求前弹出loading
    Global.saveClientID(clientID);

    login(clientID).then((value) {
      Navigator.pop(context); //销毁 loading
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => HomeBottomBarPage()),
              (_) => false);
    }).catchError((error) {
      showToastRed(error.message);
      Navigator.pop(context); //销毁 loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
//            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              children: <Widget>[
                SizedBox(
                  height: kToolbarHeight,
                ),
                SizedBox(height: 80.0),
                buildTitle(),
                SizedBox(height: 30.0),
//                buildOpenIDTextField(),
                buildChooseUserDropdownButton(context),
                SizedBox(height: 30.0),
                buildClientOpenButton(context),
              ],
            )));
  }

  Padding buildChooseUserDropdownButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('ID： '),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                DropdownButton<String>(
                  value: this._clientID,
                  onChanged: (String newValue) {
                    setState(() {
                      this._clientID = newValue;
                    });
                  },
                  items: allClients()
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            userLogin(_clientID);
//            if (_formKey.currentState.validate()) {
//              //只有输入的内容符合要求通过才会到达此处
//              _formKey.currentState.save();
//            }
          },
        ),
      ),
    );
  }

  Text buildOpenIDTextField() {
    return Text('ID：');
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
    CurrentClient currentClint = CurrentClient();
    if (clintID != currentClint.client.id) {
      currentClint.updateClient();
    }
    await currentClint.client.open();
  }
}
