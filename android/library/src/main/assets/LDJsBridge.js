 (function () {
    if (window.LDJsBridge) {
        return;
    }

    if (!window.onerror) {
        window.onerror = function (msg, url, line) {
            console.log("LDJsBridge: ERROR:" + msg + "@" + url + ":" + line);
        }
    }
    window.LDJsBridge = {
        sendMessageQueue: [],
        messageHandlers: {},
        jsHybridNotes: [],
        responseCallbacks: {},
        uniqueId: 1,
        registerHandler: registerHandler,
        callHandler: callHandler,
        _fetchQueue: _fetchQueue,
        _handleMessageFromAndroid: _handleMessageFromAndroid,
        _addJsHybridNote: _addJsHybridNote,
        _getHandlerNames: _getHandlerNames
    };

//    var sendMessageQueue = [];
//    var messageHandlers = {};
//    //绑定的jsNode的数组
//    var jsHybridNotes = [];
//
//    var responseCallbacks = {};
//    var uniqueId = 1;

    function registerHandler(handlerName, handler) {
        console.log("LDJsBridge registerHandler handlerName " + handlerName);
        console.log("LDJsBridge registerHandler handler " + handler);
        window.LDJsBridge.messageHandlers[handlerName] = handler;
    }

    function callHandler(handlerName, data, responseCallback) {
    console.log("LDJsBridge callHandler handlerName " + handlerName);
        if (arguments.length == 2 && typeof data == 'function') {
            responseCallback = data;
            data = null;
        }
        _doSend({ handlerName: handlerName, data: data }, responseCallback);
    }

    function _doSend(message, responseCallback) {
    console.log("LDJsBridge _doSend ");
        if (responseCallback) {
            var callbackID = 'cb_' + (window.LDJsBridge.uniqueId++) + '_' + new Date().getTime();
            window.LDJsBridge.responseCallbacks[callbackID] = responseCallback;
            message['callbackID'] = callbackID;
        }

        var handlerName = message.handlerName;
        var nodeName = "";
        var handlerNames = _getHandlerNames();

/*遍历handlerNames所有name,查找name.handlerName是否被定义，找到第一个被定义的。
 所有不同的自定义的不同的Handler的中，不能有重复的方法名*/
        nodeName = handlerNames.find(function (name, index) {
            try {
                console.log("handlerNames.find: ");
                var tmpFn = eval('window.' + name + '.' + handlerName);
                console.log("fn ---" + 'window.' + name + '.' + handlerName);
                console.log("fn ---" + tmpFn);
                if (typeof tmpFn === 'function') {
                    return true
                } else {
                    return false;
                }
            } catch (e) {
                console.log(e);
                return false;
            }
        });
        console.log("nodeName：" + nodeName);
        if (nodeName == null) {
            nodeName = 'android';
        }

        try {
            console.log("handlerName ---" + handlerName);
            var fn = eval('window.' + nodeName + '.' + handlerName);
            console.log("fn ---" + fn);
        } catch (e) {
            console.log(e);
        }

        if (typeof fn === 'function') {
            console.log("开始执行方法" + fn);
            console.log("传递的参数-" + JSON.stringify(message));
            var responseData = fn && (window[nodeName][handlerName])(JSON.stringify(message));
            console.log('response message: ' + responseData);
            if (responseData) {
                responseCallback = window.LDJsBridge.responseCallbacks[callbackId];
                if (!responseCallback) {
                    return;
                }
                responseCallback(responseData);
                delete window.LDJsBridge.responseCallbacks[callbackId];
            }
        }
    }

    function _fetchQueue() {
    console.log("LDJsBridge _fetchQueue  ");
        var messageQueueString = JSON.stringify(window.LDJsBridge.sendMessageQueue);
        window.LDJsBridge.sendMessageQueue = [];
        return messageQueueString;
    }

    // 获取所有的处理器名称
    function _getHandlerNames(){
        console.log("_getHandlerNames" );
        var handlerNamesJson = window.android.getHandlerNames("");
        console.log("handlerNamesJson" + handlerNamesJson);
        return JSON.parse( handlerNamesJson );
    }

    function _dispatchMessageFromAndroid(messageJSON) {
        console.log("_dispatchMessageFromAndroid ");
        var message = JSON.parse(messageJSON);
        var messageHandler;
        var responseCallback;
        console.log("_dispatchMessageFromAndroid responseID: " + message.responseID);
        if (message.responseID) {
            console.log("所有的回调的数组 -- " + window.LDJsBridge.responseCallbacks);
            responseCallback = window.LDJsBridge.responseCallbacks[message.responseID];
            console.log("找到的回调的方法 -- " + responseCallback);
            if (!responseCallback) {
                return;
            }
            responseCallback(message.responseData);
            delete window.LDJsBridge.responseCallbacks[message.responseID];
        } else {
         console.log("_dispatchMessageFromAndroid callbackID: " + message.callbackID);
            if (message.callbackID) {
                var callbackResponseId = message.callbackID;
                responseCallback = function (responseData) {
                    _doSend({ handlerName: "response", responseID: callbackResponseId, responseData: responseData });
                };
            }

            var handler = window.LDJsBridge.messageHandlers[message.handlerName];
             console.log("_dispatchMessageFromAndroid handler: " + handler);
            if (!handler) {
                console.log("LDJsBridge: WARNING: no handler for message from Android:", message);
            } else {
                handler(message.data, responseCallback);
            }
        }
    }

    function _handleMessageFromAndroid(messageJSON) {
    console.log("LDJsBridge _handleMessageFromAndroid ");
        _dispatchMessageFromAndroid(messageJSON);
    }

    function _addJsHybridNote(nodeName) {
    console.log("LDJsBridge _addJsHybridNote ");
        if (nodeName && window.LDJsBridge.jsHybridNotes.includes(nodeName)) {
            return;
        }
        window.LDJsBridge.jsHybridNotes.push(nodeName);
    }

    if (filez.initFilezCallBack) {
        filez.initFilezCallBack(filez);
        filez.initFilezCallBack = null;
    }

})();