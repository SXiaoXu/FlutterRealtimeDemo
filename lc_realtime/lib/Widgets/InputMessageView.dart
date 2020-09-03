import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/States/GlobalEvent.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:flutter_plugin_record/index.dart';

class InputMessageView extends StatefulWidget {
  final Conversation conversation;
  InputMessageView({Key key, @required this.conversation}) : super(key: key);
  @override
  _InputMessageViewState createState() => new _InputMessageViewState();
}

class _InputMessageViewState extends State<InputMessageView> {
  TextEditingController _messController = new TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  FocusNode myFocusNode;
  FlutterPluginRecord recordPlugin;
  bool _isShowImageGridView = false;
  bool _isShowVoiceIcon = true;
  IconData _voiceOrTextIcon;
  List _icons = [
    {'name': '照片', 'icon': Icons.photo_library},
    {'name': '拍摄', 'icon': Icons.photo_camera},
    //可以继续添加更多 icons
  ];

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
    mess.on(MyEvent.ScrollviewDidScroll, (arg) {
      myFocusNode.unfocus(); // 失去焦点
    });
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        setState(() {
          _isShowImageGridView = false;
        });
      }
    });
    _voiceOrTextIcon = Icons.keyboard_voice;
    //录音组件
    recordPlugin = new FlutterPluginRecord();
    recordPlugin.init();
//
//    /// 开始录制或结束录制的监听
//    recordPlugin.response.listen((data) {
//      if (data.msg == "onStop") {
//        ///结束录制时会返回录制文件的地址方便上传服务器
//        print("onStop " + data.path);
//      } else if (data.msg == "onStart") {
//        print("onStart --");
//      }
//    });

//    mess.on(MyEvent.PlayAudioMessage, (path) {
//      showToastGreen('消息正在播放');
//      recordPlugin.playByPath(path,'url');
//    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
    //取消订阅
    mess.off(
      MyEvent.ScrollviewDidScroll,
    );
    mess.off(
      MyEvent.PlayAudioMessage,
    );
    recordPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Column(children: <Widget>[
        Container(
          child: buildTextField(),
          decoration: BoxDecoration(color: Color.fromRGBO(241, 243, 244, 0.9)),
        ),
        buildImageGridView()
      ]),
    );
  }

  Widget buildImageGridView() {
    if (_isShowImageGridView) {
      return Container(
        decoration: BoxDecoration(color: Color.fromRGBO(241, 243, 244, 0.9)),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.8),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            scrollDirection: Axis.vertical,
            itemCount: _icons.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildIconButton(
                  _icons[index]['name'], _icons[index]['icon']);
            }),
        height: 200,
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget _buildIconButton(String name, IconData icon) {
    return Column(
      children: <Widget>[
        GestureDetector(
          excludeFromSemantics: true,
          onTap: () {
            if (name == '照片') {
              _onImageButtonPressed(ImageSource.gallery, context: context);
            } else if (name == '拍摄') {
              _onImageButtonPressed(ImageSource.camera, context: context);
            }
          },
          child: Container(
            width: 60.0,
            height: 60.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
            child: Icon(
              icon,
              size: 28.0,
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 3.0),
            child: Text(name,
                style: TextStyle(fontSize: 12.0, color: Colors.grey[600])))
      ],
    );
  }

  Widget buildTextField() {
    return Container(
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Container(
            child: IconButton(
                onPressed: _isShowVoiceIcon
                    ? voiceButtonPressed
                    : keyboardButtonPressed,
                iconSize: 22.0,
                highlightColor: Color(00000000),
                focusColor: Color(00000000),
                hoverColor: Color(00000000),
                icon: Icon(
                  _voiceOrTextIcon,
                  //                  color: Colors.grey,
                )),
          ),
          Container(child: voiceOrTextView()),
          Container(
            child: IconButton(
                onPressed: showImageGirdView,
                iconSize: 22.0,
                highlightColor: Color(00000000),
                focusColor: Color(00000000),
                hoverColor: Color(00000000),
                icon: Icon(
                  Icons.add,
                  //                  color: Colors.grey,
                )),
          ),
        ],
      ),
    );
  }

  Widget voiceOrTextView() {
    if (_isShowVoiceIcon) {
      return Flexible(
        child: Container(
          margin: const EdgeInsets.only(top: 2, bottom: 2),
          child: TextField(
            textInputAction: TextInputAction.send,
            controller: _messController,
            focusNode: myFocusNode,
            onEditingComplete: () {
              sendTextMessage();
            },
          ),
        ),
      );
    } else {
      return Flexible(
        child: Container(
//            margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
            child:
                VoiceWidget(startRecord: startRecord, stopRecord: stopRecord)),
      );
    }
  }

  void sendVoiceMessage() async {}

  void voiceButtonPressed() {
    //TODO 显示语音条

    setState(() {
      _isShowImageGridView = false;
      _isShowVoiceIcon = false;
      _voiceOrTextIcon = Icons.keyboard;
    });
    if (myFocusNode.hasFocus) {
      myFocusNode.unfocus();
    }
  }

  void keyboardButtonPressed() {
    setState(() {
      _isShowImageGridView = false;
      _isShowVoiceIcon = true;
      _voiceOrTextIcon = Icons.keyboard_voice;
    });
    if (!myFocusNode.hasFocus) {
      myFocusNode.requestFocus();
    }
  }

  // 点击加号
  void showImageGirdView() {
    // 监听焦点变化，获得焦点时focusNode.hasFocus 值为true，失去焦点时为false。
    if (myFocusNode.hasFocus) {
      myFocusNode.unfocus();
    }
    setState(() {
      _isShowImageGridView = !_isShowImageGridView;
      //      _isShowVoice = false;
    });
  }

  //发消息
