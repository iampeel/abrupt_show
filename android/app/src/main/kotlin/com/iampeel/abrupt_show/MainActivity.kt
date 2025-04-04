// Android 측 구현

// 1. MainActivity.java에 추가 (또는 플러그인 등록 클래스)
package com.example.yourapp;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.app/native_list";
    private MethodChannel channel;
    private List<String> listData = new ArrayList<>();

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        // 네이티브 뷰 등록
        flutterEngine.getPlatformViewsController()
                .getRegistry()
                .registerViewFactory("native-list-view", new NativeListViewFactory(this, flutterEngine.getDartExecutor().getBinaryMessenger()));

        // Method Channel 설정
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("setListData")) {
                    // Flutter에서 보낸 데이터 받기
                    listData = call.argument("titles");
                    NativeListViewFactory.updateData(listData);
                    result.success(null);
                } else {
                    result.notImplemented();
                }
            }
        );
    }
}

// 2. NativeListViewFactory.java
package com.example.yourapp;

import android.content.Context;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.List;
import java.util.ArrayList;

public class NativeListViewFactory extends PlatformViewFactory {
    private final Context context;
    private final BinaryMessenger messenger;
    private static List<String> listData = new ArrayList<>();
    private static MethodChannel channel;
    
    public NativeListViewFactory(Context context, BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.context = context;
        this.messenger = messenger;
        channel = new MethodChannel(messenger, "com.example.app/native_list");
    }
    
    public static void updateData(List<String> data) {
        listData = data;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        return new NativeListView(context, viewId, messenger, listData);
    }
}

// 3. NativeListView.java
package com.example.yourapp;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NativeListView implements PlatformView {
    private final RecyclerView recyclerView;
    private final ListAdapter adapter;
    private final MethodChannel channel;
    private final Context context;
    
    public NativeListView(Context context, int id, BinaryMessenger messenger, List<String> data) {
        this.context = context;
        this.channel = new MethodChannel(messenger, "com.example.app/native_list");
        
        // RecyclerView 설정
        recyclerView = new RecyclerView(context);
        recyclerView.setLayoutManager(new LinearLayoutManager(context));
        adapter = new ListAdapter(data, position -> {
            // 항목 클릭 이벤트를 Flutter로 전달
            Map<String, Object> args = new HashMap<>();
            args.put("index", position);
            channel.invokeMethod("onItemClick", args);
        });
        recyclerView.setAdapter(adapter);
    }

    @Override
    public View getView() {
        return recyclerView;
    }

    @Override
    public void dispose() {
        // 리소스 정리
    }
    
    // RecyclerView용 어댑터
    private static class ListAdapter extends RecyclerView.Adapter<ListAdapter.ViewHolder> {
        private final List<String> data;
        private final OnItemClickListener listener;
        
        interface OnItemClickListener {
            void onItemClick(int position);
        }
        
        ListAdapter(List<String> data, OnItemClickListener listener) {
            this.data = data;
            this.listener = listener;
        }
        
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            TextView textView = new TextView(parent.getContext());
            textView.setPadding(30, 30, 30, 30);
            textView.setTextSize(16);
            return new ViewHolder(textView);
        }
        
        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            holder.textView.setText(data.get(position));
            holder.textView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onItemClick(position);
                }
            });
        }
        
        @Override
        public int getItemCount() {
            return data.size();
        }
        
        static class ViewHolder extends RecyclerView.ViewHolder {
            final TextView textView;
            
            ViewHolder(TextView textView) {
                super(textView);
                this.textView = textView;
            }
        }
    }
}