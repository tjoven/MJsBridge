//
//  LDWKWebViewJavascriptBridge.h
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import <Foundation/Foundation.h>
#import "LDWKWebViewJavascriptBridgeCore.h"
#import "LDWKWebViewJavascriptBridgeHandlerInterface.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDWKWebViewJavascriptBridge : NSObject

#pragma mark - ---------- 初始化 ----------

/// 初始化
/// @param webView webView
+ (instancetype)jsBridgeWithWKWebView:(WKWebView *)webView;

/// 初始化
/// @param webView webView
- (instancetype)initWithWKWebView:(WKWebView *)webView;

/// 禁止使用
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - ---------- 公共方法 ----------

/// 重置
- (void)reset;

/// 注册一个JS调用IOS的方法
/// @param name 名称，必须跟JS的方法名一直
/// @param handler 处理器
- (void)registerHandlerWithName:(NSString *)name handler:(LDJBHandler)handler;

/// 注册一个JS调用的处理类
/// @param javascriptHandler 必须是继承LDWKWebViewJavascriptHandlerInterface
- (void)registerJavascriptHandler:(LDWKWebViewJavascriptBridgeHandlerInterface *)javascriptHandler;

/// 删除一个JS调用ISO的方法
/// @param name 名称，跟JS方法一直
- (void)removeHandlerWithName:(NSString *)name;

/// 请求一个JS方法
/// @param handlerName 方法名称
- (void)callJavascriptWithHandlerName:(NSString *)handlerName;

/// 请求一个JS方法
/// @param handlerName 方法名
/// @param data 参数
- (void)callJavascriptWithHandlerName:(NSString *)handlerName data:(nullable id)data;

/// 请求一个JS的方法
/// @param handlerName 方法的名字
/// @param data 传递的参数
/// @param responseCallback 返回的回调方法
- (void)callJavascriptWithHandlerName:(NSString *)handlerName data:(nullable id)data responseCallback:(nullable LDJBResponseCallback)responseCallback;

@end

NS_ASSUME_NONNULL_END
