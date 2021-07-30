//
//  LDWKWebViewJavascriptBridgeCore.h
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import <Foundation/Foundation.h>
#import "LDWKWebViewJavascriptBridgeHandlerInterface.h"
@class LDWKWebViewJavascriptBridgeCore;

NS_ASSUME_NONNULL_BEGIN

/// JS回调
typedef void (^LDJBResponseCallback)(id _Nullable responseData);

/// 处理回调
typedef void (^LDJBHandler)(id data, LDJBResponseCallback responseCallback);

@protocol LDWKWebViewJavascriptBridgeCoreDelegate <NSObject>

/// 执行js命令的回调
/// @param jsBridgeCore 实例
/// @param javascript 命令语句
- (void)jsBridgeCore:(LDWKWebViewJavascriptBridgeCore *)jsBridgeCore evaluateJavascript:(NSString *)javascript;

@end

@interface LDWKWebViewJavascriptBridgeCore : NSObject

#pragma mark - ---------- 属性 ----------

/// 是不是开启日志
@property (nonatomic, assign, getter=isLogEnable) BOOL logEnable;

/// 代理
@property (nonatomic, weak) id<LDWKWebViewJavascriptBridgeCoreDelegate> delegate;

#pragma mark - ---------- 公共方法 ----------

/// 重置
- (void)reset;

/// 发送一个请求
/// @param data data
/// @param handlerName 处理的名字
/// @param callBack 回调
- (void)sendData:(nullable id)data withHandlerName:(nullable NSString *)handlerName callBack:(nullable LDJBResponseCallback)callBack;

/// 刷新消息队列，接收JS的请求
/// @param messageQueueString 消息字符串
- (void)flushMessageQueueWithString:(NSString *)messageQueueString;

/// 注入JS代码
- (void)injectJavascriptFile;

/// 返回刷新JS队列的命令
- (NSString *)javascriptFetchQueyCommand;

/// 注册一个JS调用IOS的方法
/// @param name 名称，必须跟JS的方法名一直
/// @param handler 处理器
- (void)registerHandlerWithName:(NSString *)name handler:(LDJBHandler)handler;

/// 注册一个JS的处理类
/// @param javascriptHandler 必须继承LDWKWebViewJavascriptHandlerInterface
- (void)registerJavascriptHandler:(LDWKWebViewJavascriptBridgeHandlerInterface *)javascriptHandler;

/// 删除一个JS调用ISO的方法
/// @param name 名称，跟JS方法一直
- (void)removeHandlerWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
