package com.example.lcrealtime;
import cn.leancloud.AVLogger;
import cn.leancloud.AVOSCloud;
import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication{
    private static final String LC_App_Id = "1eUivazFXYwJvuGpPl2LE4uY-gzGzoHsz";
    private static final String LC_App_Key = "nLMIaQSwIsHfF206PnOFoYYa";
    private static final String LC_Server_Url = "https://1euivazf.lc-cn-n1-shared.com";

    @Override
    public void onCreate() {
        super.onCreate();
        AVOSCloud.setLogLevel(AVLogger.Level.DEBUG);
        AVOSCloud.initialize(this, LC_App_Id, LC_App_Key, LC_Server_Url);
        AVIMOptions.getGlobalOptions().setUnreadNotificationEnabled(true);
    }
}
