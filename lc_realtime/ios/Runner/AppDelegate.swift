import Flutter
import LeanCloud

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        do {
            LCApplication.logLevel = .all
            try LCApplication.default.set(
                id: "1eUivazFXYwJvuGpPl2LE4uY-gzGzoHsz",
                key: "nLMIaQSwIsHfF206PnOFoYYa",
                serverURL: "https://1euivazf.lc-cn-n1-shared.com")
            GeneratedPluginRegistrant.register(with: self)
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        } catch {
            fatalError("\(error)")
        }
    }
}
