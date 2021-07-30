//
//  LDWKWebViewJavascriptBridgeCore.m
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import "LDWKWebViewJavascriptBridgeCore.h"
#import "LDWKWebViewJavascriptBridgeHandlerInterface.h"
#import "LDJBMessage.h"
#import "LDJBUtils.h"
#import "LDJBConstants.h"

@interface LDWKWebViewJavascriptBridgeCore ()

#pragma mark - ---------- 属性 ----------

/// 消息的队列,为了保存还么有注入JS之前所有的命令的队列
@property (nonatomic, strong) NSMutableArray<LDJBMessage *> *startupMessageQueue;

/// 回调的字典
@property (nonatomic, strong) NSMutableDictionary<NSString *, LDJBResponseCallback> *responseCallbacks;

/// 处理消息的字典
@property (nonatomic, strong) NSMutableDictionary<NSString *, LDJBHandler> *messageHandlers;

@end

@implementation LDWKWebViewJavascriptBridgeCore

- (NSMutableDictionary<NSString *, LDJBResponseCallback> *)responseCallbacks{
    if(!_responseCallbacks){
        _responseCallbacks = [NSMutableDictionary dictionary];
    }
    return _responseCallbacks;
}

- (NSMutableDictionary<NSString *, LDJBHandler> *)messageHandlers{
    if(!_messageHandlers){
        _messageHandlers = [NSMutableDictionary dictionary];
    }
    return _messageHandlers;
}

#pragma mark - ---------- 初始化 ----------

- (instancetype)init {
    self = [super init];
    if (self) {
        self.startupMessageQueue = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    if(_startupMessageQueue){
        _startupMessageQueue = nil;
    }
    if(_responseCallbacks){
        _responseCallbacks = nil;
    }
    if(_messageHandlers){
        _messageHandlers = nil;
    }
}

#pragma mark - ---------- 公共方法 ----------

- (void)reset{
    if(_startupMessageQueue){
        [_startupMessageQueue removeAllObjects];
    }
    
    if(_responseCallbacks){
        [_responseCallbacks removeAllObjects];
    }
}

- (void)sendData:(id)data withHandlerName:(NSString *)handlerName callBack:(LDJBResponseCallback)callBack{
    LDJBMessage *message = [[LDJBMessage alloc] init];
    if(data){
        message.data = data;
    }
    
    if(callBack){
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%@", [LDJBUtils uniqueId]];
        [self.responseCallbacks setValue:[callBack copy] forKey:callbackId];
        message.callbackId = callbackId;
    }
    
    if(handlerName){
        message.handlerName = handlerName;
    }
    
    [self _addToQueueWithMessage:message];
}

- (void)flushMessageQueueWithString:(NSString *)messageQueueString{
    if(!messageQueueString || messageQueueString.length == 0){
        //
        NSLog(@"LDJsBridge: WARNING: ObjC got nil while fetching the message queue JSON from webview. This can happen if the WebViewJavascriptBridge JS is not currently present in the webview, e.g if the webview just loaded a new page.");
        return;
    }
    
    NSArray<LDJBMessage *> *messages = [LDJBMessage messagesWithJsonString:messageQueueString];
    if(!messages || messages.count == 0){
        return;
    }
    
    [messages enumerateObjectsUsingBlock:^(LDJBMessage *message, NSUInteger idx, BOOL *stop) {
        NSString *responsId = message.responseId;
        if(responsId){
            //有响应ID
            LDJBResponseCallback responseCallBack = [self.responseCallbacks objectForKey:responsId];
            if(responseCallBack){
                responseCallBack(message.responseData);
            }
            [self.responseCallbacks removeObjectForKey:responsId];
        }else{
            //没有响应ID,可能是JS直接调用原生的代码
            NSString* callbackId = message.callbackId;
            LDJBResponseCallback responseCallBack = NULL;
            if(callbackId){
                //回调给JS的回调方法
                responseCallBack = ^(id responseData) {
                    if (responseData == nil) {
                        responseData = [NSNull null];
                    }
                    
                    LDJBMessage *message = [[LDJBMessage alloc] init];
                    message.responseId = callbackId;
                    message.responseData = responseData;
                    [self _addToQueueWithMessage:message];
                };
            }else{
                responseCallBack = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }
            
            NSString *handerName = message.handlerName;
            if(!handerName || handerName.length == 0){
                return;
            }
            
            LDJBHandler handler = [self.messageHandlers objectForKey:handerName];
            if(!handler){
                NSLog(@"LDJsBridge: Exception, No handler for message from JS: %@", message);
                return;
            }
            
            handler(message.data, responseCallBack);
        }
    }];
}

- (void)injectJavascriptFile{
    NSString *js = LDJBInjectJavascript();
    [self _evaluateJavascript:js];
    if (self.startupMessageQueue) {
        NSArray* queue = self.startupMessageQueue;
        self.startupMessageQueue = nil;
        for (id queuedMessage in queue) {
            [self _dispatchMessage:queuedMessage];
        }
    }
}

- (NSString *)javascriptFetchQueyCommand{
    return CALL_JS_FETCH_QUEUE_FUNC_COMMENT;
}

- (void)registerHandlerWithName:(NSString *)name handler:(LDJBHandler)handler{
    [self.messageHandlers setValue:[handler copy] forKey:name];
}

- (void)registerJavascriptHandler:(LDWKWebViewJavascriptBridgeHandlerInterface *)javascriptHandler{
    if(!javascriptHandler || ![javascriptHandler isKindOfClass:LDWKWebViewJavascriptBridgeHandlerInterface.class]){
        return;
    }
    [javascriptHandler registerAllMethodsWithBridge:self];
}

- (void)removeHandlerWithName:(NSString *)name{
    [self.messageHandlers removeObjectForKey:name];
}

#pragma mark - ---------- 私有方法 ----------

/// 添加到队列里面，如果没有startup队列，直接执行
/// @param message 消息
- (void)_addToQueueWithMessage:(LDJBMessage *)message{
    if (self.startupMessageQueue) {
        [self.startupMessageQueue addObject:message];
    } else {
        //直接发送
        [self _dispatchMessage:message];
    }
}

/// 发送一个消息
/// @param message 消息
- (void)_dispatchMessage:(LDJBMessage *)message{
    NSString *javascriptCommand = message.javascriptCommend;
    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavascript:javascriptCommand];

    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _evaluateJavascript:javascriptCommand];
        });
    }
}

/// 执行js命令
/// @param javascriptCommand 命令
- (void)_evaluateJavascript:(NSString *)javascriptCommand{
    if(self.delegate && [self.delegate respondsToSelector:@selector(jsBridgeCore:evaluateJavascript:)]){
        [self.delegate jsBridgeCore:self evaluateJavascript:javascriptCommand];
    }
}

@end