//    void sendMessage(MyMessageType type) {
//      switch (type.index) {
//        case 0:
//          //TextMessage 文本消息
//
//          break;
//        case 1:
//          //ImageMessage 图像消息
//        sendImageMessage();
//          break;
//        case 2:
//          //AudioMessage 音频消息
//          break;
//        case 3:
//          //VideoMessage 视频消息
//          break;
//        case 4:
//          //FileMessage 普通文件消息（.txt/.doc/.md 等各种）
//          break;
//        case 5:
//          //LocationMessage 地理位置消息
//          break;
//        default:
//          {
//            showToastRed('消息类型错误！');
//          }
//          break;
//      }
//    }
  void sendTextMessage() async {
    if (_messController.text != null && _messController.text != '') {
      try {
        TextMessage textMessage = TextMessage();
        textMessage.text = _messController.text;
        await this.widget.conversation.send(message: textMessage);
//        showToastGreen('发送成功');
        mess.emit(MyEvent.NewMessage, textMessage);
        _messController.clear();
        myFocusNode.unfocus();
      } catch (e) {
        showToastRed(e.toString());
        print(e.toString());
      }
    } else {
      showToastRed('未输入消息内容');
      return;
    }
  }

  //发送图片消息
  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    final _imageFile = await _imagePicker.getImage(
      source: source,
      maxWidth: MediaQuery.of(context).size.width * 0.4,
      maxHeight: MediaQuery.of(context).size.width * 0.6,
      imageQuality: 70,
    );
    Image image = Image.file(File(_imageFile.path));
//     预先获取图片信息
    double imageHeight = 250;
    image.image
        .resolve(new ImageConfiguration())
        .addListener(new ImageStreamListener((ImageInfo info, bool _) {
      //图片的宽高 info.image.height
      print('image.height:---->' + info.image.height.toString());
      print('image.width:---->' + info.image.width.toString());
      imageHeight = info.image.height.toDouble();
    }));
    Uint8List bytes = await _imageFile.readAsBytes();
    LCFile file = LCFile.fromBytes('imageMessage.png', bytes);

    await file.save(onProgress: (int count, int total) {
      print('$count/$total');
      if (count == total) {
        //发消息
        sendImageMessage(file.data, imageHeight);
      }
    });
  }

  void sendImageMessage(Uint8List binaryData, double imageHeight) async {
    //上传完成
    try {
      ImageMessage imageMessage = ImageMessage.from(binaryData: binaryData);
      await this.widget.conversation.send(message: imageMessage);
//      showToastGreen('发送成功 url:' + imageMessage.url);
      //预先显示图片要知道高度
      mess.emit(MyEvent.ImageMessageHeight, imageHeight);

//      print('发送成功 url:' + imageMessage.url);
      mess.emit(MyEvent.NewMessage, imageMessage);
      setState(() {
        _messController.clear();
        myFocusNode.unfocus();
        _isShowImageGridView = false;
      });
    } catch (e) {
      showToastRed(e.toString());
      print(e.toString());
    }
  }

  startRecord() {
    print("开始录制");
  }

  stopRecord(String path, double audioTimeLength) async {
    print("结束束录制");
    print("音频文件位置" + path);
    print("音频录制时长" + audioTimeLength.toString());
    LCFile file = await LCFile.fromPath('message.wav', path);
    file.addMetaData('duration', audioTimeLength.toInt());
    try {
      await file.save();
      print(file.objectId);
      sendAudioMessage(file.data);
    } catch (e) {
      showToastRed(e.toString());
      print(e.toString());
    }
  }

  void sendAudioMessage(Uint8List binaryData) async {
    try {
      //发送消息
      AudioMessage audioMessage = AudioMessage.from(
        binaryData: binaryData,
        format: 'wav',
      );
      audioMessage.text = '语音消息';
      await this.widget.conversation.send(message: audioMessage);
      mess.emit(MyEvent.NewMessage, audioMessage);
//      print('语音消息发送成功');
      setState(() {
        _messController.clear();
        myFocusNode.unfocus();
        _isShowImageGridView = false;
      });
    } catch (e) {
      showToastRed(e.toString());
      print(e.toString());
    }
  }
}
