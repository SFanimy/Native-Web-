//
//  WebViewController.m
//  QYHongPinShuo
//
//  Created by 管理员 on 17/4/11.
//  Copyright © 2017年 Animy. All rights reserved.
//

#import "WebViewController.h"
#import "AppDelegate.h"
#import "WebViewJavascriptBridge.h"

@interface WebViewController ()<UIWebViewDelegate,UIActionSheetDelegate>
{
    NSString *callback;
    NSArray *shareArray;
    
    UIWebView *webView;
    UIButton *firstButton;
    
    NSDictionary *paydic;
}
@property (strong, nonatomic) WebViewJavascriptBridge *bridge;


@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate loadCookies];
    
    
     self.view.backgroundColor = [UIColor whiteColor];
    
   
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, kDeviceWidth, kDeviceHeight-20)];
    webView.backgroundColor = [UIColor whiteColor];
    webView.backgroundColor = UIColorMakeRGBA(247, 247, 247, 1);
    
    NSURL *url = [NSURL URLWithString:@"https://shop.cguoguo.com/index.php/C/Index/index.html"];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    
    
//    方法2: WebViewJavascriptBridge开源库使用
    
 
    [WebViewJavascriptBridge enableLogging];
     _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
  
    [self.bridge setWebViewDelegate:self];

    //oc获取js数据
    [self.bridge registerHandler:@"getShareFromObjC" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"oc获取js数据：%@",dataDic);
        }
    }];

    [self.bridge registerHandler:@"getBlogNameFromObjC" handler:^(id data, WVJBResponseCallback responseCallback) {
      
        if (responseCallback) {
           NSLog(@"支付数据：%@",data);
            [self goodsPayClick:data[@"info"]];
        }
    }];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPayInfo:) name:@"pushPayInfo" object:nil];
    
    
  
    firstButton = [[UIButton alloc]initWithFrame:CGRectMake(kDeviceWidth-48, kDeviceHeight-188-40, 40, 40)];
    [firstButton setImage:[UIImage imageNamed:@"返回首页"] forState:UIControlStateNormal];
    firstButton.hidden = 1;
    [firstButton addTarget:self action:@selector(firstClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:firstButton];

   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


- (void)pushPayInfo:(NSNotification *)noti{
    NSDictionary *dic = [noti object];
    
    NSDictionary *userDic ;
    
    if ([dic[@"status"] isEqualToString:@"0"]) {
        userDic = [[NSDictionary alloc]initWithObjectsAndKeys:paydic[@"go_url"], @"url",nil];
    }else{
        userDic = [[NSDictionary alloc]initWithObjectsAndKeys:paydic[@"back_url"], @"url",nil];
    }
    
    //oc回传数据到js数据
    [self.bridge callHandler:@"getPayInfos" data:userDic responseCallback:^(id response) {
        NSLog(@"oc回传数据到js: %@",response);
    }];

}



- (void)firstClick:(UIButton *)sender{
    NSURL *url = [NSURL URLWithString:@"https://shop.cguoguo.com/index.php/C/Index/index.html"];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    
    [webView loadRequest:request];
    
}


//URL 解码
-(NSString *)URLDecodedString:(NSString *)str
{
 
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSLog(@"decodedString:%@",decodedString);
    return decodedString;
}



//分享
- (void)shareClick{
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"朋友圈", nil];
    [sheet showInView:self.view];
  
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [NSString stringWithFormat:@"%@",shareArray[1]];
        message.description = [NSString stringWithFormat:@"%@",shareArray[2]];
        
        WXWebpageObject *web = [WXWebpageObject object];
        web.webpageUrl = [NSString stringWithFormat:@"%@",shareArray[3]];
        message.mediaObject = web;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneSession;
        
        [WXApi sendReq:req];

    }
    
    if (buttonIndex == 1) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [NSString stringWithFormat:@"%@",shareArray[1]];
        message.description = [NSString stringWithFormat:@"%@",shareArray[2]];
        
        WXWebpageObject *web = [WXWebpageObject object];
        web.webpageUrl = [NSString stringWithFormat:@"%@",shareArray[3]];
        message.mediaObject = web;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneTimeline;
        
        [WXApi sendReq:req];

    }
   
    
   }


- (NSString*)getCurrentTime {
    
    NSDate*datenow = [NSDate  date];
    
    NSString*timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    NSTimeZone*zone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    
    NSDate*localeDate = [datenow dateByAddingTimeInterval:interval];
    
    NSString*timeSpp = [NSString stringWithFormat:@"%f", [localeDate timeIntervalSince1970]];
    
    return timeSp;
    
}


//产品支付
- (void)goodsPayClick:(NSDictionary *)dic{
    paydic = dic;
  
    NSLog(@"产品支付:%@",dic);
    PayReq *request = [[PayReq alloc] init];
    /** 商家向财付通申请的商家id */
    request.partnerId = dic[@"partnerid"];
    /** 预支付订单 */
    request.prepayId= dic[@"prepayid"];
    /** 商家根据财付通文档填写的数据和签名 */
    request.package = @"Sign=WXPay";
    /** 随机串，防重发 */
    request.nonceStr= dic[@"noncestr"];
    /** 时间戳，防重发 */
    request.timeStamp= [dic[@"timestamp"] intValue];
    /** 商家根据微信开放平台文档对数据做的签名 */
    request.sign=dic[@"sign"];
    /*! @brief 发送请求到微信，等待微信返回onResp
     *
     * 函数调用后，会切换到微信的界面。第三方应用程序等待微信返回onResp。微信在异步处理完成后一定会调用onResp。支持以下类型
     * SendAuthReq、SendMessageToWXReq、PayReq等。
     * @param req 具体的发送请求，在调用函数后，请自己释放。
     * @return 成功返回YES，失败返回NO。
     */
    [WXApi sendReq: request];
}


#pragma mark   webViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    firstButton.hidden =0;
    
    NSString *requestString = [[request URL] absoluteString];

    //方法1:通过拦截url scheme判断
    if ([requestString isEqualToString:@"https://shop.cguoguo.com/index.php/C/Index/index.html"]) {
        firstButton.hidden =1;
    }
  
    NSString *protocol = @"js-call://";
    
    NSLog(@"%@",requestString);
    
  
    if ([requestString hasPrefix:protocol]) {
        
         requestString = [self URLDecodedString:requestString];
        
    
        NSString *requestContent = [requestString substringFromIndex:[protocol length]];
        

        NSArray *vals = [requestContent componentsSeparatedByString:@"*"];
        
        if ([[vals objectAtIndex:0] isEqualToString:@"goodsShare"]) {
         
            shareArray = vals;
            
            [self shareClick];
        
        }
       
        return NO;
    }
    return YES;
}



- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
   
    NSArray *nCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate saveCookies:nCookies];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
