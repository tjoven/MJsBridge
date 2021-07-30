//filez_app.js
;(function(undefined) {
    "use strict"
    var _global;

    //返回结果
    function FilezResponse(res) {
        this._initial(res);
    }

    FilezResponse.prototype = {
        //初始化
        constructor: this,
        _initial: function(res){
            var isJson = this.isJsonString(res);
            this.isStandardRes = false;
            if(isJson){
                var resObj = JSON.parse(res);
                this.code = resObj.code;
                this.message = resObj.message;
                this.errorCode = resObj.errorCode;
                this.isStandardRes = true;
            }
            this.resStr = res;
            if(this.isStandardRes){
                this.isSuccess = this.code == '200';
            }else{
                this.isSuccess = true;
            }
        },
        //是不是Json字符串
        isJsonString: function(str){
            if (typeof str == 'string') {
                try {
                    JSON.parse(str);
                    return true;
                } catch(e) {
                    console.log(e);
                    return false;
                }
            }
            return false;
        }
    }

    //插件的构造函数
    function Filez(opt){
        this._initial(opt);
    }

    Filez.prototype = {
        //初始化
        constructor: this,
        _initial: function(opt){
            var def = {
                logEnale : false,
                platform : 'other'
            };
            this.def = Object.assign(def, opt);
        },
        //platform: ios android other
        init: function(platform, initCallBack) {
            if(window.LDJsBridge){
                return;
            }
            this.def.platform = platform;
            this.initFilezCallBack = initCallBack;
            if(this.def.platform == 'ios'){
                window.webkit.messageHandlers.iOS_Native_InjectJavascript.postMessage(null)
            }else if(this.def.platform == 'android'){
                android.injectJavascript("");
            }
        },
        //注册一个JS方法，供OC调用
        //handlerName方法的名称
        //handler处理方法，function(data, responseCallback)
        registerHandler: function(handlerName, handler) {
            if(!window.LDJsBridge){
                return;
            }
            window.LDJsBridge.registerHandler(handlerName, handler);
        },
        //调用app原生方法
        //handlerName:方法的名称
        //params:参数
        //responseCallback:回调方法
        callHandler: function(handlerName, params, responseCallback) {
            if(!window.LDJsBridge){
                return;
            }
            window.LDJsBridge.callHandler(handlerName, params, function(response){
                var filezRes = new FilezResponse(response);
                if(responseCallback){
                    responseCallback(filezRes);
                }
            });
        }
    }

    // interaction
    Filez.prototype.showToast = function(opt, callback){
        var def = {
                     title : "",
                     duration : 1500
                 }
        var data = Object.assign(def, opt);
        this.callHandler('showToast', data, function (response) {
            var filezRes = new FilezResponse(response);
            if(callback){
                callback(filezRes.isSuccess, filezRes);
            }
        })
    }

    var filez = new Filez({
        log : false,
        platform : 'other'
    });

    //最后将插件对象暴露给全局对象
    _global = (function(){return this || (0, eval)('this');}());
    if(typeof module !=="undefined" && module.exports) {
        module.exports = filez;
    } else if(typeof define === "function" && define.amd) {
        define(function(){return filez;});
    } else {
        !('filez' in _global) && (_global.filez = filez);
    }
}())
