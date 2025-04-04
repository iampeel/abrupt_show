import Flutter
import UIKit

class NativeListViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private static var listData: [String] = []
    private let channel: FlutterMethodChannel
    
    init(messenger: FlutterBinaryMessenger) {
        print("🍎 NativeListViewFactory - 초기화 시작")
        self.messenger = messenger
        self.channel = FlutterMethodChannel(name: "com.example.app/native_list", binaryMessenger: messenger)
        super.init()
        
        // Method Channel 설정
        print("🍎 NativeListViewFactory - setMethodCallHandler 설정")
        channel.setMethodCallHandler { [weak self] call, result in
            print("🍎 NativeListViewFactory - MethodCall 받음: \(call.method)")
            guard call.method == "setListData" else {
                print("❌ NativeListViewFactory - 알 수 없는 메서드: \(call.method)")
                result(FlutterMethodNotImplemented)
                return
            }
            
            if let args = call.arguments as? [String: Any],
               let titles = args["titles"] as? [String] {
                print("🍎 NativeListViewFactory - 데이터 수신 성공, 항목 수: \(titles.count)")
                NativeListViewFactory.listData = titles
                result(nil)
                print("🍎 NativeListViewFactory - 결과 반환 완료")
            } else {
                print("❌ NativeListViewFactory - 잘못된 인자")
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        }
        print("🍎 NativeListViewFactory - 초기화 완료")
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        print("🍎 NativeListViewFactory - create 호출, frame: \(frame), viewId: \(viewId)")
        print("🍎 NativeListViewFactory - 현재 데이터 수: \(NativeListViewFactory.listData.count)")
        return NativeListView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            messenger: messenger,
            data: NativeListViewFactory.listData
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        print("🍎 NativeListViewFactory - createArgsCodec 호출")
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
