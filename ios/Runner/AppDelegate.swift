import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("🍎 AppDelegate - application(_:didFinishLaunchingWithOptions:) 시작")
    let controller = window?.rootViewController as! FlutterViewController
    let messenger = controller.binaryMessenger
    
    // 네이티브 뷰 등록
    print("🍎 AppDelegate - NativeListViewFactory 초기화")
    let factory = NativeListViewFactory(messenger: messenger)
    print("🍎 AppDelegate - registrar 가져오기 시도")
    if let registrar = registrar(forPlugin: "native-list-view") {
      print("🍎 AppDelegate - registrar.register 호출")
      registrar.register(
        factory,
        withId: "native-list-view"
      )
      print("🍎 AppDelegate - registrar.register 완료")
    } else {
      print("❌ AppDelegate - registrar가 nil입니다")
    }
    
    print("🍎 AppDelegate - GeneratedPluginRegistrant.register 호출")
    GeneratedPluginRegistrant.register(with: self)
    print("🍎 AppDelegate - 초기화 완료")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
