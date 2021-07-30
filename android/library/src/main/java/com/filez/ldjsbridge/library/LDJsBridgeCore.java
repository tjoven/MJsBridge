package com.filez.ldjsbridge.library;

import android.text.TextUtils;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
 * JSBridge的核心类
 * */
public class LDJsBridgeCore {
    private static final String TAG = "LDJsBridgeCore";
    //////////////////////////属性//////////////////////////

    /*
     * 回调*/
    private OnJsBridgeListener jsBridgeListener;

    /*
     * 消息的队列
     * */
    private List<LDJsBridgeMessage> startupMessageQueue;

    /*
     * JS回调处理方法的Map
     * */
    private Map<String, OnJsResponseListener> responseCallbacks;

    /*
     * 添加的节点的数组
     * */
    private List<String> jsInterfaceNameList;

    /**
     * 是不是已经注入JS了
     */
    private boolean JavascriptInjected = false;

    //////////////////////////Setter//////////////////////////

    public void setJsBridgeListener(OnJsBridgeListener jsBridgeListener) {
        this.jsBridgeListener = jsBridgeListener;
    }

    //////////////////////////Getter//////////////////////////

    public List<String> getJsInterfaceNameList() {
        return jsInterfaceNameList;
    }

    //////////////////////////公开的接口//////////////////////////

    /*
     * JS处理的接口
     * */
    public static interface OnJsBridgeListener {

        /*
         * 执行JS脚本
         * */
        void evaluateJavascript(String javascript);

        /*
         * 加载JS
         * */
        void loadJavascript(String javascript);

        /*
         * 加载Assets里面的js文件
         * */
        void loadLocalJavascriptFromAssets(String jsFileName);
    }

    /*
     * JS回调的方法
     * */
    public static interface OnJsResponseListener {

        /*
         * JS回调方法执行
         * */
        void onJsResponse(String responseData);
    }

    //////////////////////////构造方法//////////////////////////

    /*
    * 构造函数
    * */
    public LDJsBridgeCore() {
        super();
        init();
    }

    //////////////////////////公共方法//////////////////////////

    /*
     * 重置
     * */
    public void reset() {
        this.startupMessageQueue.clear();
        this.responseCallbacks.clear();
    }

    /*
     * 添加JS name
     * */
    public void registerJsInterfaceName(String name){
        if (TextUtils.isEmpty(name)){
            return;
        }

        if (this.jsInterfaceNameList.contains(name)){
            return;
        }

        this.jsInterfaceNameList.add(name);
    }

    /*
     * 发送到JS
     * */
    public void send(String data, String handlerName, OnJsResponseListener onJsResponseListener) {
        LDJsBridgeMessage message = new LDJsBridgeMessage();
        if (data != null) {
            message.setData(data);
        }

        if (onJsResponseListener != null) {
            String callBackID = String.format(LDJsBridgeUtils.CALLBACK_ID_FORMAT, LDJsBridgeUtils.getUUID());
            this.responseCallbacks.put(callBackID, onJsResponseListener);
            message.setCallbackId(callBackID);
        }

        if (!TextUtils.isEmpty(handlerName)) {
            message.setHandlerName(handlerName);
        }

        //发送
        this.addToQueueWithMessage(message);
    }

    /*
     * 注入JS代码
     * */
    public void injectJavascriptFile() {
        Log.d(TAG,"injectJavascript: ");
        Log.d(TAG,"injectJavascript_startupMessageQueue："+startupMessageQueue);
        //注入Js文件
        this.loadLocalJavascriptFromAssets(LDJsBridgeUtils.LCOAL_INJECT_JAVASCRIPT_NAME);

        if (this.startupMessageQueue == null) {
            return;
        }
        Log.d(TAG,"injectJavascript：dispatchMessage pre");
        // 遍历所有没有发送出去的消息
        for (LDJsBridgeMessage message : this.startupMessageQueue) {
            Log.d(TAG,"injectJavascript: message");
            dispatchMessage(message);
        }
        this.startupMessageQueue = null;
    }

    /*
     * 处理JS回调回来的方法
     * */
    public void handleJsCallBack(String responseJsonString){
        LDJsBridgeMessage message = new LDJsBridgeMessage(responseJsonString);
        String responseId = message.getResponseId();
        if(!TextUtils.isEmpty(responseId)){
            OnJsResponseListener jsCallBack = responseCallbacks.remove(responseId);
            if (jsCallBack != null) {
                jsCallBack.onJsResponse(message.getResponseData());
            }
        }
    }

    /*
     * 返回给JS调用的回调
     * */
    public void sendJsResponse(String data, String responseId){
        if(TextUtils.isEmpty(data) || TextUtils.isEmpty(responseId)){
            return;
        }
        LDJsBridgeMessage resMessage = new LDJsBridgeMessage();
        resMessage.setResponseId(responseId);
        resMessage.setResponseData(data);

        this.addToQueueWithMessage(resMessage);
    }

    //////////////////////////私有方法//////////////////////////

    /*
     * 初始化
     * */
    private void init() {
        this.startupMessageQueue = new ArrayList<LDJsBridgeMessage>();
        this.responseCallbacks = new HashMap<String, OnJsResponseListener>();
        this.jsInterfaceNameList = new ArrayList<String>();
    }

    /*
     * 添加到队列，如果没有队列，直接发送
     * */
    private void addToQueueWithMessage(LDJsBridgeMessage message) {
        if (this.startupMessageQueue == null) {
            dispatchMessage(message);
        } else {
            this.startupMessageQueue.add(message);
        }
    }

    /*
     * 发送一个命令
     * */
    private void dispatchMessage(LDJsBridgeMessage message) {
        Log.d(TAG,"dispatchMessage: ");
        //js命令
        String jsCommend = message.getCallJsCommend();
        this.evaluateJavascript(jsCommend);
    }

    /*
     * 执行一个JS命令
     * */
    private void evaluateJavascript(String jsCommend) {
        if (this.jsBridgeListener == null || jsCommend == null || jsCommend.length() == 0) {
            return;
        }
        this.jsBridgeListener.evaluateJavascript(jsCommend);
    }

    /*
     * loadJS
     * */
    private void loadUrl(String jsCommend) {
        if (this.jsBridgeListener == null || jsCommend == null || jsCommend.length() == 0) {
            return;
        }
        this.jsBridgeListener.loadJavascript(jsCommend);
    }

    /*
     * 加载js文件
     * */
    private void loadLocalJavascriptFromAssets(String jsFilePath) {
        if (this.jsBridgeListener == null || jsFilePath == null || jsFilePath.length() == 0) {
            return;
        }
        this.jsBridgeListener.loadLocalJavascriptFromAssets(jsFilePath);
    }

}
