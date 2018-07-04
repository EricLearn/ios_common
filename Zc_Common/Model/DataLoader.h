//
//  DataLoader.h
//  ZCEJ
//
//  Created by Fred on 15-05-26.
//  Copyright (c) 2015年 xtownmobile.com. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef enum {
    LoginIdentityUnLogin = 0,//未登陆
    LoginIdentityStudent = 1,//学生
    LoginIdentityStaff = 2,//教职工
    LoginIdentityParents = 3,//家长
    LoginIdentityEnterprise = 4,//企业
    LoginIdentityUnverified,//未验证
    
} LoginIdentityType;

@interface DataLoader : NSObject
{
    NSMutableArray   *_tasks;
    NSOperationQueue *_taskQueue;
}

@property (nonatomic, assign)BOOL logined;
@property (nonatomic, strong)NSString *userId;
@property (nonatomic, strong)NSString *userToken;
@property (nonatomic, strong)NSMutableDictionary *userInfo;
@property (nonatomic, assign)LoginIdentityType identityType;
@property (nonatomic, strong)NSString *aboutUrl;
@property (nonatomic, strong)NSString *integralUrl;
@property (nonatomic, strong)NSString *contributeUrl;
@property (nonatomic, strong)NSString *after_saleUrl;
@property (nonatomic, strong)NSString *operateUrl;
@property (nonatomic, strong)NSString *updateObject;
@property (nonatomic, strong)NSString *deviceToken;
@property (nonatomic, strong)NSString *ecard;
@property (nonatomic, strong)NSString *payCenterUrl;
@property (nonatomic, assign)NSInteger newFriend;
/**
 配置内容
 */
@property (nonatomic, strong)NSDictionary *config;
@property (nonatomic, strong)NSDictionary *userAddress;
@property (nonatomic, assign)NSInteger cartNumber;
@property (nonatomic, strong)NSString *commonQA;
@property (nonatomic, strong)NSString *registerQA;
/**
 模块点击次数统计
 */
@property (nonatomic, strong)NSMutableDictionary *channelStat;
/**
 定制tabar的时候，是否配有生活模块
 */
@property (nonatomic, assign)BOOL openLife;
/**
 set接口返回的定制tabar的数据
 */
@property (nonatomic, strong)NSArray *tabarIconData;

/**
 测试代码：用于便捷更换域名
 */
@property (nonatomic, strong)NSString *testServerUrl;
/**
 测试代码：用于便捷更换商城域名
 */
@property (nonatomic, strong)NSString *testMallUrl;
/**
 测试代码：用于便捷更换新生域名
 */
@property (nonatomic, strong)NSString *testFreshmanUrl;
/**
 测试代码：用于便捷更换学校code
 */
@property (nonatomic, strong)NSString *testSchoolCode;

+ (DataLoader *)loader;

+ (NSString *)getDateStr:(long long int)inteverl formatStyle:(NSString *)format;

+ (NSString*)getDateTimeIntervalStr:(long long int)startInteverl startStyle:(NSString*)statrtFormat endInteverl:(long long int)endInteverl endStyle:(NSString*)endFormat;

+ (NSString *)filterCount:(long)count;

+ (NSString *)timeInterval:(long long int)interval;

- (void)startTask:(TaskOrMethodType)type andDelegate:(id <TaskDelegate>)delegate andParams:(id)params;

- (void)closeTaskWithDelegate:(id)delegate;

- (void)closeTask:(Task *)task;

- (NSString *)passwordMD5:(NSString *)password;

- (void)logout;
/**
 上传模块点击次数
 */
- (void)upadloadChannelStat;

/**
 获取验证码规则
 1、md5(手机id取后4位+前4位), 得到A 小写
 2、3des（A+验证码+手机号码）
 3、服务端检验手机唯一标识是否正确，校验验证码是否正确

 @return 加密文本
 */
- (NSString *)codeVerifyA;


- (NSString *)getVrifyImageUrl;

/**
 *  格式化券码
 *
 *  @param str 券码
 *
 *  @return 格式化后的券码
 */
+ (NSString *)formatCardVoucher:(NSString *)str;

/**
 四舍五入

 @param num 完整数据
 @param scale 保留小数点
 @return 新的数据
 */
+ (CGFloat)roundWithNum:(CGFloat)num scale:(short)scale;
@end
