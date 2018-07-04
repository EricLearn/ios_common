
#import "NSUtil.h"
#import "UIExpand.h"
#import "DelayImageView.h"
#import <objc/runtime.h>

//
@implementation DelayImageView
@synthesize url=_url;
@synthesize def=_def;

static NSOperationQueue *_queue;

+ (NSOperationQueue *)operationQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 10;
    });
    return _queue;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        overlay = [[UIImageView alloc] initWithFrame:self.bounds];
        overlay.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:overlay];
        overlay.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        overlay.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.6f];
        overlay.hidden = YES;
        
        _selected = NO;
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        
        [self bringSubviewToFront:overlay];
    }
    
    return self;
}

- (void)addTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
    self.userInteractionEnabled = YES;
}

- (void)setClickOverlayMask:(UIImage *)mask {
    if (!mask) {
        //self.down = YES;
        return;
    }
    
    overlay.image = mask;
    overlay.backgroundColor = [UIColor clearColor];
    self.down = NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _selected = !_selected;
    
    if (_target) {
        if (_down) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop
        }
        else {
            //self.alpha = 0.75;
            [self bringSubviewToFront:overlay];
            overlay.hidden = NO;
        }
    }
    else {
        [super touchesBegan:touches withEvent:event];
    }
}

//
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    BOOL inside = NO;
    if ((touchPoint.x <= self.frame.size.width && touchPoint.x >= 0) && (touchPoint.y <= self.frame.size.height && touchPoint.y >= 0))
    {
        inside = YES;
    }
    
    //self.alpha = 1;
    overlay.hidden = YES;
    
    if (_target && !_down && inside)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop
    }
    else
    {
        [super touchesEnded:touches withEvent:event];
    }
}

//
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_target)
    {
        //self.alpha = 1;
        overlay.hidden = YES;
    }
    [super touchesCancelled:touches withEvent:event];
}

//
- (void)stopAnimating
{
    [_activityView stopAnimating];
    [_activityView removeFromSuperview];
    _activityView = nil;
}

//
- (void)startAnimating
{
    [self stopAnimating];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:_activityView];
    [_activityView startAnimating];
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    
    if (_imageLoadFinish) {
        _imageLoadFinish(self);
    }
}

//
- (void)downloaded:(NSData *)data {
    [self stopAnimating];
    if (data) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(image)
                {
                   self.image = image;
                }
                if (self.image)
                {
                    CGFloat alpha = self.alpha;
                    self.alpha = 0;
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.3];
                    self.alpha = alpha;
                    [UIView commitAnimations];
                }
            });
        });
    }
    else {
        self.image = [self placeholderImage];
    }
}

//
- (void)setUrl:(NSString *)url
{
    _force = NO;
    self.image = [UIImage imageWithColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.3]];
    if (url.length) {
        _url = url;
        [self startAnimating];
        __weak typeof(self) weak = self;
        [self sd_setImageWithURL:[NSURL URLWithString:_url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [weak stopAnimating];
            if (error) {
                self.image = [self placeholderImage];
                _url = nil;
            }
        }];
    }
    else
    {
        self.image = [self placeholderImage];
        _url = nil;
    }
}

- (UIImage *)placeholderImage
{
    UIImage * image = [UIImage imageNamed:_def.length ? _def : @"previewpic"];
    return image;
}

//
- (id)initWithUrl:(NSString *)url frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.url = url;
    return self;
}

- (void)cancelImageRequestOperation {
    
}

// 
- (void)dealloc
{
    /*[self cancelImageRequestOperation];
    [_request cancel];
    _request = nil;*/
}
@end
