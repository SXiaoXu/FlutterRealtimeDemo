import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:flutter/material.dart';
import '../Common/Global.dart';

class CurrentClient {
  factory CurrentClient() => _sharedInstance();
  static CurrentClient _instance = CurrentClient._();
  Client client ;

  CurrentClient._() {
    print('初始化');
    client = Client(id: Global.clientID);
  }

  static CurrentClient _sharedInstance() {
    return _instance;
  }

  void updateClient(){
    client = Client(id: Global.clientID);
  }
//
//  void open() async {
//    print('clint.open');
////    await client.open();
//  }
}
