
#import <UIKit/UIKit.h>
#import "BaseController.h"
//
@interface WebController : BaseController <UIWebViewDelegate>
{
	NSURL *_URL;
	NSUInteger _loading;
	UIBarButtonItem *_rightButton;
	BOOL _openInNewWindow;
}

@property(nonatomic,retain) NSURL *URL;
@property(nonatomic,retain) NSString *url;
@property(nonatomic,assign) NSString *HTML;
@property(nonatomic,readonly) UIWebView *webView;
@property(nonatomic,assign) BOOL openInNewWindow;
@property(nonatomic,assign) BOOL parseTitle;
@property(nonatomic,assign) BOOL noScalesPageToFit;

- (id)initWithURL:(NSURL *)URL;
- (id)initWithUrl:(NSString *)url;
- (void)loadHTML:(NSString *)HTML baseURL:(NSURL *)baseURL;

@end
