//
//  LDJBResponse.m
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import "LDJBResponse.h"

@implementation LDJBResponse

#pragma mark - ---------- 公共方法 ----------

- (nullable NSString *)jsonString{
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    if(self.code){
        [jsonDic setValue:self.code forKey:@"code"];
    }
    if(self.message){
        [jsonDic setValue:self.message forKey:@"message"];
    }
    if(self.errorCode){
        [jsonDic setValue:self.errorCode forKey:@"errorCode"];
    }
    
    if(self.content){
        [jsonDic setValue:self.content forKey:@"content"];
    }
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonDic.copy options:0 error:nil] encoding:NSUTF8StringEncoding];
}

@end
