//
//  HttpHelper.h
//  Zc_Common
//
//  Created by Eric on 2018/6/6.
//  Copyright © 2018年 EricDu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;

@interface HttpHelper : NSObject

+ (NSString *)getUserAgent;

+ (AFHTTPSessionManager *)setRequestSerializerHeader:(AFHTTPSessionManager *)session;
@end
