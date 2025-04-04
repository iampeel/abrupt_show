// Flutter 측 구현 (main.dart)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'board_titles.dart'; // 기존 데이터 import

void main() {
  debugPrint('🔍 앱 시작');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 MyApp 빌드');
    return MaterialApp(
      title: '네이티브 리스트뷰 데모',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NativeListScreen(),
    );
  }
}

class NativeListScreen extends StatefulWidget {
  const NativeListScreen({super.key});

  @override
  State<NativeListScreen> createState() {
    debugPrint('🔍 NativeListScreen createState');
    return _NativeListScreenState();
  }
}

class _NativeListScreenState extends State<NativeListScreen> {
  // Method Channel 설정
  static const platform = MethodChannel('com.example.app/native_list');
  bool _isNativeViewReady = false;

  @override
  void initState() {
    debugPrint('🔍 initState 호출');
    super.initState();

    // 플랫폼 채널 핸들러 설정
    debugPrint('🔍 setMethodCallHandler 설정 시작');
    platform.setMethodCallHandler(_handleItemClick);
    debugPrint('🔍 setMethodCallHandler 설정 완료');

    // 지연 추가
    debugPrint('🔍 지연 타이머 설정 (100ms)');
    Future.delayed(const Duration(milliseconds: 100), () {
      debugPrint('🔍 지연 후 _initNativeList 호출');
      _initNativeList();
    });
  }

  @override
  void dispose() {
    debugPrint('🔍 dispose 호출');
    platform.setMethodCallHandler(null);
    super.dispose();
  }

  // 네이티브 리스트뷰 초기화 및 데이터 전달
  Future<void> _initNativeList() async {
    debugPrint('🔍 _initNativeList 시작');
    try {
      debugPrint('🔍 platform.invokeMethod 호출 시작');
      debugPrint('🔍 전달할 데이터 크기: ${BoardData.titles.length}');
      final result = await platform.invokeMethod('setListData', {
        'titles': BoardData.titles,
      });
      debugPrint('🔍 platform.invokeMethod 호출 완료, 결과: $result');

      setState(() {
        debugPrint('🔍 _isNativeViewReady = true로 설정');
        _isNativeViewReady = true;
      });
    } on PlatformException catch (e) {
      debugPrint('❌ 네이티브 통신 오류: ${e.message}');
      debugPrint('❌ 오류 세부 정보: ${e.details}');
      debugPrint('❌ 오류 코드: ${e.code}');
    } catch (e) {
      debugPrint('❌ 예상치 못한 오류 발생: $e');
    }
  }

  // 항목 클릭 처리 콜백
  Future<void> _handleItemClick(MethodCall call) async {
    debugPrint('🔍 _handleItemClick 호출됨: ${call.method}');
    if (call.method == 'onItemClick') {
      debugPrint('🔍 onItemClick 처리 중, 인자: ${call.arguments}');
      final int index = call.arguments['index'];
      if (mounted) {
        debugPrint('🔍 Snackbar 표시: index=$index');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('선택: ${BoardData.titles[index]}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      debugPrint('❌ 알 수 없는 메서드 호출: ${call.method}');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 build 메서드 호출, _isNativeViewReady: $_isNativeViewReady');

    return Scaffold(
      appBar: AppBar(
        title: const Text('네이티브 리스트뷰'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // 디버깅용 버튼 추가
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              debugPrint('🔍 수동 새로고침 버튼 클릭');
              _initNativeList();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isNativeViewReady) _buildNativeListView(),
          if (!_isNativeViewReady)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('네이티브 뷰 로딩 중...'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 플랫폼별 네이티브 뷰 생성
  Widget _buildNativeListView() {
    debugPrint(
      '🔍 _buildNativeListView 호출, 플랫폼: ${Theme.of(context).platform}',
    );

    // 안드로이드인 경우
    if (Theme.of(context).platform == TargetPlatform.android) {
      debugPrint('🔍 Android 네이티브 뷰 생성');
      return SizedBox(
        height: MediaQuery.of(context).size.height - 100, // AppBar 고려
        child: const AndroidView(
          viewType: 'native-list-view',
          creationParams: <String, dynamic>{},
          creationParamsCodec: StandardMessageCodec(),
        ),
      );
    }
    // iOS인 경우
    else {
      debugPrint('🔍 iOS 네이티브 뷰 생성');
      return SizedBox(
        height: MediaQuery.of(context).size.height - 100, // AppBar 고려
        child: const UiKitView(
          viewType: 'native-list-view',
          creationParams: <String, dynamic>{},
          creationParamsCodec: StandardMessageCodec(),
        ),
      );
    }
  }
}
