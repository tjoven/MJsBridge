//
//  LDJBViewController.m
//  LDJsBridge
//
//  Created by changmin_wow@163.com on 09/14/2020.
//  Copyright (c) 2020 changmin_wow@163.com. All rights reserved.
//

#import "LDJBViewController.h"
#import "LDJsBridge.h"
#import "LDCommonJavascriptHandler.h"

@interface LDJBViewController ()

#pragma mark - ---------- 属性 ----------

@property (nonatomic, strong) WKWebView *webView;

/// JS回调按钮
@property (nonatomic, strong) UIButton *callBackButton;

/// 刷新按钮
@property (nonatomic, strong) UIButton *reloadButton;

/// jsbridge
@property (nonatomic, strong) LDWKWebViewJavascriptBridge *jsBridge;

@end

@implementation LDJBViewController

#pragma mark - ---------- Getter ----------

- (WKWebView *)webView{
    if(!_webView){
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (UIButton *)callBackButton{
    if(!_callBackButton){
        _callBackButton = [[UIButton alloc] init];
        _callBackButton.backgroundColor = UIColor.blackColor;
        [_callBackButton setTitle:@"Call Handler" forState:UIControlStateNormal];
        [_callBackButton addTarget:self action:@selector(callBackButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callBackButton;
}

- (UIButton *)reloadButton{
    if(!_reloadButton){
        _reloadButton = [[UIButton alloc] init];
        _reloadButton.backgroundColor = UIColor.blackColor;
        [_reloadButton setTitle:@"刷新webView" forState:UIControlStateNormal];
        [_reloadButton addTarget:self action:@selector(reloadButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadButton;
}

- (LDWKWebViewJavascriptBridge *)jsBridge{
    if(!_jsBridge){
        _jsBridge = [LDWKWebViewJavascriptBridge jsBridgeWithWKWebView:self.webView];
    }
    return _jsBridge;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        self.webView.frame = self.view.bounds;
        [self.view addSubview:self.webView];
        [self _loadHTML];

        self.callBackButton.frame = CGRectMake(10, [UIScreen mainScreen].bounds.size.height - 80, [UIScreen mainScreen].bounds.size.width * 0.4, 35);
        self.reloadButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - [UIScreen mainScreen].bounds.size.width * 0.4 - 10, [UIScreen mainScreen].bounds.size.height - 80, [UIScreen mainScreen].bounds.size.width * 0.4, 35);
        
        [self.view addSubview:self.callBackButton];
        [self.view addSubview:self.reloadButton];
        
        [self.jsBridge registerHandlerWithName:@"testiOSCallback" handler:^(id  _Nonnull data, LDJBResponseCallback  _Nonnull responseCallback) {
            NSLog(@"data -- %@", data);
            if(responseCallback){
                responseCallback(@"Response from testiOSCallback");
            }
        }];
        
        [self.jsBridge registerJavascriptHandler:[[LDCommonJavascriptHandler alloc] init]];
        
    //    [self.jsBridge registerHandlerWithName:@"showToast" handler:^(id  _Nonnull data, LDWKJBResponseCallback  _Nonnull responseCallback) {
    //        NSDictionary *params = (NSDictionary*)data;
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[params objectForKey:@"text"] message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    //        [alertView show];
    //    }];
        
        [self.jsBridge registerHandlerWithName:@"showIOSAlertView" handler:^(id  _Nonnull data, LDJBResponseCallback  _Nonnull responseCallback) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"test" message:@"来自js" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if(responseCallback){
                    responseCallback(@"取消");
                }
            }];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                if(responseCallback){
                    responseCallback(@"点击确定");
                }
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }];
}

#pragma mark - ---------- 私有方法 ----------

/// 加载网页
- (void)_loadHTML{
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"Demo" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    [self.webView loadHTMLString:appHtml baseURL:baseURL];
    NSURL *baseURL = [NSURL URLWithString:@"http://test.lenovows.com/mobile/mobileToJSNative.html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:baseURL]];
}

#pragma mark - ---------- 事件 ----------

/// 点击JS安妮
/// @param sender sender
- (void)callBackButtonTaped:(id)sender{
    NSDictionary *data = @{@"greetingFromiOS" : @"Hi there, JS!"};
    
    [self.jsBridge callJavascriptWithHandlerName:@"callFromIOS" data:data responseCallback:^(id  _Nullable responseData) {
        NSLog(@"testJavascriptHandler responded: %@", (NSString *)responseData);
    }];
}

/// 点击刷新按钮
/// @param sender 按钮
- (void)reloadButtonTaped:(id)sender{
    [self.webView reload];
}

@end
