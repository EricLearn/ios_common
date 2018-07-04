 //
//  ContentWebView.m


#import "ContentWebView.h"
#import "BaseController.h"
#import "WebController.h"

#import "NSUtil.h"
#import "PhotoItem.h"
#import "PhotoBrowser.h"

#import <Toast/UIView+Toast.h>
#import <Masonry.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface ContentWebView ()

@property (nonatomic ,strong)JSContext *context;
@property (nonatomic ,strong)UIActivityIndicatorView *placeholderView;
@end

@implementation ContentWebView

//string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
+ (NSString *)getHtmlString:(NSString *)string
{
    NSString *path = NSUtil::BundlePath(@"webFunction.js");
    NSString *function = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding];
    NSString *html = [NSString stringWithFormat:
                      @"<html>"
                      @"<head>"
                      @"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"/>"
                      @"<head>"
                      @"<body><font><span style=\"font-size:18px;\">%@</span></font>"
                      @"<script type=\"text/javascript\">%@</script>"
                      @"</body>"
                      @"</html>",
                      string,function];
    return html;
}

- (void)dealloc {
    //[self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.scrollEnabled = NO;
        
        //self.layer.borderWidth = 1;
        //self.layer.borderColor = [UIColor blackColor].CGColor;
        
        __weak typeof(self) weak = self;
        self.context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        self.context[@"xt_changecontentheight"] = ^(){
            [weak getContentHeight];
        };
        self.context[@"xt_gethtmlimage"] = ^(NSString *images) {
            [weak getAllImage:images];
        };
        self.context[@"xt_consoleLog"] = ^(NSString *string) {
            NSLog(@"consoleLog: %@",string);
        };
    }
    return self;
}

- (void)setHtmlString:(NSString *)htmlString {
    _htmlString = htmlString;
    [self loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] resourcePath] isDirectory:YES]];
    //NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"article.html"];
    //[self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}

- (void)getAllImage:(NSString *)urlResurlt {
    NSMutableArray * urlArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
    [self.images removeAllObjects];
    
    for (int i = 0; i < urlArray.count - 1; i++) {
        PhotoItem *item = [[PhotoItem alloc] init];
        item.url = urlArray[i];
        [self.images addObject:item];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *urlA = request.URL.absoluteString;
    NSRange range = [urlA rangeOfString:@"myweb:imageClick:"];
    if (range.location != NSNotFound) {
        NSString *imgUrl = [urlA substringFromIndex:range.location + range.length];
        int index = 0;
        for (int i = 0; i < self.images.count; i++) {
            PhotoItem *item = self.images[i];
            if ([item.url isEqualToString:imgUrl]) {
                index = i;
                break;
            }
        }
        if (_images.count) {
            if (_otherWayShowImages) {
                _otherWayShowImages(_images,index);
            }
            else {
                PhotoBrowser *browser = [[PhotoBrowser alloc] initWithPhotos:self.images firstPhotoIndex:index withType:ShowType];
                [browser show];
            }
        }
        return NO;
    }
    
    NSURL *URL = request.URL;
    NSString *url = [URL absoluteString];
    NSString *scheme = [[URL scheme] lowercaseString];
    NSString *host = [[URL host] lowercaseString];
    
    UITabBarController *tabbar = (UITabBarController *)UIUtil::Delegate().window.rootViewController;
    
    BaseController *bas = nil;
    
    UIViewController *control = tabbar.currentViewController;
    if ([control isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)control;
        if ([nav.topViewController isKindOfClass:[BaseController class]]) {
            bas = (BaseController *)nav.topViewController;
        }
    }
    
    if (bas) {
        if ([scheme isEqualToString:@"accessresource"] && [host isEqualToString:@"gotopage"]) {
            [bas getAssignControllerOfRuleString:url];
            return NO;
        }
        if ([url rangeOfString:@"http"].length != 0) {
            WebController *vc = [[WebController alloc] initWithUrl:url];
            [bas.navigationController pushViewController:vc animated:YES];
            return NO;
        }
    }
    return YES;
}

- (UIActivityIndicatorView *)placeholderView {
    if (_placeholderView == nil) {
        _placeholderView =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_placeholderView];
        
        [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.offset(20);
            make.centerX.centerY.mas_equalTo(self);
        }];
    }
    return _placeholderView;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.placeholderView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.placeholderView stopAnimating];
    [self changeHeight];
}

- (void)getContentHeight {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeHeight];
    });
}

- (void)changeHeight {
    float height = [[self stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    if (_changeContentSize) {
        _changeContentSize(height);
    }
}

- (NSMutableArray *)images{
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}

@end
