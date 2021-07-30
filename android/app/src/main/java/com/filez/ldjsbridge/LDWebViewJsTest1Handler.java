package com.filez.ldjsbridge;

import android.content.Context;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.widget.Toast;

import com.filez.ldjsbridge.library.LDJsBridge;
import com.filez.ldjsbridge.library.LDJsBridgeMessage;
import com.filez.ldjsbridge.library.LDJsBridgeResponse;
import com.filez.ldjsbridge.library.LDJsBridgeUtils;

import java.util.Map;

public class LDWebViewJsTest1Handler extends LDJsBridge.JsHandler {
    /*
     * 上下文
     * */
    private Context mContext;

    public LDWebViewJsTest1Handler() {
        super();
    }

    public LDWebViewJsTest1Handler(Context mContext) {
        this.mContext = mContext;
    }

    @JavascriptInterface
    public void callFromJs(String json){
        LDJsBridgeMessage message = new LDJsBridgeMessage(json);
        Log.d("jsData", message.getData());
        if(this.mContext == null){
            //失败
            LDJsBridgeResponse response = new LDJsBridgeResponse();
            response.setCode("300");
            response.setErrorCode("native_error");
            response.setMessage("显示toast失败");
            this.sendJsResponse(response.response2JsonStr(), message.getCallbackId());
        }else {
            String dataStr = message.getData();
            Map dataMap = LDJsBridgeUtils.json2Map(dataStr);
            Toast.makeText(mContext, (String)dataMap.get("title"), Toast.LENGTH_SHORT).show();
            this.sendJsResponse("来自原生", message.getCallbackId());
        }
    }
}
