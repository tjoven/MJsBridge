//
//  LDWKWebViewjavascriptBridgeWeakProxy.m
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import "LDWKWebViewjavascriptBridgeWeakProxy.h"

@implementation LDWKWebViewjavascriptBridgeWeakProxy

#pragma mark - ---------- 初始化 ----------

+ (instancetype)weakProxyWithDelegate:(id<WKScriptMessageHandler>)delegate{
    return [[self alloc] initWithDelegate:delegate];
}

/// 初始化
/// @param delegate 代理
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate{
    self = [super init];
    if(self){
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - ---------- WKScriptMessageHandler ----------

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if(self.delegate && [self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]){
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
