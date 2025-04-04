import Flutter
import UIKit

class NativeListView: NSObject, FlutterPlatformView, UITableViewDelegate, UITableViewDataSource {
    private let frame: CGRect
    private let viewId: Int64
    private let tableView: UITableView
    private let channel: FlutterMethodChannel
    private let data: [String]
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger,
        data: [String]
    ) {
        print("🍎 NativeListView - 초기화 시작, frame: \(frame), viewId: \(viewId), 데이터 수: \(data.count)")
        self.frame = frame
        self.viewId = viewId
        self.data = data
        self.tableView = UITableView(frame: frame)
        self.channel = FlutterMethodChannel(name: "com.example.app/native_list", binaryMessenger: messenger)
        
        super.init()
        
        // TableView 설정
        print("🍎 NativeListView - TableView 설정")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        print("🍎 NativeListView - 초기화 완료")
    }
    
    func view() -> UIView {
        print("🍎 NativeListView - view() 호출, 데이터 수: \(data.count)")
        return tableView
    }
    
    // UITableViewDataSource 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("🍎 NativeListView - numberOfRowsInSection 호출: \(data.count)")
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🍎 NativeListView - cellForRowAt: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    // UITableViewDelegate 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("🍎 NativeListView - didSelectRowAt: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 클릭 이벤트를 Flutter로 전달
        print("🍎 NativeListView - Flutter에 클릭 이벤트 전달")
        channel.invokeMethod("onItemClick", arguments: ["index": indexPath.row])
    }
}
