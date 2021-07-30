//
//  LDJBResponse.h
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDJBResponse : NSObject

#pragma mark - ---------- 属性 ----------

/// 状态码
@property (nonatomic, copy) NSString *code;

/// 消息
@property (nonatomic, copy) NSString *message;

/// 错误码
@property (nonatomic, copy) NSString *errorCode;

/// 返回的内容
@property (nonatomic, strong) NSDictionary<NSString *, id<NSCoding>> *content;

#pragma mark - ---------- 公共方法 ----------

/// 返回当前的JSon字符串
- (nullable NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
