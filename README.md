## 应用简介

本应用是一款社交聊天的应用，实现了基本的聊天需求。实现这款应用一方面是为了了解与学习 Flutter，另一方面趁此机会熟悉 LeanCloud 即时通信 Flutter SDK 的使用。

应用还在持续完善中，现已经支持如下功能：

- 登录、登出
- 发起单聊
- 发起群聊
- 支持文字消息、语音消息、图片消息
- 支持展示未读消息数
- 支持展示会话成员
- 支持修改会话名称
- 支持离线消息推送
- 投诉举报不良信息
- 把某用户加入黑名单

### 页面截图

<div align = center>
<img src="https://lc-pdyu5vcy.cn-n1.lcfile.com/0129aa3eed52f5a94473.png/Snip20201019_5.png" />
<img src="https://lc-pDyU5vCY.cn-n1.lcfile.com/0e101d6ed6427be8e7ee.png/Snip20201019_6.png"/>
</div>
<br/>


## 开发环境搭建

第一步：Flutter 安装和环境搭建直接查看：[ Flutter 文档](https://flutter.dev/docs/get-started/install)。
第二步：登录 [LeanCloud 控制台](https://leancloud.cn/dashboard/login.html#/signin)，创建 LeanCloud 应用。

- 在控制台 > 应用 > 设置 >域名绑定页面绑定 **API 访问域名**。暂时没有域名可以略过这一步，LeanCloud 也提供了短期有效的免费体验域名；或者注册[ LeanCloud 国际版](https://console.leancloud.app/login.html#/signin)，国际版不要求绑定域名。
- 在控制台 > 应用 > 设置 > 应用 Keys 页面记录 AppID、AppKey 与服务器地址备用，这里的服务器地址就是 REST API 服务器地址。如果未绑定域名，控制台相同的位置可以获取到免费的共享域名。

## APP 初始化设置

在 pubspec.yaml 中，将 LeanCloud Flutter SDK  添加到依赖项列表:

```
dependencies:
  leancloud_official_plugin: ^1.0.0-beta.8   //即时通信插件
  leancloud_storage: ^0.2.9  //数据存储 SDK
```

然后运行 flutter pub get 安装 SDK。

因为 leancloud_official_plugin 是基于 [Swift SDK](https://github.com/leancloud/swift-sdk) 以及 [Java Unified SDK](https://github.com/leancloud/java-unified-sdk) 开发，所以还要安装后面两个 SDK，这样应用才能分别在 iOS 和 Android 设备运行。

需要通过 CocoaPods 安装 Swift SDK，这一步和安装 iOS 其他第三方库是一样的，在应用的 ios 目录下执行 pod update 即可。

```
$ cd ios/
$ pod update # 或者 $ pod install --repo-update
```

同样的，需要配置 Gradle 来安装 Java Unified SDK，打开工程目录 android/app/build.gradle，添加如下依赖，用 Android Studio 打开工程下的 android 目录，同步更新 Gradle 即可。

```
dependencies {
implementation 'cn.leancloud:storage-android:6.5.11'
implementation 'cn.leancloud:realtime-android:6.5.11'
implementation 'io.reactivex.rxjava2:rxandroid:2.1.1'
}
```

> 小 tips： 安装 SDK 期间遇到任何困难都可在 [LeanCloud 社区](https://forum.leancloud.cn/latest) 发帖求助。

SDK 安装成功以后，需要分别 [初始化 iOS 和 Android 平台](https://leancloud.cn/docs/sdk_setup-flutter.html#hash662673194)。

## 用户系统

Demo 里面并没有内置用户系统，可以选择联系人列表中的用户名来登录聊天系统。LeanCloud 即时通信服务端中只需要传入一个唯一标识字符串既可以表示一个「用户」，对应唯一的  Client， 在应用内唯一标识自己的 ID（clientId）。

在自己的项目中，如果已经有独立的用户系统也很方便维护。
或者使用 LeanStorage 提供的[用户系统](https://leancloud.cn/docs/leanstorage_guide-java.html#hash954895)。

## 会话列表

会话列表要展示当前用户所参与的会话，会话名称、会话的成员，会话的最后一条消息。还需要展示未读消息数目。

会话列表对应 Conversation 表，查询当前用户的全部会话只需要下面两行代码：

```
ConversationQuery query = client.conversationQuery();
await query.find();
```

按照会话的更新时间排序：

```
query.orderByDescending('updatedAt');
```

为了展示会话的最新一条消息，查询的时候要额外加上这行代码：

```
//让查询结果附带一条最新消息
query.includeLastMessage = true;
```

这样会话页面的后端数据就搞定了。下面看一下如何显示数据。

会话查询成功返回的数据格式是 Conversation 类型的 List。

- conversation.name 即会话的名称
- conversation.members 即会话成员
- conversation.lastMessage 就是当前会话的最新一条消息了。

### 未读消息数的处理

如果要在 Android 设备上运行，需要在初始化 Java SDK 的时候加上下面这行代码，表示开启未读消息数通知：

```
AVIMOptions.getGlobalOptions().setUnreadNotificationEnabled(true);
```

swift SDK 是默认支持，无需额外设置。

可以监听 onUnreadMessageCountUpdated 时间获取未读消息数通知：

```
client.onUnreadMessageCountUpdated = ({
  Client client,
  Conversation conversation,
}) {
  // conversation.unreadMessageCount 即该 conversation 的未读消息数量
};
```

注意要在以下两处清除未读消息数：

- 在对话列表点击某对话进入到对话页面时
- 用户正在某个对话页面聊天，并在这个对话中收到了消息时

## 会话详情页面

### 上拉加载更多历史消息

查询聊天记录的时候，先查最近的 10 条消息，然后以第一页的最早的消息作为开始，继续向前拉取消息：

```
List<Message> messages;
try {
//第一次查询成功
  messages = await conversation.queryMessage(
    limit: 10,
  );
} catch (e) {
  print(e);
}

try {
  // 返回的消息一定是时间增序排列，也就是最早的消息一定是第一个
  Message oldMessage = messages.first;
  // 以第一页的最早的消息作为开始，继续向前拉取消息
  List<Message> messages2 = await conversation.queryMessage(
    startTimestamp: oldMessage.sentTimestamp,
    startMessageID: oldMessage.id,
    startClosed: true,
    limit: 10,
  );
} catch (e) {
  print(e);
}
```

### 修改会话名

对话的名称是会话表 Conversation 默认的属性，更新会话名称只需要执行：

```
await conversation.updateInfo(attributes: {
  'name': 'New Name',
});
```

### 图片、语音消息

LeanCloud 即时通信 SDK 提供了下面几种默认的消息类型，Demo 中只用到了文本消息，图像消息和语音消息。

- TextMessage 文本消息
- ImageMessage 图像消息
- AudioMessage 音频消息
- VideoMessage 视频消息
- FileMessage 普通文件消息（.txt/.doc/.md 等各种）
- LocationMessage 地理位置消息

**注意，图片与语音消息需要先保存成 LCFile，然后再调用发消息接口发消息。**

比如发送音频消息。第一步先保存音频文件为 LCFile:

```
LCFile file = await LCFile.fromPath('message.wav', path);
await file.save();
```

第二步，再发消息:

```
//发送消息
AudioMessage audioMessage = AudioMessage.from(
  binaryData: file.data,
  format: 'wav',
);
await this.widget.conversation.send(message: audioMessage);
```

还要注意 iOS 设备发送图片消息注意打开相册和相机权限，语音消息需要麦克风权限：

```
<key>NSMicrophoneUsageDescription</key>
<string>录音功能需要访问麦克风，如果不允许，你将无法在聊天过程中发送语音消息。</string>
   
<key>NSCameraUsageDescription</key>
<string>发送图片功能需要访问您的相机。如果不允许，你将无法在聊天过程中发送图片消息。</string>
   
<key>NSPhotoLibraryUsageDescription</key>
<string>发送图片功能需要访问您的相册。如果不允许，你将无法在聊天过程中发送相册中的图片。</string>
```

## 离线推送通知

当用户下线以后，收到消息的时候，往往希望能有推送提醒。最简单的一种推送设置就是在 LeanCloud **控制台 > 消息 > 即时通讯 > 设置 > 离线推送设置** 页面，填入：

```
{ "alert": "您有新的消息", "badge": "Increment" }
```

这样 iOS 设备有离线消息的时候会收到提醒。这里 badge 参数为 iOS 设备专用，用于增加应用 badge 上的数字计数。

> 如果想在 Android 设备上实现离线推送，要增加一步接入[ Android 混合推送](https://leancloud.cn/docs/android_mixpush_guide.html)。

当然在实际项目中，离线消息的提醒往往会要求更加具体，比如推送中要包括消息的内容或者消息类型等。LeanCloud 也提供了其他几种定制离线推送的方法，感兴趣可以自行查阅[文档](https://leancloud.cn/docs/realtime-guide-intermediate.html#hash-485620600)。

还要注意，iOS 推送一定要正确配置 [配置 APNs 推送证书](https://leancloud.cn/docs/ios_push_cert.html)，并打开 Xcode 的推送开关：

<img src="https://lc-pDyU5vCY.cn-n1.lcfile.com/b01aff6f2bdc608c058c.png/84587ede-dcf7-4417-bcef-1519d172ceda.png" width = "535" height = "281.4" />


AppDelegate.swift 中开启推送，要这样设置：

```
import Flutter
import LeanCloud
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        do {
            LCApplication.logLevel = .all
            try LCApplication.default.set(
                 id: "你的APPID",
                               key: "你的 APPKey",
                               serverURL: "服务器地址")
            GeneratedPluginRegistrant.register(with: self)
            /*
            register APNs to access token, like this:
            */
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                switch settings.authorizationStatus {
                case .authorized:
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
                        if granted {
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        }
                    }
                default:
                    break
                }
                _ = LCApplication.default.currentInstallation
            }
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        } catch {
            fatalError("\(error)")
        }
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /*
        set APNs deviceToken and Team ID.
        */
        LCApplication.default.currentInstallation.set(
            deviceToken: deviceToken,
            apnsTeamId: "你的 TeamId")
        /*
        save to LeanCloud.
        */
        LCApplication.default.currentInstallation.save { (result) in
            switch result {
            case .success:
                break
            case .failure(error: let error):
                print(error)
            }
        }
    }
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //如果注册推送失败，可以检查 error 信息
        print(error)
    }
}
```

## 投诉举报、黑名单

在 APP Store 审核过程中，因为用户可以随意发送消息，被要求对用户生成的内容要有适当的预防措施。

要求提供下面这两条内容：

- A mechanism for users to flag objectionable content  

用户标记不良信息的机制，就是举报功能。

- A mechanism for users to block abusive users

用户阻止滥用用户的机制，实际就是黑名单。

### 实现举报功能

我的解决办法是在消息处长按弹出举报窗口。

<img src="https://lc-pDyU5vCY.cn-n1.lcfile.com/a0a180ce30b221f8dfc0.png/report.png" width = "288" height = "513" />

使用 LeanCloud 存储服务，新建一张 Report 表用于记录举报信息：

```
//保存一条举报信息
LCObject report = LCObject('Report');
report['clientID'] = Global.clientID;   //举报人
report['messageID'] = messageID;   //消息 ID
report['conversationID'] = this.widget.conversation.id;  //会话 ID
report['content'] = _selectedReportList.toString(); //举报内容
await report.save(); //保存举报信息
```

可以在控制台查看举报内容：

![img](https://lc-pDyU5vCY.cn-n1.lcfile.com/c40eef4909993405c688.png/dae5cbca-6b27-43e5-a49e-df5561c6da9f.png)

### 实现黑名单功能

<img src="https://lc-pDyU5vCY.cn-n1.lcfile.com/77302c6a7c97c25471de.png/blacklist.png" width = "288" height = "513" />

我的解决办法是，在联系人列表处单击联系人弹框提示是否加入黑名单。

黑名单实现思路是新建一张 BlackList 表，来保存每个用户的黑名单列表，使用 [LeanCloud 云函数](https://leancloud.cn/docs/realtime-guide-systemconv.html#hash1748033991) 实现屏蔽消息。在 [_messageReceived](https://leancloud.cn/docs/realtime-guide-systemconv.html#hash-1573260517) 这个 Hook 函数下（这个 hook 发生在消息到达 LeanCloud 云端之后），先查此条消息的发件人与收件人是否在黑名单列表，如果在黑名单列表就删除其中要求屏蔽的收件人，返回新的收件人列表。

实现起来也比较简单，把下面这个云函数粘贴在 LeanCloud 控制台 > 云引擎 >云函数在线编辑框中即可。

![img](https://lc-pDyU5vCY.cn-n1.lcfile.com/14b3d005f070241d1f05.png/bd006a73-cf3d-45e8-acc5-5bbc8b4b74d3.png)

> 步骤
>
> 先点击「创建函数」，然后选择 _messageReceived 类型，粘贴下面的代码，最后点击「部署」按钮。

等待部署完成，黑名单功能就已经实现成功，将不再收到加入黑名单用户的全部消息。

```
//下面这个函数粘贴在 LeanCloud 控制台

AV.Cloud.define('_messageReceived', async function(request) {
let fromPeer = request.params.fromPeer;
let toPeersNew = request.params.toPeers;

var query = new AV.Query('BlackList');
query.equalTo('blackedList', fromPeer);
query.containedIn('clientID', toPeersNew);
return query.find().then((results) => {
    if (results.length > 0) {
        var clientID = results[0].get('clientID');
        var index = toPeersNew.indexOf(clientID);
        if (index > -1) {
            toPeersNew.splice(index, 1);
        }
        return {
            toPeers: toPeersNew
        }
    }
    return {
    }
});
})
```

## APP 安装

[APP Store 下载链接](https://apps.apple.com/cn/app/leanmessage/id1529417244)

## 文档

- [LeanCloud 即时通信插件链接](https://pub.dev/packages/leancloud_official_plugin#leancloud_official_plugin)
- [LeanCloud 即时通信开发文档](https://leancloud.cn/docs/#即时通讯)
- [Flutter 文档](https://flutter.dev/docs)
