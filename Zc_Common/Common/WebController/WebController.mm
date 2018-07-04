
#import "WebController.h"
#import "UIUtil.h"
#import "Category.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "WebExportBridging.h"

@interface WebController()
{
  
}
@property (nonatomic, strong) NSString *photoType;
@property (nonatomic ,strong) JSContext *context;
@end

@implementation WebController
@synthesize URL=_URL;
@synthesize openInNewWindow=_openInNewWindow;

#pragma mark Generic methods

- (instancetype)init {
    self = [super init];
    if (self) {
       _parseTitle = YES;
    }
    return self;
}

// Contructor
- (id)initWithURL:(NSURL *)URL {
	self = [super init];
	_URL = URL;
    _parseTitle = YES;
	return self;
}

// Contructor
- (id)initWithUrl:(NSString *)url {
	return [self initWithURL:[NSURL URLWithString:url]];
}

// Destructor
- (void)dealloc {
	if (_loading) UIUtil::ShowNetworkIndicator(NO);
}

//
- (UIWebView *)webView {
	return (UIWebView *)self.view;
}

//
- (NSString *)url {
	return self.URL.absoluteString;
}

//
- (void)setUrl:(NSString *)url {
	self.URL = [NSURL URLWithString:url];
}

//
- (void)setURL:(NSURL *)URL {
	if (URL != _URL) {
		_URL = URL;
	}
	if (URL) [self.webView loadRequest:[NSURLRequest requestWithURL:_URL]];
}

//
- (NSString *)HTML {
	return [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
}

//
- (void)setHTML:(NSString *)HTML {
	[self.webView loadHTMLString:HTML baseURL:nil];
}

//
- (void)loadHTML:(NSString *)HTML baseURL:(NSURL *)baseURL
{
	[self.webView loadHTMLString:HTML baseURL:baseURL];
}

#pragma mark View methods
//
- (void)loadView {
	UIWebView *webView = [[UIWebView alloc] initWithFrame:UIUtil::AppFrame()];
	//webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	webView.scalesPageToFit = !_noScalesPageToFit;
	webView.delegate = self;
	self.view = webView;
    
    [self getCloseItem];
    [self getBackItem];
}

- (void)getBackItem {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"nav_icon_back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)getCloseItem {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"web_icon_delete"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pop {
    UIWebView *view = [self webView];
    
    if ([view canGoBack]) {
        [view goBack];
    }
    else {
        [self close];
    }
}

// Do additional setup after loading the view.
- (void)viewDidLoad {
	[super viewDidLoad];
	self.URL = _URL;
}

//
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	if (_loading++ == 0) UIUtil::ShowNetworkIndicator(YES);
    if (self.parseTitle) {
        self.title = NSLocalizedString(@"Loading...", @"加载中⋯");
    }
}

- (NSString *)getUrlValueByKey:(NSString *)key url:(NSString *)url
{
    NSRange range = [url rangeOfString:key];
    if(range.location == NSNotFound)
        return nil;
    NSString * subString = [url substringFromIndex:range.location + range.length];
    NSRange range2 = [subString rangeOfString:@"&"];
    if(range2.location == NSNotFound)//说明是最后一个value
    {
        return subString;
    }
    NSString * value = [subString substringToIndex:range2.location];
    return value;
}

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if (_loading != 0) _loading--;
	if (_loading == 0) UIUtil::ShowNetworkIndicator(NO);
    if (self.parseTitle)
    { 
        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
	//[self.navigationItem setRightBarButtonItem:_rightButton animated:YES];

	_rightButton = nil;
}

//
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self webViewDidFinishLoad:webView];
	if (error.code != -999)
	{
#ifdef _WebViewInlineError
		NSString *string = [NSString stringWithFormat:
							@"<head>"
							@"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"/>"
							@"<title>%@</title>"
							@"<head>"
							@"<body>%@</body>",
							NSLocalizedString(@"Error", @"错误"),
							error.localizedDescription];
		
		[((UIWebView *)self.view) loadHTMLString:string baseURL:nil];
#else
        [self alertWithTitle:error.localizedDescription];
#endif
	}
}
@end
