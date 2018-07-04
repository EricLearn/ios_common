//
//  ContentWebView.h
 
 
#import <UIKit/UIKit.h>

@interface ContentWebView : UIWebView<UIWebViewDelegate>

@property (nonatomic ,copy)void (^changeContentSize)(CGFloat);
@property (nonatomic ,copy)void (^otherWayShowImages)(NSArray *images,int index);
@property (nonatomic ,strong)NSString *htmlString;
@property (nonatomic ,strong)NSMutableArray *images;

/**
 添加完整的Html代码

 @param string body内容
 @return html代码
 */
+ (NSString *)getHtmlString:(NSString *)string;

@end
