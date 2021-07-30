//
//  LDCommonJavascriptHandler.m
//  LDJsBridge_Example
//
//  Created by changmin on 2020/9/14.
//  Copyright © 2020 changmin_wow@163.com. All rights reserved.
//

#import "LDCommonJavascriptHandler.h"
#import "LDJsBridge.h"

@implementation LDCommonJavascriptHandler

- LDWKWebViewJavascriptBridgeHandlerAsyncMethod(showToast){
    NSLog(@"%@", data);

    LDJBResponse *response = [[LDJBResponse alloc] init];
    response.code = @"200";
    response.errorCode = @"";
    response.message = @"显示toast成功";
    response.content = @{@"aa" : @"aa", @"bb" : @(YES)};
    if(responseCallback){
        responseCallback(response.jsonString);
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:data[@"title"] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    
}

- LDWKWebViewJavascriptBridgeHandlerSyncMethod(showSyncToast){
    NSLog(@"%@", data);
    return @"来自iOS的同步数据";
}

@end
