package com.filez.ldjsbridge.library;

import android.util.Log;
import android.webkit.JavascriptInterface;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class LDJsBridgeCoreJsHandler extends LDJsBridge.JsHandler {

    //////////////////////////常量//////////////////////////

    /*
     * js交互用的名称
     * */
    public final static String JS_INTERFACE_NAME = "android";

    //////////////////////////JS方法//////////////////////////

    @JavascriptInterface
    public void injectJavascript(String data) {
        Log.d(TAG,"injectJavascript: "+data);
        if (this.getInternalBridgeCore() == null){
            return;
        }
        this.getInternalBridgeCore().injectJavascriptFile();
    }

    @JavascriptInterface
    public void response(String responseJsonString) {
        Log.d(TAG,"response: "+responseJsonString);
        if (this.getInternalBridgeCore() == null){
            return;
        }
        this.getInternalBridgeCore().handleJsCallBack(responseJsonString);
    }

    @JavascriptInterface
    public String getHandlerNames(String responseJsonString) {
        Log.d(TAG,"getHandlerNames: "+responseJsonString);
        return new Gson().toJson(this.getInternalBridgeCore().getJsInterfaceNameList());
    }

}
