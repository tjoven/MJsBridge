package com.filez.ldjsbridge.library;

import android.content.Context;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonPrimitive;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

public class LDJsBridgeUtils {

    //////////////////////////常量//////////////////////////

    /*
     * 执行JS方法的命令
     * */
    public final static String CALL_JS_FROM_ANDROID_COMMEND = "javascript:LDJsBridge._handleMessageFromAndroid('%s');";

    /*
     * 执行JS方法的命令
     * */
    public final static String CALL_JS_ADD_NODE_COMMEND = "javascript:LDJsBridge._addJsHybridNote('%s');";

    /*
     * 本地JS文件的名称
     * */
    public final static String LCOAL_INJECT_JAVASCRIPT_NAME = "LDJsBridge.js";

    /*
     * callback的唯一ID
     * */
    public final static String CALLBACK_ID_FORMAT = "JAVA_CB_%s";

    /*
     * js命令最大的长度
     * */
    public final static int URL_MAX_CHARACTER_NUM = 2097152;

    //////////////////////////公共方法//////////////////////////

    /*
     * 把Assets的文件内容转换成字符串
     * */
    public static String assetFile2Str(Context context, String filePath) {
        InputStream in = null;
        try {
            in = context.getAssets().open(filePath);
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(in));
            String line = null;
            StringBuilder sb = new StringBuilder();
            do {
                line = bufferedReader.readLine();
                if (line != null && !line.matches("^\\s*\\/\\/.*")) { // 去除注释
                    sb.append(line);
                }
            } while (line != null);

            bufferedReader.close();
            in.close();

            return sb.toString();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (in != null) {
                try {
                    in.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }

    /*
     * 得到一个唯一数
     * */
    public static String getUUID() {
        return UUID.randomUUID().toString();
    }

    /*
     * json转换成Map
     * */
    public static Map<String, Object> json2Map(String jsonString) {
        JsonParser parser = new JsonParser();
        JsonObject jsonObj = parser.parse(jsonString).getAsJsonObject();
        return json2Map(jsonObj);
    }

    /*
     * json对象转换成Map
     * */
    public static Map<String, Object> json2Map(JsonObject jsonObject) {
        Map<String, Object> map = new HashMap<String, Object>();
        Set<Map.Entry<String, JsonElement>> entrySet = jsonObject.entrySet();
        for (Iterator<Map.Entry<String, JsonElement>> iter = entrySet.iterator(); iter.hasNext(); ) {
            Map.Entry<String, JsonElement> entry = iter.next();
            String key = entry.getKey();
            Object value = entry.getValue();
            if (value instanceof JsonArray) {
                List array = json2List((JsonArray) value);
                map.put((String) key, new Gson().toJson(array));
            } else if (value instanceof JsonObject) {
                Map tmpMap = json2Map((JsonObject) value);
                map.put((String) key, new Gson().toJson(tmpMap));
            } else {
                if (value instanceof JsonPrimitive){
                    map.put((String) key, ((JsonPrimitive) value).getAsString());
                }
            }
        }
        return map;
    }

    /*
     * jsonObject转换成List
     * */
    public static List<Object> json2List(JsonArray jsonArray) {
        List<Object> list = new ArrayList<Object>();
        for (int i = 0; i < jsonArray.size(); i++) {
            Object value = jsonArray.get(i);
            if (value instanceof JsonArray) {
                list.add(json2List((JsonArray) value));
            } else if (value instanceof JsonObject) {
                list.add(json2Map((JsonObject) value));
            } else {
                list.add(value);
            }
        }
        return list;
    }

}
