//
//  WebExportBridging.h
//  ZCEJ
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol WebExport <JSExport>
- (void)backToNative:(NSString *)string;
@end

@interface WebExportBridging : NSObject <WebExport>

@property (nonatomic ,copy)void (^block_backToNative)(NSString *);

@end


