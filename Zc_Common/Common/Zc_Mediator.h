//
//  Zc_Mediator.h
//  Zc_Common
//
//  Created by Eric on 2018/6/4.
//  Copyright © 2018年 EricDu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Zc_Mediator : NSObject

+ (instancetype)sharedInstance;

// 远程App调用入口
- (id)performActionWithUrl:(NSURL *)url completion:(void(^)(NSDictionary *info))completion;
// 本地组件调用入口
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;
- (void)releaseCachedTargetWithTargetName:(NSString *)targetName;

@end
