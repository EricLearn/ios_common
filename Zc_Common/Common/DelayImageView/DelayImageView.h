
#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

//
@interface DelayImageView: UIImageView
{
    BOOL _force;
    BOOL _loaded;
    NSString *_url;
    NSString *_def;
    UIActivityIndicatorView *_activityView;
    
    BOOL _down;
    __weak id _target;
    SEL _action;
    UIImageView *overlay;
    BOOL _selected;
    int _tryCount;
    
}

- (id)initWithUrl:(NSString *)url frame:(CGRect)frame;
- (void)addTarget:(id)target action:(SEL)action;
- (void)setClickOverlayMask:(UIImage *)mask;

@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSString *def;
@property (nonatomic) BOOL down;
@property (nonatomic) BOOL selected;
@property (nonatomic,assign) UIButton *sender;

@property (nonatomic,copy)void (^imageLoadFinish)(DelayImageView *);

@end

