//
//  Task.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ApiLoadHelper.h"



@interface Task : NSObject<UIAlertViewDelegate>
{
    TaskOrMethodType type;
    id paramsObject;
    NSString *guid;

    NSURLSessionDataTask *realSession;
}

@property (nonatomic, /*unsafe_unretained*/weak) id <TaskDelegate> delegate;
@property (nonatomic, readonly) TaskOrMethodType type;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, readonly) NSURLSessionDataTask *realSession;

- (instancetype)initSessionWihtType:(TaskOrMethodType)taskType andDelegate:(id <TaskDelegate>)theDelegate andParams:(id)theParamsObject;

@end
