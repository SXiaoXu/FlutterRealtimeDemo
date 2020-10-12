import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MyEvent {
  NewMessage,
  ScrollviewDidScroll,
  ImageMessageHeight,
  PlayAudioMessage,
  ConversationRefresh
}

//TextMessage 文本消息
//ImageMessage 图像消息
//AudioMessage 音频消息
//VideoMessage 视频消息
//FileMessage 普通文件消息（.txt/.doc/.md 等各种）
//LocationMessage 地理位置消息

enum MyMessageType {
  TextMessage,
  ImageMessage,
  AudioMessage,
  VideoMessage,
  FileMessage,
  LocationMessage
}

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

String getMessageString(Message message) {
  String messageString = '';
  if (message.binaryContent != null) {
    print('收到二进制消息：${message.binaryContent.toString()}');
    messageString = '收到二进制消息';
  } else if (message is TextMessage) {
    print('收到文本类型消息：${message.text}');
    messageString = message.text;
  } else if (message is LocationMessage) {
    print('收到地理位置消息，坐标：${message.latitude},${message.longitude}');
    messageString = '地理位置消息';
  } else if (message is FileMessage) {
    if (message is ImageMessage) {
      print('收到图像消息，图像 URL：${message.url}');
      messageString = '收到图像消息';
    } else if (message is AudioMessage) {
      print('收到音频消息，消息时长：${message.duration}');
      messageString = '收到语音消息';
    } else if (message is VideoMessage) {
      print('收到视频消息，消息时长：${message.duration}');
      messageString = '收到视频消息';
    } else {
      print('收到.txt/.doc/.md 等各种类型的普通文件消息，URL：${message.url}');
      messageString = '收到文件消息';
    }
  }
//  else if (message is CustomMessage) {
//    // CustomMessage 是自定义的消息类型
//    print('收到自定义类型消息');
//  }
  else {
    // 这里可以继续添加自定义类型的判断条件
    print('收到未知消息类型');
    messageString = '未知消息类型';
//    if (message.stringContent != null) {
//      print('收到普通消息：${message.stringContent}');
//      lastMessage = message.stringContent;
//    }
  }
  return messageString;
}

///根据给定的日期得到format后的日期
String getFormatDate(String dateOriginal) {
  if (dateOriginal == null) {
    return '';
  }
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
    LeanCloud.initialize(
        '1eUivazFXYwJvuGpPl2LE4uY-gzGzoHsz', 'nLMIaQSwIsHfF206PnOFoYYa',
        server: 'https://1euivazf.lc-cn-n1-shared.com',
        queryCache: new LCQueryCache());
  }

  static saveClientID(String id) {
    _prefs.setString("clienidtID", id);
    clientID = id;
  }

  static removeClientID() {
    _prefs.remove("clientID");
    _prefs.clear();
  }
}
