package com.filez.ldjsbridge.library;

import android.text.TextUtils;

import com.google.gson.Gson;

import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

public class LDJsBridgeMessage {

    //////////////////////////属性//////////////////////////

    /*
     * 参数
     * */
    private String data;

    /*
     * 回调的ID
     * */
    private String callbackId;

    /*
     * 响应的ID
     * */
    private String responseId;

    /*
     * 响应的参数
     * */
    private String responseData;

    /*
     * 方法的名称
     * */
    private String handlerName;

    //////////////////////////Setter and Getter//////////////////////////

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public String getCallbackId() {
        return callbackId;
    }

    public void setCallbackId(String callbackId) {
        this.callbackId = callbackId;
    }

    public String getResponseId() {
        return responseId;
    }

    public void setResponseId(String responseId) {
        this.responseId = responseId;
    }

    public String getResponseData() {
        return responseData;
    }

    public void setResponseData(String responseData) {
        this.responseData = responseData;
    }

    public String getHandlerName() {
        return handlerName;
    }

    public void setHandlerName(String handlerName) {
        this.handlerName = handlerName;
    }

    //////////////////////////构造函数//////////////////////////

    /*
     * 构造函数
     * */
    public LDJsBridgeMessage() {
        super();
    }

    /*
     * 构造函数，通过js回调回来的Json
     * */
    public LDJsBridgeMessage(String responseJsonString) {
        super();
        if (!TextUtils.isEmpty(responseJsonString)) {
            Map<String, Object> messageMap = LDJsBridgeUtils.json2Map(responseJsonString);
            if (messageMap.containsKey("callbackID")) {
                this.callbackId = (String) messageMap.get("callbackID");
            }
            if (messageMap.containsKey("data")) {
                this.data = (String) messageMap.get("data");
            }
            if (messageMap.containsKey("responseID")) {
                this.responseId = (String) messageMap.get("responseID");
            }
            if (messageMap.containsKey("responseData")) {
                this.responseData = (String) messageMap.get("responseData");
            }
            if (messageMap.containsKey("handlerName")) {
                this.handlerName = (String) messageMap.get("handlerName");
            }
        }
    }

    //////////////////////////公共方法//////////////////////////

    /*
     * 返回json字符串
     * */
    public String getJsonString() {
        Map jsonMap = new HashMap();
        if (this.data != null) {
            jsonMap.put("data", this.getData());
        }

        if (this.callbackId != null) {
            jsonMap.put("callbackID", this.getCallbackId());
        }

        if (this.handlerName != null) {
            jsonMap.put("handlerName", this.getHandlerName());
        }

        if (this.responseId != null) {
            jsonMap.put("responseID", this.getResponseId());
        }

        if (this.responseData != null) {
            jsonMap.put("responseData", this.getResponseData());
        }

        if (this.data != null) {
            jsonMap.put("data", this.getData());
        }

        String jsonString = new Gson().toJson(jsonMap);
        return jsonString;
    }

    /*
     * 获取请求JS代码的JS命令字符串
     * */
    public String getCallJsCommend() {
        String messageJson = this.getJsonString();
        //escape special characters for json string  为json字符串转义特殊字符
        messageJson = messageJson.replaceAll("(\\\\)([^utrn])", "\\\\\\\\$1$2");
        messageJson = messageJson.replaceAll("(?<=[^\\\\])(\")", "\\\\\"");
        messageJson = messageJson.replaceAll("(?<=[^\\\\])(\')", "\\\\\'");
        messageJson = messageJson.replaceAll("%7B", URLEncoder.encode("%7B"));
        messageJson = messageJson.replaceAll("%7D", URLEncoder.encode("%7D"));
        messageJson = messageJson.replaceAll("%22", URLEncoder.encode("%22"));

        String javascriptCommand = String.format(LDJsBridgeUtils.CALL_JS_FROM_ANDROID_COMMEND, messageJson);
        return javascriptCommand;
    }

}
