//
//  LDWKWebViewJavascriptBridgeHandlerInterface.h
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import <Foundation/Foundation.h>
@class LDWKWebViewJavascriptBridgeCore;

NS_ASSUME_NONNULL_BEGIN

//异步方法声明
#ifndef LDWKWebViewJavascriptBridgeHandlerAsyncMethod
#define LDWKWebViewJavascriptBridgeHandlerAsyncMethod(_JS_METHOD_) \
(void)ld_javascriptInterface_async_##_JS_METHOD_##_withData:(nullable id)data responseCallback:(void(^)(id _Nullable responseData))responseCallback
#endif

//同步方法声明
#ifndef LDWKWebViewJavascriptBridgeHandlerSyncMethod
#define LDWKWebViewJavascriptBridgeHandlerSyncMethod(_JS_METHOD_) \
(nullable id)ld_javascriptInterface_sync_##_JS_METHOD_##_withData:(nullable id)data
#endif

@interface LDWKWebViewJavascriptBridgeHandlerInterface : NSObject

#pragma mark - ---------- 公共方法 ----------

/// 注册所有的JS响应方法
/// @param bridgeCore core
- (void)registerAllMethodsWithBridge:(LDWKWebViewJavascriptBridgeCore *)bridgeCore;

@end

NS_ASSUME_NONNULL_END
