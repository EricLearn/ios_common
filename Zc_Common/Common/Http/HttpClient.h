//
//  HttpClient.h
//  Zc_Common
//
//  Created by Eric on 2018/6/6.
//  Copyright © 2018年 EricDu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpClient : NSObject
{
    NSMutableArray *_taskQueue;
}
@property (nonatomic ,strong)NSString *userAgent;

+ (instancetype)sharedInstance;

@end
