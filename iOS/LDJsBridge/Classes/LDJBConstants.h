//
//  LDJBConstants.h
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import <Foundation/Foundation.h>

// 注入的JS字符串
NSString * LDJBInjectJavascript(void);

// 注入JS的方法名称
FOUNDATION_EXPORT NSString * const iOS_Native_InjectJavascript;

// 刷新消息队列的方法名称
FOUNDATION_EXPORT NSString * const iOS_Native_FlushMessageQueue;

// 调用JS的命令
FOUNDATION_EXPORT NSString * const CALL_JS_FUNC_COMMENT;

// fetech命令
FOUNDATION_EXPORT NSString * const CALL_JS_FETCH_QUEUE_FUNC_COMMENT;

// 响应JS的同步方法的前缀
FOUNDATION_EXPORT NSString * const JS_HANDLER_SYNC_METHOD_PREFIX;

// 响应JS的异步方法的前缀
FOUNDATION_EXPORT NSString * const JS_HANDLER_ASYNC_METHOD_PREFIX;
