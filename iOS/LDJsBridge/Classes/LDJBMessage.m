//
//  LDJBMessage.m
//  LDJsBridge
//
//  Created by changmin on 2020/9/14.
//

#import "LDJBMessage.h"
#import "LDJBConstants.h"

@implementation LDJBMessage

#pragma mark - ---------- 公共方法 ----------

/// 返回消息的json字符串
- (nullable NSString *)jsonStringWithPretty:(BOOL)pretty{
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    if(self.data){
        [jsonDic setValue:self.data forKey:@"data"];
    }
    
    if(self.callbackId){
        [jsonDic setValue:self.callbackId forKey:@"callbackID"];
    }
    
    if(self.handlerName){
        [jsonDic setValue:self.handlerName forKey:@"handlerName"];
    }
    
    if(self.responseId){
        [jsonDic setValue:self.responseId forKey:@"responseID"];
    }
    
    if(self.responseData){
        [jsonDic setValue:self.responseData forKey:@"responseData"];
    }
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonDic.copy options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
}

- (nullable NSString *)javascriptCommend{
    NSString *jsonString = [self jsonStringWithPretty:NO];
    if(!jsonString){
        return nil;
    }
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    NSString* javascriptCommand = [NSString stringWithFormat:CALL_JS_FUNC_COMMENT, jsonString];
    return javascriptCommand;
}

+ (nullable NSArray<LDJBMessage *> *)messagesWithJsonString:(NSString *)jsonString{
    NSMutableArray<LDJBMessage *> *messages = [NSMutableArray array];
    NSArray<NSDictionary *> *messageDics = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    if(!messageDics){
        return nil;
    }
    
    [messageDics enumerateObjectsUsingBlock:^(NSDictionary *messageDic, NSUInteger idx, BOOL * _Nonnull stop) {
        LDJBMessage *message = [[LDJBMessage alloc] init];
        if([messageDic.allKeys containsObject:@"callbackID"]){
            message.callbackId = [messageDic objectForKey:@"callbackID"];
        }
        
        if([messageDic.allKeys containsObject:@"data"]){
            message.data = [messageDic objectForKey:@"data"];
        }
        
        if([messageDic.allKeys containsObject:@"responseID"]){
            message.responseId = [messageDic objectForKey:@"responseID"];
        }
        
        if([messageDic.allKeys containsObject:@"responseData"]){
            message.responseData = [messageDic objectForKey:@"responseData"];
        }
        
        if([messageDic.allKeys containsObject:@"handlerName"]){
            message.handlerName = [messageDic objectForKey:@"handlerName"];
        }
        
        [messages addObject:message];
    }];
    
    return messages.copy;
}

@end
