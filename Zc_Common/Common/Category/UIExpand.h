
#import <UIKit/UIKit.h>

typedef enum {
    Line_Top,
    Line_Bottom,
    Line_Left,
    Line_Right,
}LinePosition;

@interface UIScrollView (Category)

@end

//
@interface UIImage (ImageExpand)
+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)scaleImageToSize:(CGSize)size;
- (UIImage *)cropImageInRect:(CGRect)rect;
//- (UIImage *)cropImageToRect:(CGRect)rect;
- (UIImage *)maskImageWithImage:(UIImage *)mask;
- (CGAffineTransform)orientationTransform:(CGSize *)newSize;
- (UIImage *)straightenAndScaleImage:(NSUInteger)maxDimension;
+ (UIImage *)codeImageWithString:(NSString *)string size:(CGFloat)size;
@end


//
@interface UIView (ViewEx)
- (void)removeSubviews;
- (UIView *)findFirstResponder;
- (UIView *)findSubview:(NSString *)cls;

- (void)addLine:(LinePosition )position gap:(CGFloat)gap;

- (void)fadeForAction:(SEL)action target:(id)target;
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration;
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration delay:(CGFloat)delay;
@end

@interface UIView (SegmentFrame)

@property (nonatomic, assign) CGFloat zj_x;
@property (nonatomic, assign) CGFloat zj_width;
@end


@interface UIButton(Under)

- (void)textUnderImageButton;

@end
