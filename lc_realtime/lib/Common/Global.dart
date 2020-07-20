import 'package:flutter/material.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    // 注册服务

  }
}