import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showToastRed(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 20.0);
}

void showToastGreen(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 20.0);
}

List<String> allClients() {
  List<String> list = [
    'Tom',
    'Jerry',
    'Bob',
    'Mary',
    'Linda',
    'Bill',
    'XiaoHong',
    'Lisa',
    'Object',
    'LC',
    'William',
    'robot',
  ];
  return list;
}

///根据给定的日期得到format后的日期
String getFormatDate(String dateOriginal) {
//现在的日期
  var today = DateTime.now();
//今天的23:59:59
  var standardDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
//传入的日期与今天的23:59:59秒进行比较
  Duration diff = standardDate.difference(DateTime.parse(dateOriginal));
  if (diff < Duration(days: 1)) {
//今天
// 09:20
    return dateOriginal.substring(11, 16);
  } else if (diff >= Duration(days: 1) && diff < Duration(days: 2)) {
//昨天
//昨天 09:20
    return "昨天 " + dateOriginal.substring(11, 16);
  } else {
//昨天之前
// 2019-01-23 09:20
    return dateOriginal.substring(0, 16);
  }
}

class CommonUtil {
  static Future<Null> showLoadingDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return new Material(
              color: Colors.transparent,
              child: WillPopScope(
                  onWillPop: () => new Future.value(false),
                  child: Center(
                    child: new CircularProgressIndicator(),
                  )));
        });
  }
}

class Global {
  static SharedPreferences _prefs;
  static String clientID;

  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();

    var _profile = _prefs.getString("clientID");
    if (_profile != null) {
      try {
        clientID = _profile;
      } catch (e) {
        print(e);
      }
    }
  }

  // 持久化 User 信息
  static saveClientID(String id) {
    _prefs.setString("clienidtID", id);
    clientID = id;
  }

  static removeClientID() {
    _prefs.remove("clientID");
    _prefs.clear();
  }
}
