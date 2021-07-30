//filez_app.js
;(function(undefined) {
    "use strict"
    var _global;

    // 一些常量
    var FilezConstants = {
        PlatformIOS: "ios",
        PlatformAndroid: "android",
        PlatformAuto: "auto",
        PlatformOther: "other"
    }

    //常用的错误码
    var FilezErrorCodeConstants = {
        FilezErrorCodeSuccess: "100200",
        FilezErrorCodeFailed: "100500",
        FilezErrorCodeUserAction: "100300"
    }
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
                this.content = resObj.content;
                this.isStandardRes = true;
            }
            this.resStr = res;
            if(this.isStandardRes){
                this.isSuccess = this.code == FilezErrorCodeConstants.FilezErrorCodeSuccess;
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
        canUse: false,  //是不是可以使用
        _initial: function(opt){
            var def = {
                logEnale : false,
                platform : 'other'
            };
            this.def = Object.assign(def, opt);
        },
        //platform: ios android other
        init: function(platform, initCallBack) {
            if (window.LDJsBridge) {
                this.canUse = true;
                return;
            }
            this.def.platform = this.correctPlatform(platform);
            this.initFilezCallBack = initCallBack;
            if (this.def.platform == 'ios') {
                window.webkit.messageHandlers.iOS_Native_InjectJavascript.postMessage(null);
                this.canUse = true;
            } else if (this.def.platform == 'android') {
                android.injectJavascript("");
                this.canUse = true;
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
        },
        // 自动纠正一下传入的平台
        // 初始化传入的平台类型
        correctPlatform: function (platform) {
            if (platform == FilezConstants.PlatformIOS) {
                //ios
                return FilezConstants.PlatformIOS;
            }
            if (platform == FilezConstants.PlatformAndroid) {
                //android
                return FilezConstants.PlatformAndroid;
            }
            if (platform == FilezConstants.PlatformAuto) {
                //自动识别
                var u = navigator.userAgent;
                var isIOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
                var isAndroid = u.indexOf('Android') > -1 || u.indexOf('Adr') > -1;
                if (isIOS) {
                    return FilezConstants.PlatformIOS;
                } else if (isAndroid) {
                    return FilezConstants.PlatformAndroid;
                }
            }
            return FilezConstants.PlatformOther;
        }
    }
  // 系统相关

  // 获取系统的信息
  // 不需要传参数
  // 返回结果：
  // brand：设备品牌
  // model：设备型号
  // pixelRatio：设备的像素比
  // screenWidth：屏幕的宽度，单位px
  // screenHeight：屏幕的高度，单位px
  // windowWidth：可使用屏幕的宽度，单位px
  // windowHeight：可使用屏幕的高度，单位px
  // statusBarHeight：状态栏的高度，单位px
  // language：app当前的语言
  // version：app的版本号
  // buildVersion：app的build号
  // system：操作系统和版本
  // platform：app的平台
  // theme：主题，dark还是light
  // callback中的第一个参数返回是否成功，false说明失败，第二个参数会返回所有的原生返回结果
  // callback中第二个参数是返回的content内容：返回上面的所有的内容
  Filez.prototype.getSystemInfo = function (callback) {
    this.callHandler('getSystemInfo', {}, function (response) {
        if(!response.isStandardRes || response.code != showModelFilezErrorCodeSuccess){
            //失败
            if(callback){
                callback(false, response)
            }
        }
        if (callback) {
            callback(response.isSuccess, response.content);
        }
    })
}
  // interaction

    // 调用显示原生的Toast
    // title: 标题
    // duration: 显示的时间
    // callback中的第一个参数返回是否成功，false说明失败，第二个参数会返回所有的原生返回结果
    Filez.prototype.showToast = function (opt, callback) {
        var def = {
            title: "",
            duration: 1500
        }
        var data = Object.assign(def, opt);
        this.callHandler('showToast', data, function (response) {
            if(!response.isStandardRes || response.code != FilezErrorCodeConstants.FilezErrorCodeSuccess){
                //失败
                if(callback){
                    callback(false, response)
                }
            }
            if (callback) {
                callback(response.isSuccess, response.content);
            }
        })
    }
    // 显示Model框，提示框
    // title：标题
    // content：内容
    // showCancel：是不是显示取消按钮
    // cancelText： 取消按钮的标题
    // confirmText：确定按钮的标题
    // callback中的第一个参数返回是否成功，false说明失败，第二个参数会返回所有的原生返回结果
    // callback中第二个参数是返回的content内容：content.confirm == true 说明点击确定按钮  content.cancel==true 说明点击取消按钮
    Filez.prototype.showModel = function (opt, callback) {
        var def = {
            title: "",
            content: '',
            showCancel: true,
            cancelText: "取消",
            confirmText: "确定"
        }
        var data = Object.assign(def, opt);
        this.callHandler('showModel', data, function (response) {
            if(!response.isStandardRes || response.code != FilezErrorCodeConstants.FilezErrorCodeSuccess){
                //失败
                if(callback){
                    callback(false, response)
                }
            }
            if (callback) {
                callback(response.isSuccess, response.content);
            }
        })
    }
    // 显示ActionSheet
    // title：标题
    // itemList: item的标题的数组，必须是Array.<string>,不要超过六个item
    // showCancel：是不是显示取消按钮，默认true
    // cancelText： 取消按钮的标题，默认“取消”
    // callback中的第一个参数返回是否成功，false说明失败，第二个参数会返回所有的原生返回结果
    // callback中第二个参数返回content，content.tapIndex 点击的item的序号，content.tapIndex == -1 ，说明点击cancel
    Filez.prototype.showActionSheet = function (opt, callback) {
        var def = {
            title: "",
            itemList: [],
            showCancel: true,
            cancelText: "取消"
        }
        var data = Object.assign(def, opt);
        this.callHandler('showActionSheet', data, function (response) {
            if(!response.isStandardRes || response.code != FilezErrorCodeConstants.FilezErrorCodeSuccess){
                //失败
                if(callback){
                    callback(false, response)
                }
            }
            if (callback) {
                callback(response.isSuccess, response.content);
            }
        })
    }

    // 显示文本输入框
    // title：标题
    // placeHolder：站位文本
    // content：默认显示的内容
    // confirmText：提交按钮显示的文本
    // callback中的第一个参数返回是否成功，false说明失败，第二个参数会返回所有的原生返回结果
    // callback中第二个参数返回content，content.text 输入的内容，content.cancel == true ，说明点击cancel
    Filez.prototype.showTextInput = function (opt, callback) {
        var def = {
            title: "",
            placeHolder: "",
            content: "",
            confirmText: "保存"
        }
        var data = Object.assign(def, opt);
        this.callHandler('showTextInput', data, function (response) {
            if(!response.isStandardRes || response.code != FilezErrorCodeConstants.FilezErrorCodeSuccess){
                //失败
                if(callback){
                    callback(false, response)
                }
            }
            if (callback) {
                callback(response.isSuccess, response.content);
            }
        })
    }

    Filez.prototype.previewFile = function(opt, callback){
        var def = {
            file: {}
        }
        var data = Object.assign(def, opt);
        this.callHandler('previewFile', data, function (response) {
            if(callback){
                callback(response.isSuccess, response.content);
            }
        })
    }

    Filez.prototype.downloadFile = function(opt, callback){
        var def = {
            files: []
        }
        var data = Object.assign(def, opt);
        this.callHandler('downloadFile', data, function (response) {
            if(callback){
                callback(response.isSuccess, response.content);
            }
        })
    }
    Filez.prototype.openApprovalDetail = function(opt, callback){
        var def = {
            approval_id: 0
        }
        var data = Object.assign(def, opt);
        this.callHandler('openApprovalDetail', data, function (response) {
            if(callback){
                callback(response.isSuccess, response.content);
            }
        })
    }

    Filez.prototype.openMyFilePublishApproval = function(opt, callback){
        var def = {
                     approvalId : ""
                  }
        var data = Object.assign(def, opt);
        this.callHandler('openMyFilePublishApproval', data, function (response) {
            if(callback){
                callback(response.isSuccess, response.content);
            }
        })
    }

    Filez.prototype.openMyFilePublishApprovalWithCallback = function(opt, callback){
        var def = {
                     approvalId : ""
                  }
        var data = Object.assign(def, opt);
        this.callHandler('openMyFilePublishApprovalWithCallback', data, function (response) {
            if(callback){
                callback(response.isSuccess, response.content);
            }
        })
    }

    // 初始化方法
    var filez = new Filez({
        log: false,
        platform: 'other'
    });

    //最后将插件对象暴露给全局对象
    _global = (function () { return this || (0, eval)('this'); }());
    if (typeof module !== "undefined" && module.exports) {
        module.exports = filez;
    } else if (typeof define === "function" && define.amd) {
        define(function () { return filez; });
    } else {
        !('filez' in _global) && (_global.filez = filez);
    }
}())
