import 'package:flutter/material.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';

class ConversationModel extends ChangeNotifier {

  //更新消息列表
  Future<List<Message>> updateMessageListView(Conversation conversation) async {
    List<Message> messages;
    try {
      messages = await conversation.queryMessage(
        limit: 100,
      );
      print(messages.length);
    } catch (e) {
      print(e.message);
    }
    return messages;
  }

  void sendNewMessage() {
    // 通知监听器（订阅者），重新构建InheritedProvider， 更新状态。
    notifyListeners();
  }
}
