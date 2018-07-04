//
//  DataLoader.mm
//  ZCEJ
//
//  Created by Fred on 15-05-26.
//  Copyright (c) 2015年 xtownmobile.com. All rights reserved.
//

#import "DataLoader.h"
#import "AppDelegate.h"

#import "TabBarModel.h"

//#import <CoreTelephony/CTCarrier.h>
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonCryptor.h>

#import <Security/Security.h>

#define kMaxTaskCount 10

@implementation DataLoader

@synthesize logined = _logined , channelStat = _channelStat;

static DataLoader *loader = nil;

+ (NSString *)getDateStr:(long long int)inteverl formatStyle:(NSString *)format {
    inteverl = inteverl / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:inteverl];
    static NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0]; //todo:根据服务器调整
//    [formatter setTimeZone:GTMzone];
    [formatter setDateFormat:format];
    NSString *dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}

+(NSString *)getDateTimeIntervalStr:(long long int)startInteverl startStyle:(NSString *)statrtFormat endInteverl:(long long int)endInteverl endStyle:(NSString *)endFormat
{
    NSMutableString *result = [NSMutableString string];
    NSString *format = @"yyyy-MM-dd";
    NSString *start = [DataLoader getDateStr:startInteverl formatStyle:format];
    NSString *end = [DataLoader getDateStr:endInteverl formatStyle:format];
    BOOL sameDay = [start isEqualToString:end];
    
    start = [DataLoader getDateStr:startInteverl formatStyle:statrtFormat];
    if (endInteverl) {
        end =[DataLoader getDateStr:endInteverl formatStyle:endFormat];
        if (sameDay) {
            return start;
        }
        [result appendFormat:@"%@ ~ %@",start,end];
    }
    else {
        [result appendString:start];
    }
    return result;
}

+ (NSString *)timeInterval:(long long int)interval
{
    interval = interval / 1000;
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger inter = [zone secondsFromGMTForDate:[NSDate date]];
//    NSDate *currentDate = [[NSDate date] dateByAddingTimeInterval: inter];
    NSDate *currentDate = [NSDate date];
    int ct = (int)interval / 86400;
    int nt = [currentDate timeIntervalSince1970] / 86400;
    
    if (nt - ct == 0) {
        int hour = ([currentDate timeIntervalSince1970] - interval) / 3600;
        if (hour == 0) {
            int minute = ([currentDate timeIntervalSince1970] - interval) / 60;
            if (minute <= 0) {
                return @"刚刚";
            }
            return [NSString stringWithFormat:@"%d分钟前", minute];
        }
        else {
            return [NSString stringWithFormat:@"%d小时前", hour];
        }
    }
    else if (nt - ct == 1){
        return @"昨天";
    }
    else if (nt - ct == 2){
        //return [NSString stringWithFormat:@"%d天前", nt - ct];
        return @"前天";
    }
    else {
        return [DataLoader getDateStr:interval*1000 formatStyle:@"yyyy-MM-dd"];
    }
    return @"";
}

+ (NSString *)filterCount:(long)count {
    NSString *title = @"0";
    if (count) {
        //处理数字大于1W
        if (count>=10000) {
            double wan=count/10000.0;
            title=[NSString stringWithFormat:@"%.1fw",wan];
            title=[title stringByReplacingOccurrencesOfString:@".0" withString:@""];
        }else{
            title=[NSString stringWithFormat:@"%lu",count];
        }
    }
    
    return title;
}

+ (DataLoader *)loader
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[DataLoader alloc] init];
    });
    return loader;
}

- (id)init
{
    self = [super init];
    if (self) {
        _taskQueue = [[NSOperationQueue alloc] init];
        [_taskQueue setMaxConcurrentOperationCount:kMaxTaskCount];
        _tasks = [NSMutableArray arrayWithCapacity:kMaxTaskCount];
    }
    return self;
}

- (void)setTabarIconData:(NSArray *)tabarIconData {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:tabarIconData.count];
    for (NSDictionary *item in tabarIconData) {
        TabBarModel *model = [[TabBarModel alloc] initWithData:item];
        [temp addObject:model];
    }
    _tabarIconData = temp;
}

#pragma mark TaskHelper
- (void)startTask:(TaskOrMethodType)type andDelegate:(id <TaskDelegate>)delegate andParams:(id)params
{
    [self closeTaskWithType:type delegate:delegate];
    Task *task = [[Task alloc] initSessionWihtType:type andDelegate:delegate andParams:params];
    if (type > TaskOrMethod_None && type < TaskOrMethod_PostSomeObject) {
        // add normal api task to taskqueue.
        [_tasks addObject:task];
    }
}

