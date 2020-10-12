import 'package:flutter/material.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';
import 'package:lcrealtime/Routes/UserProtocol.dart';
import '../Common/Global.dart';
import 'HomeBottomBar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _clientID;
  bool _checkboxSelected = true;

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
            child: ListView(
      padding: EdgeInsets.symmetric(horizontal: 22.0),
      children: <Widget>[
        SizedBox(
          height: kToolbarHeight,
        ),
        SizedBox(height: 80.0),
        buildTitle(),
        SizedBox(height: 30.0),
        buildChooseUserDropdownButton(context),
        SizedBox(height: 30.0),
        buildCheckBox(context),
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

  Padding buildCheckBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            value: _checkboxSelected,
            activeColor: Colors.blue, //选中时的颜色
            onChanged: (value) {
              setState(() {
                _checkboxSelected = value;
              });
            },
          ),
          GestureDetector(
            child: Text(
              '我已阅读并同意使用协议',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 15.0,
              ),
            ),
            onTap: () => showUserProtocolPage(), //点击
          )
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
            if (!_checkboxSelected) {
              showToastRed('未同意用户使用协议');
            } else {
              userLogin(_clientID);
            }
          },
        ),
      ),
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

  showUserProtocolPage() {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new UserProtocolPage(),
      ),
    );
  }

  Future login(String clintID) async {
    CurrentClient currentClint = CurrentClient();
    if (clintID != currentClint.client.id) {
      currentClint.updateClient();
    }
    await currentClint.client.open();
  }
}
