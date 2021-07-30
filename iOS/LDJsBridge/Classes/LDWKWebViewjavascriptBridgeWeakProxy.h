//
//  LDWKWebViewjavascriptBridgeWeakProxy.h
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDWKWebViewjavascriptBridgeWeakProxy : NSObject <WKScriptMessageHandler>

#pragma mark - ---------- 属性 ----------

/// 代理
@property (nonatomic, weak) id<WKScriptMessageHandler> delegate;

#pragma mark - ---------- 初始化 ----------

/// 初始化
/// @param delegate 代理
+ (instancetype)weakProxyWithDelegate:(id<WKScriptMessageHandler>)delegate;

/// 初始化
/// @param delegate 代理
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate;

@end

NS_ASSUME_NONNULL_END
