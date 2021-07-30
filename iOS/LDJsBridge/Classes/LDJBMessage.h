//
//  LDJBMessage.h
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDJBMessage : NSObject

#pragma mark - ---------- 属性 ----------

/// 数据
@property (nonatomic, strong) id data;

/// 回调的唯一ID
@property (nonatomic, copy) NSString *callbackId;

/// 响应的ID
@property (nonatomic, copy) NSString *responseId;

/// 响应的data
@property (nonatomic, strong) id responseData;

/// 处理方法的名字
@property (nonatomic, copy) NSString *handlerName;

#pragma mark - ---------- 公共方法 ----------

/// 返回消息的json字符串
- (nullable NSString *)jsonStringWithPretty:(BOOL)pretty;

/// 返回消息对应的js命令字符串
- (nullable NSString *)javascriptCommend;

/// 根据js传过来的js，返回消息的数组
/// @param jsonString 字符串
+ (nullable NSArray<LDJBMessage *> *)messagesWithJsonString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
