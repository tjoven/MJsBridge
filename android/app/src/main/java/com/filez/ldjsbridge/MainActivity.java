package com.filez.ldjsbridge;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.Toast;

import com.filez.ldjsbridge.library.LDJsBridge;
import com.filez.ldjsbridge.library.LDJsBridgeCore;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    //////////////////////////属性//////////////////////////

    /*
     * webView
     * */
    private WebView webView;

    /*
     * 调用JS的按钮
     * */
    private Button callJsButton;

    /*
     * jsBridge
     * */
    private LDJsBridge jsBridge;


    //////////////////////////生命周期//////////////////////////

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        //webview
        webView = findViewById(R.id.webView);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true);
        }
        //button
        callJsButton = findViewById(R.id.button);
        callJsButton.setOnClickListener(this);

        //bridge
        jsBridge = new LDJsBridge(webView);
        jsBridge.addJavascriptHandler(new LDWebViewJsTestHandler(this.getApplicationContext()), "android_filez");
        jsBridge.addJavascriptHandler(new LDWebViewJsTest1Handler(this.getApplicationContext()), "android_filez_1");
        //加载网页
//        webView.loadUrl("file:///android_asset/Demo.html");
        webView.loadUrl("file:///android_asset/Demo.html");
    }

    //////////////////////////OnClickListener//////////////////////////

    @Override
    public void onClick(View v) {
        //按钮点击

        this.jsBridge.callJavascript("callFromAndroid", "来自原生的数据", new LDJsBridgeCore.OnJsResponseListener() {
            @Override
            public void onJsResponse(String responseData) {
                Log.d("from JS", responseData);
                Toast.makeText(MainActivity.this,"responseData :"+responseData,Toast.LENGTH_LONG).show();
            }
        });

    }
}