- (void)closeTaskWithType:(TaskOrMethodType)type delegate:(id)delegate {
    for (Task *task in _tasks)
    {
        if (task.delegate == delegate && type == task.type) {
            [self closeTask:task];
            break;
        }
    }
}

- (void)closeTaskWithDelegate:(id)delegate {
    for (int index = 0; index < [_tasks count]; index++)
    {
        Task *task = _tasks[index];
        if (task.delegate == delegate) {
            [self closeTask:task];
        }
    }
}

- (void)closeTask:(Task *)task {
    if (task.realSession) {
        [task.realSession cancel];
        task.delegate = nil;
    }
    [_tasks removeObject:task];
}

#pragma mark 用户操作
- (BOOL)logined {
    return _userToken && _userToken.length;
}

- (NSString *)passwordMD5:(NSString *)password {
    NSString *string = [@"jw134#%pqNLVfn" stringByAppendingString:password];
    NSString *first = [NSUtil::MD5(string) lowercaseString];
    NSString *newPassword = [NSUtil::MD5(first) lowercaseString];
    return newPassword;
}

- (void)logout {
    _userId = nil;
    _userInfo = nil;
    _userToken = nil;
    _identityType = LoginIdentityUnLogin;
    
    if (NSUtil::IsPathExist(NSUtil::DocumentPath(kUserInfoPath))) {
        NSUtil::RemovePath(NSUtil::DocumentPath(kUserInfoPath));
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateChangeNotification object:nil];
}

#pragma mark 模块点击次数统计

- (NSString *)channelStatPath {
    NSString *path = NSUtil::CachePath(@"channelStat");
    if (NSUtil::IsFileExist(path) == NO) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    return path;
}

- (void)setChannelStat:(NSMutableDictionary *)channelStat {
    _channelStat = channelStat;
    [channelStat writeToFile:[self channelStatPath] atomically:YES];
}

- (NSMutableDictionary *)channelStat {
    if (_channelStat == nil) {
        NSMutableDictionary *temp = [NSDictionary dictionaryWithContentsOfFile:[self channelStatPath]].mutableCopy;
        if (temp == nil) {
            temp = [NSMutableDictionary dictionary];
        }
        _channelStat = temp;
    }
    return _channelStat;
}

- (void)upadloadChannelStat {
    NSDictionary *param = [NSDictionary dictionaryWithContentsOfFile:[self channelStatPath]];
    [[NSFileManager defaultManager] removeItemAtPath:[self channelStatPath] error:nil];
    if (param) {
        [[DataLoader loader] startTask:TaskOrMethod_app_appmenubar_columnOneClick andDelegate:nil andParams:@{@"data":NSUtil::dictionaryToJson(param)}];
    }
}

#pragma mark Helper
- (NSString *)codeVerifyA {
    NSString *uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    uuid = uuid.length > 8 ? uuid : @"hsejsendsms";
    NSString *idString = @"";
    if (uuid.length > 8) {
        idString = [[uuid substringFromIndex:uuid.length - 4] stringByAppendingString:[uuid substringToIndex:4]];
        idString = [NSUtil::MD5(idString) lowercaseString];
    }
    return idString;
}

- (NSString *)getVrifyImageUrl {
    return [NSString stringWithFormat:@"%@user/verifyimage?imei=%@&time=%@",kServerUrl,[[UIDevice currentDevice].identifierForVendor UUIDString],NSUtil::FormatDate([NSDate date], @"yyyy-MM-ddHH:mm:ss")];
}

- (NSDictionary *)getPlistData {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"hsej-Info" ofType:@"plist"];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    return dataDic;
}

+ (NSString *)formatCardVoucher:(NSString *)str {
    if([str length]==12) {
        NSString * subStr1 = [str substringWithRange:NSMakeRange(0, 4)];
        NSString * subStr2 = [str substringWithRange:NSMakeRange(4, 4)];
        NSString * subStr3 = [str substringWithRange:NSMakeRange(8, 4)];
        return [NSString stringWithFormat:@"%@ %@ %@",subStr1,subStr2,subStr3];
    }
    return str;
}

+ (CGFloat)roundWithNum:(CGFloat)num scale:(short)scale {
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",num]];
    return [decimalNum decimalNumberByRoundingAccordingToBehavior:handler].floatValue;
}
@end
