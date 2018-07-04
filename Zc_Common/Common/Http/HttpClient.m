//
//  HttpClient.m
//  Zc_Common
//
//  Created by Eric on 2018/6/6.
//  Copyright © 2018年 EricDu. All rights reserved.
//

#import "HttpClient.h"
#import "HttpHelper.h"

#import <AFNetworking.h>

@implementation HttpClient

+ (instancetype)sharedInstance {
    static HttpClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[HttpClient alloc] init];
    });
    return client;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskQueue = [NSMutableArray array];
    }
    return self;
}

- (NSString *)userAgent {
    if (_userAgent == nil) {
        _userAgent = [HttpHelper getUserAgent];
    }
    return _userAgent;
}

- (void)closeTaskWithUrl:(NSString *)url {
    NSURLSessionDataTask *task = nil;
    for (NSURLSessionDataTask *sub in _taskQueue) {
        if ([sub.response.URL.absoluteString isEqualToString:url]) {
            task = sub;
            break;
        }
    }
    if (task) {
        [task cancel];
        [_taskQueue removeObject:task];
    }
}

- (void)reponseHandle:(NSObject *)result withTask:(NSURLSessionTask *)task {
    for (NSURLSessionDataTask *sub in _taskQueue) {
        if (sub.taskIdentifier == task.taskIdentifier) {
            
        }
    }
}

/**
 接口访问

 @param r_params 接口访问参数
 @param url 接口地址
 */
- (NSURLSessionDataTask *)startRequestTask:(NSDictionary *)r_params url:(NSString *)url   {

    [self closeTaskWithUrl:url];
    
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] init];
    session.requestSerializer.timeoutInterval = 30;
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain",@"text/javascript", @"text/html", nil];
    
    session = [HttpHelper setRequestSerializerHeader:session];
    
    // jsonstring 访问
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:r_params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (jsonString) {
        r_params = @{@"content":jsonString};
    }
    
    __weak typeof(self) weak = self;
    NSURLSessionDataTask *task = [session POST:url parameters:r_params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weak reponseHandle:responseObject withTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weak reponseHandle:error withTask:task];
    }];
    [_taskQueue addObject:task];
    return task;
}

- (void)Action_startRequestTask:(NSDictionary *)params {
    
    
    
}
@end
