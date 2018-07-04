//
//  TaskModel.h
//  Zc_Common
//
//  Created by Eric on 2018/6/6.
//  Copyright © 2018年 EricDu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TaskFinishBlock)(NSObject *result);

@protocol TaskDelegate <NSObject>

- (void)taskStarted;
- (void)taskFinished:(id)result;
- (void)taskIsCanceled;

@end

@interface TaskModel : NSObject

@property (nonatomic ,strong)NSURLSessionDataTask *task;
@property (nonatomic ,weak) id <TaskDelegate> delegate;
@property (nonatomic ,weak) TaskFinishBlock finishBlock;
@end
