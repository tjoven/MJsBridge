//
//  LDJBUtils.m
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import "LDJBUtils.h"

@implementation LDJBUtils

#pragma mark - ---------- 公共方法 ----------

/// 返回一个唯一的随机数
+ (NSString *)uniqueId{
    return [[NSUUID UUID] UUIDString];
}

@end
