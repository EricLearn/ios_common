//
//  Task.mm

#import "Task.h"

#import "DataLoader.h"

#import "ApiLoadHelper.h"
#import "KeyChainGuid.h"

#import "GTMBase64.h"
#import "AppDelegate.h"
#import "BaseController.h"
#import "OnlineTabBarController.h"

#import <AFNetworking.h>

@implementation Task

@synthesize delegate, type, guid, realSession;

- (instancetype)initSessionWihtType:(TaskOrMethodType)taskType
                        andDelegate:(id<TaskDelegate>)theDelegate
                          andParams:(id)theParamsObject
{
    self = [super init];
    if (self) {
        type = taskType;
        delegate = theDelegate;
        
        [self taskStarted];
        
        if (type == TaskOrMethod_user_sendPhoneCode) {
            // 获取验证码 封装参数
            theParamsObject = [ApiLoadHelper setupVerifyCodeParams:theParamsObject];
        }
        NSString *url = [ApiLoadHelper getMethodUrl:taskType andParams:nil];
    
        AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] init];
        session.requestSerializer.timeoutInterval = 120;// kTimeOut;
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain",@"text/javascript", @"text/html", nil];
        
        [self setRequestSerializerHeader:session];
        
        if (type == TaskOrMethod_SaveOrders || type == TaskOrMethod_orders_saveNewOrders) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theParamsObject options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if (jsonString) {
                theParamsObject = @{@"content":jsonString};
            }
        }
        
        __weak typeof(self) weak = self;
        [session POST:url parameters:theParamsObject progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weak taskSuccess:task result:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weak taskFailure:task error:error];
        }];
    }
    return self;
}

- (void)taskSuccess:(NSURLSessionDataTask *)sessionTask result:(id)responseObject {
    //_Log(@"task-success :%@",responseObject);
    int code = 0;
    NSString *errorMsg = kErrorMeassage;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        code = [[responseObject objectForKey:@"result"] intValue];
        if (code != 1) {
            errorMsg = [responseObject objectForKey:@"msg"];
        }
    }
    if (code == 1) {
        if (type == TaskOrMethod_Login) {
            NSHTTPURLResponse *response = ((NSHTTPURLResponse *)[sessionTask response]);
            NSDictionary *headers = [response allHeaderFields];
            [DataLoader loader].userId = headers[@"XPS-UserId"];
            [DataLoader loader].userToken = headers[@"XPS-UserToken"];
            [DataLoader loader].userAddress = [responseObject objectForKey:@"userAddress"];
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)responseObject;
                if ([DataLoader loader].userToken && [DataLoader loader].userId && dict) {
                    NSDictionary *userInfo = dict[@"item"];
                    NSInteger verifyStatus = [userInfo[@"verifyStatus"] integerValue];
                    if (verifyStatus == 2) {
                        [DataLoader loader].identityType = (LoginIdentityType)[userInfo[@"userType"] integerValue];
                    }else {
                        [DataLoader loader].identityType = LoginIdentityUnverified;
                    }
                }
            }
        }
        else if (type == TaskOrMethod_Logout) {
            [DataLoader loader].userAddress = nil;
        }
        else if (type == TaskOrMethod_SaveShoppingCar
                 || type == TaskOrMethod_delShoppingCar
                 || type == TaskOrMethod_MallHomeHome) {
            NSInteger number = [responseObject[@"count"] integerValue];
            [DataLoader loader].cartNumber = number;
            [[NSNotificationCenter defaultCenter] postNotificationName:kShoppingCartNumberNotification object:@(number)];
        }
        [self taskFinished:responseObject];
    }
    else {
        NSError *error = [[NSError alloc] initWithDomain:@"Server error" code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorMsg, NSLocalizedDescriptionKey,nil]];
        [self taskFinished:error];
    }
    realSession = sessionTask;
}

- (void)taskFailure:(NSURLSessionDataTask *)sessionTask error:(NSError *)error {
    _Log(@"task-error :%@",error.localizedDescription);
    if ([error.description containsString:@"The Internet connection appears to be offline"]) {
        error = [[NSError alloc] initWithDomain:@"Server error" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"网络链接异常，请检查网络链接", NSLocalizedDescriptionKey,nil]];
    }
    else {
        error = [[NSError alloc] initWithDomain:@"Server error" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:kErrorMeassage, NSLocalizedDescriptionKey,nil]];
    }
    _Log(@"error: %@", error);
    [self taskFinished:error];
    realSession = sessionTask;
}

- (void)setRequestSerializerHeader:(AFHTTPSessionManager *)session {
    NSString *userAgent = [ApiLoadHelper getUserAgent];// TODO:缓存起来
    if (userAgent.length) {
        [session.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    UIDevice *device = [UIDevice currentDevice];
    NSString *DevicesId = [NSString stringWithFormat:@"%@/%@",device.model,[KeyChainGuid getGuid]];
    if (DevicesId) {
        [session.requestSerializer setValue:DevicesId forHTTPHeaderField:@"DevicesId"];
    }
    _Log(@"XPS-UserId:%@",[DataLoader loader].userId);
    if ([DataLoader loader].userId) {
        [session.requestSerializer setValue:[DataLoader loader].userId forHTTPHeaderField:@"XPS-UserId"];
    }
    
    if ([DataLoader loader].userToken) {
        [session.requestSerializer setValue:[DataLoader loader].userToken forHTTPHeaderField:@"XPS-Token"];
    }
    NSString *deviceToken = NSUtil::DefaultForKey(kDeviceTokenKey);
    deviceToken = deviceToken ? deviceToken : @"";
    if (deviceToken) {
        [session.requestSerializer setValue:deviceToken forHTTPHeaderField:@"XPS-PUSHID"];
    }
    // 身份证号 识别
    if ([DataLoader loader].logined && [ApiLoadHelper isApiMethod:type]) {
        NSString *sfzh = [[DataLoader loader].userInfo checkStringValueForKey:@"sfzh"];
        if (sfzh.length > 0) {
            [session.requestSerializer setValue:sfzh forHTTPHeaderField:@"XPS-SFZH"];
        }
    }
    // 客户端标示
    [session.requestSerializer setValue:[ApiLoadHelper clientCode] forHTTPHeaderField:@"XPS-ClientCode"];
}

// help functions.
- (void)taskStarted
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(taskStarted:)]) {
        [self.delegate taskStarted:type];
    }
}

- (void)taskFinished:(NSObject *)result
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(taskFinished: result:)]) {
        NSError *error;
        if ([result isKindOfClass:[NSError class]]) {
            error = (NSError *)result;
        }
        if (error && error.code == 99) {
            [[DataLoader loader] logout];
            [UIAlertView alertForUIAlertControllerWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"重新登录" otherButtonTitle:nil presentAtController:UIUtil::Delegate().window.rootViewController cancelButtonClick:^(UIAlertController *) {
                OnlineTabBarController*root = (OnlineTabBarController *)UIUtil::Delegate().window.rootViewController;
                [root seizeLogin];
            } otherButtonClick:^(UIAlertController *) {
                
            }];
            [self.delegate taskFinished:TaskOrMethod_None result:nil];
        }
        else {
            [self.delegate taskFinished:type result:result];
        }
    }
}

- (void)taskCanceled
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(taskIsCanceled:)]) {
        [self.delegate taskIsCanceled:type];
    }
}
@end
