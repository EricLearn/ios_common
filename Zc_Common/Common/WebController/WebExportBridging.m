//
//  WebExportBridging.m
//  ZCEJ
//

#import "WebExportBridging.h"

@implementation WebExportBridging

- (void)dealloc {
    
}

/**
 农商银行回退回调

 @param string 回退地址
 */
- (void)backToNative:(NSString *)string {
    if (_block_backToNative) {
        _block_backToNative(string);
    }
}
@end
