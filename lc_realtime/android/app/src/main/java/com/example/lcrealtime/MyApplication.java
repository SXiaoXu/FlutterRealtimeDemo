package com.example.lcrealtime;
import cn.leancloud.LCLogger;
import cn.leancloud.LeanCloud;
import cn.leancloud.im.LCIMOptions;
import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication{
    private static final String LC_App_Id = "1eUivazFXYwJvuGpPl2LE4uY-gzGzoHsz";
    private static final String LC_App_Key = "nLMIaQSwIsHfF206PnOFoYYa";
    private static final String LC_Server_Url = "https://1euivazf.lc-cn-n1-shared.com";
//    private static final String MEIZU_APP = "119851";
//    private static final String MEIZU_KEY = "73c48ba926fb40b898797b819030830d";
//
//    private static final String MI_APPID = "2882303761517988199";
//    private static final String MI_APPKEY = "5571798886199";
    @Override
    public void onCreate() {
        super.onCreate();

        LCIMOptions.getGlobalOptions().setUnreadNotificationEnabled(true);

        LeanCloud.setLogLevel(LCLogger.Level.DEBUG);
        LeanCloud.initialize(this, LC_App_Id, LC_App_Key, LC_Server_Url);

//        //华为推送
//        LCMixPushManager.registerHMSPush(this);
//        //小米
//        LCMixPushManager.registerXiaomiPush(this , MI_APPID, MI_APPKEY);
//        //魅族
//        LCMixPushManager.registerFlymePush(this, MEIZU_APP, MEIZU_KEY);

    }
}
