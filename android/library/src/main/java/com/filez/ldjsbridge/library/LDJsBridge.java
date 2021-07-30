package com.filez.ldjsbridge.library;

import android.os.Build;
import android.os.Looper;
import android.webkit.JavascriptInterface;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.google.gson.Gson;

public class LDJsBridge implements LDJsBridgeCore.OnJsBridgeListener {

    /*
     * webView实例
     * */
    private WebView webView;

    /*
     * 核心实例
     * */
    private LDJsBridgeCore core;

    /**
     * 基础JSHander
     */
    private LDJsBridgeCoreJsHandler coreJsHandler;

    //////////////////////////构造函数//////////////////////////

    /*
     * 构造函数
     * */
    public LDJsBridge(WebView webView) {
        super();
        this.webView = webView;
        init();
    }

    //////////////////////////公开的接口//////////////////////////

    /*
     * JS处理的基础类
     * */
    public static abstract class JsHandler {
        protected static final String TAG = "JsHandler";

        /*
         * bridge
         * */
        private LDJsBridgeCore internalBridgeCore;

        //////////////////////////Setter//////////////////////////

        protected void setInternalBridgeCore(LDJsBridgeCore internalBridgeCore) {
            this.internalBridgeCore = internalBridgeCore;
        }

        protected LDJsBridgeCore getInternalBridgeCore() {
            return internalBridgeCore;
        }

        //////////////////////////公共方法//////////////////////////

        /*
         * 发送给JS调用的回调,js调用原生如果有回调的话，需要手动调用一下这个方法
         * */
        protected void sendJsResponse(String data, String responseId){
            if (this.internalBridgeCore == null){
                return;
            }
            this.internalBridgeCore.sendJsResponse(data, responseId);
        }

        //////////////////////////JS方法//////////////////////////

        /*
         * 初始化时候调用注入JS脚本
         * */
        @JavascriptInterface
        public void send(String data){ }
    }

    //////////////////////////公共方法//////////////////////////

    /*
     * 设置是不是可以调试
     * */
    public void setWebContentsDebuggingEnabled(Boolean debugEnable){
        if (this.webView == null){
            return;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && BuildConfig.DEBUG) {
            WebView.setWebContentsDebuggingEnabled(debugEnable);
        }
    }

    /*
     * 重置
     * */
    public void reset(){
        this.core.reset();
    }

    /*
     * 请求一个JS方法
     * */
    public void callJavascript(String handlerName, Object data, LDJsBridgeCore.OnJsResponseListener jsResponseListener){
        String dataJson = new Gson().toJson(data);
        this.core.send(dataJson, handlerName, jsResponseListener);
    }

    /*
     * 请求一个JS方法
     * */
    public void callJavascript(String handlerName, String data, LDJsBridgeCore.OnJsResponseListener jsResponseListener){
        this.core.send(data, handlerName, jsResponseListener);
    }

    /*
     * 添加一个JS交互的处理
     * */
    public void addJavascriptHandler(JsHandler jsHandler, String interfaceName){
        if(jsHandler == null || this.webView == null){
            return;
        }
        jsHandler.setInternalBridgeCore(this.core);
        this.core.registerJsInterfaceName(interfaceName);
        this.webView.addJavascriptInterface(jsHandler, interfaceName);
    }

    //////////////////////////私有方法//////////////////////////

    /*
     * 初始方法
     * */
    private void init(){
        //设置webView
        WebSettings webSettings = this.webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setUseWideViewPort(true);
        webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webSettings.setDefaultTextEncodingName("utf-8");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && BuildConfig.DEBUG) {
            WebView.setWebContentsDebuggingEnabled(true);
        }

        this.core = new LDJsBridgeCore();
        this.core.setJsBridgeListener(this);
        this.coreJsHandler = new LDJsBridgeCoreJsHandler();

        this.addJavascriptHandler(this.coreJsHandler, LDJsBridgeCoreJsHandler.JS_INTERFACE_NAME);
    }

    /*
     * 执行JS方法
     * */
    private void autoEvaluateJavascript(final String javascript){
        // 必须要找主线程才会将数据传递出去 --- 划重点
        if (Thread.currentThread() == Looper.getMainLooper().getThread()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && javascript.length() >= LDJsBridgeUtils.URL_MAX_CHARACTER_NUM) {
                this.webView.evaluateJavascript(javascript, null);
            } else {
                this.webView.loadUrl(javascript);
            }
        } else {
            final LDJsBridge self = this;
            this.webView.post(new Runnable() {
                @Override
                public void run() {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && javascript.length() >= LDJsBridgeUtils.URL_MAX_CHARACTER_NUM) {
                        self.webView.evaluateJavascript(javascript, null);
                    } else {
                        self.webView.loadUrl(javascript);
                    }
                }
            });
        }
    }

    //////////////////////////OnJsBridgeListener//////////////////////////

    @Override
    public void evaluateJavascript(String javascript) {
        if (this.webView == null){
            return;
        }
        this.autoEvaluateJavascript(javascript);
    }

    @Override
    public void loadJavascript(String javascript) {
        if (this.webView == null){
            return;
        }
        this.webView.loadUrl(javascript);
    }

    @Override
    public void loadLocalJavascriptFromAssets(String jsFileName) {
        final String jsContent = LDJsBridgeUtils.assetFile2Str(this.webView.getContext(), jsFileName);
        final WebView targetWebView = this.webView;
        this.webView.post(new Runnable() {
            @Override
            public void run() {
                targetWebView.loadUrl("javascript:" + jsContent);
            }
        });
    }

}
