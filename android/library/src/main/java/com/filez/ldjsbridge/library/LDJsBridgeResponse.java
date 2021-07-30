package com.filez.ldjsbridge.library;

import com.google.gson.Gson;

import java.util.Map;

public class LDJsBridgeResponse {

    //////////////////////////变量//////////////////////////

    /*
     * 状态码
     * */
    private String code;

    /*
     * 消息
     * */
    private String message;

    /*
     * 错误代码
     * */
    private String errorCode;

    /**
     * 返回的内容字典
     */
    private Map<String, Object> content;

    //////////////////////////Setter Getter//////////////////////////

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public Map<String, Object> getContent() {
        return content;
    }

    public void setContent(Map<String, Object> content) {
        this.content = content;
    }

    //////////////////////////公共方法//////////////////////////

    /*
     * 返回转换的Json字符串
     * */
    public String response2JsonStr(){
        return new Gson().toJson(this);
    }

}
