//
//  HttpHelper.m
//  Zc_Common
//
//  Created by Eric on 2018/6/6.
//  Copyright © 2018年 EricDu. All rights reserved.
//

#import "HttpHelper.h"
#import "NSUtil.h"
#import "HttpClient.h"

#import "KeyChainGuid.h"

#import <AFNetworking.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonCryptor.h>

static const char* JAILBREAK_APPS[] =
{
    "/Applications/Cydia.app",
    "/Applications/limera1n.app",
    "/Applications/greenpois0n.app",
    "/Applications/blackra1n.app",
    "/Applications/blacksn0w.app",
    "/Applications/redsn0w.app",
    NULL,
};

@implementation HttpHelper

+ (NSString *)getUserAgent {
    //User-Agent: <手机/终端型号>/<软件版本号> (<终端操作系统>;<终端操作系统版本号>;<屏幕尺寸>;<破解>;<运营商>;<联网方式>)
    //如：“iPhone 3/2.0 (ios;4.3;320x480;s;46000;wifi)”
    NSMutableString* strAgent = [[NSMutableString alloc] initWithCapacity:128];
    UIDevice *device = [UIDevice currentDevice];
    
    [strAgent appendString:device.model];
    [strAgent appendString:@"/"];
    
    NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [strAgent appendString:[versionStr length] ? versionStr:@"1.0"];
    
    [strAgent appendString:@" ("];
    [strAgent appendString:device.systemName];
    [strAgent appendString:@";"];
    [strAgent appendString:device.systemVersion];
    [strAgent appendString: @";"];
    
    CGSize screenSize = [[[UIScreen mainScreen] currentMode] size];
    NSString *screenSizeStr = [[NSString alloc] initWithFormat:@"%dx%d", (int)screenSize.width, (int)screenSize.height];
    [strAgent appendString:screenSizeStr];
    
    [strAgent appendString: @";"];
    
    // 判断是否越狱
    NSString *jailbreak = @"s";
    for (int i = 0; JAILBREAK_APPS[i] != NULL; ++i)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:JAILBREAK_APPS[i]]]) {
            jailbreak = @"p";
            break;
        }
    }
    [strAgent appendString:jailbreak];
    
    // 取营运商
    NSString *strProvider = @"";
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    if (carrier) {
        strProvider = [[NSString alloc] initWithFormat:@"%@%@", carrier.mobileCountryCode, carrier.mobileNetworkCode];
    }
    
    [strAgent appendString:@";"];
    [strAgent appendString:strProvider];
    
    [strAgent appendString:NSUtil::IsWiFiAvailable()?@";wifi":@";wwan"];
    
    [strAgent appendString: @")"];
    
    return strAgent;
}

+ (AFHTTPSessionManager *)setRequestSerializerHeader:(AFHTTPSessionManager *)session {
    NSString *userAgent = [HttpClient sharedInstance].userAgent;
    if (userAgent.length) {
        [session.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    UIDevice *device = [UIDevice currentDevice];
    NSString *DevicesId = [NSString stringWithFormat:@"%@/%@",device.model,[KeyChainGuid getGuid]];
    if (DevicesId) {
        [session.requestSerializer setValue:DevicesId forHTTPHeaderField:@"DevicesId"];
    }
    return session;
}
@end
