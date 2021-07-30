//
//  LDWKWebViewJavascriptBridge.m
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import "LDWKWebViewJavascriptBridge.h"
#import "LDWKWebViewJavascriptBridgeCore.h"
#import "LDWKWebViewjavascriptBridgeWeakProxy.h"
#import "LDJBConstants.h"

@interface LDWKWebViewJavascriptBridge () <LDWKWebViewJavascriptBridgeCoreDelegate, WKScriptMessageHandler>

#pragma mark - ---------- 属性 ----------

/// webView
@property (nonatomic, weak) WKWebView *webView;

/// 核心处理类
@property (nonatomic, strong) LDWKWebViewJavascriptBridgeCore *core;

@end

@implementation LDWKWebViewJavascriptBridge

#pragma mark - ---------- Getter ----------

- (LDWKWebViewJavascriptBridgeCore *)core{
    if(!_core){
        _core = [[LDWKWebViewJavascriptBridgeCore alloc] init];
    }
    return _core;
}

#pragma mark - ---------- 初始化 ----------

+ (instancetype)jsBridgeWithWKWebView:(WKWebView *)webView{
    return [[self alloc] initWithWKWebView:webView];
}

- (instancetype)initWithWKWebView:(WKWebView *)webView{
    self = [super init];
    if(self){
        self.webView = webView;
        self.core.delegate = self;
        [self _addScriptMessageHandlers];
    }
    return self;
}

- (void)dealloc {
    self.core.delegate = nil;
    [self _removeScriptMessageHandlers];
}

#pragma mark - ---------- 公共方法 ----------

- (void)reset{
    [self.core reset];
}

- (void)registerHandlerWithName:(NSString *)name handler:(LDJBHandler)handler{
    [self.core registerHandlerWithName:name handler:handler];
}

- (void)registerJavascriptHandler:(LDWKWebViewJavascriptBridgeHandlerInterface *)javascriptHandler{
    [self.core registerJavascriptHandler:javascriptHandler];
}

- (void)removeHandlerWithName:(NSString *)name{
    [self.core removeHandlerWithName:name];
}

- (void)callJavascriptWithHandlerName:(NSString *)handlerName{
    [self callJavascriptWithHandlerName:handlerName data:nil];
}

- (void)callJavascriptWithHandlerName:(NSString *)handlerName data:(nullable id)data{
    [self callJavascriptWithHandlerName:handlerName data:data responseCallback:nil];
}

- (void)callJavascriptWithHandlerName:(NSString *)handlerName data:(nullable id)data responseCallback:(nullable LDJBResponseCallback)responseCallback{
    [self.core sendData:data withHandlerName:handlerName callBack:responseCallback];
}

#pragma mark - ---------- 私有方法 ----------

/// 添加消息处理
- (void)_addScriptMessageHandlers{
    if(!self.webView){
        return;
    }
    [self.webView.configuration.userContentController addScriptMessageHandler:[LDWKWebViewjavascriptBridgeWeakProxy weakProxyWithDelegate:self] name:iOS_Native_InjectJavascript];
    [self.webView.configuration.userContentController addScriptMessageHandler:[LDWKWebViewjavascriptBridgeWeakProxy weakProxyWithDelegate:self] name:iOS_Native_FlushMessageQueue];
}

/// 移除消息处理
- (void)_removeScriptMessageHandlers{
    if(!self.webView){
        return;
    }
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:iOS_Native_InjectJavascript];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:iOS_Native_FlushMessageQueue];
}

/// 刷新消息队列
- (void)_flushMessageQueue{
    if(!self.webView){
        return;
    }
    [self.webView evaluateJavaScript:[self.core javascriptFetchQueyCommand] completionHandler:^(NSString *result, NSError *error) {
        if(error){
            //发生错误
            NSLog(@"LDWKWebViewJavascriptBridge: WARNING: Error when trying to fetch data from WKWebView: %@", error);
        }
        [self.core flushMessageQueueWithString:result];
    }];
}

#pragma mark - ---------- LDWKWebViewJavascriptBridgeCoreDelegate ----------

- (void)jsBridgeCore:(LDWKWebViewJavascriptBridgeCore *)jsBridgeCore evaluateJavascript:(NSString *)javascript{
    if(!self.webView){
        return;
    }
    [self.webView evaluateJavaScript:javascript completionHandler:nil];
}

#pragma mark - ---------- WKScriptMessageHandler ----------

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name isEqualToString:iOS_Native_InjectJavascript]){
        //网页加载完成，需要注入JS脚本
        [self.core injectJavascriptFile];
    }else if ([message.name isEqualToString:iOS_Native_FlushMessageQueue]){
        //响应JS请求
        [self _flushMessageQueue];
    }
}

@end
