//

#import "UIExpand.h"
#import "UIUtil.h"
#import "NSUtil.h"
#import <Masonry.h>

@implementation UIScrollView (Category)

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

@end


#pragma mark UIImage methods

@implementation UIImage (ImageExpand)
//
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// Scale to specified size if needed
#define _Radians(d) (d * M_PI/180)
- (UIImage *)scaleImageToSize:(CGSize)size
{
    CGSize imageSize = self.size;
    if (size.width == 0)
    {
        if (imageSize.height)
        {
            size.width = (NSUInteger)(imageSize.width * size.height / imageSize.height);
        }
    }
    else if (size.height == 0)
    {
        if (imageSize.width)
        {
            size.height = (NSUInteger)(imageSize.height * size.width / imageSize.width);
        }
    }
    
    if ((size.width == imageSize.width) && (size.height == imageSize.height))
    {
        return self;
    }
    
    // Get scale
    CGFloat scale = UIUtil::ScreenScale();
    size.width *= scale;
    size.height *= scale;
    
    // Scale image
    CGImageRef imageRef = self.CGImage;
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    if (alphaInfo == kCGImageAlphaNone)
    {
        alphaInfo = kCGImageAlphaNoneSkipLast;
    }
    else if ((alphaInfo == kCGImageAlphaLast) || (alphaInfo == kCGImageAlphaFirst))
    {
        alphaInfo = kCGImageAlphaPremultipliedLast;
    }
    CGFloat bytesPerRow = 4 * ((size.width > size.height) ? size.width : size.height);
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                size.width,
                                                size.height,
                                                8, //CGImageGetBitsPerComponent(imageRef),    // really needs to always be 8
                                                bytesPerRow, //4 * thumbRect.size.width,    // rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo);
    
    //
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        {
            CGContextRotateCTM(bitmap, _Radians(90));
            CGContextTranslateCTM(bitmap, 0, -size.height);
            break;
        }
        case UIImageOrientationRight:
        {
            CGContextRotateCTM(bitmap, _Radians(-90));
            CGContextTranslateCTM(bitmap, -size.width, 0);
            break;
        }
        case UIImageOrientationUp:
        {
            break;
        }
        case UIImageOrientationDown:
        {
            CGContextTranslateCTM(bitmap, size.width, size.height);
            CGContextRotateCTM(bitmap, _Radians(-180.));
            break;
        }
        default:
        {
            break;
        }
    }
    
    // Draw into the context, this scales the image
    CGRect rect = {0, 0, size.width, size.height};
    CGContextDrawImage(bitmap, rect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *image;
    if (scale == 1)
    {
        image = [UIImage imageWithCGImage:ref];
    }
    else
    {
        image = [UIImage imageWithCGImage:ref scale:scale orientation:UIImageOrientationUp/*self.imageOrientation*/];
    }
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return image;
}


/*- (UIImage *)cropImageToRect:(CGRect)rect
 {
 CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
 
 CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
 CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
 CGContextRef bitmap = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
 
 switch (self.imageOrientation)
 {
 case UIImageOrientationLeft:
 {
 CGContextRotateCTM(bitmap, _Radians(90));
 CGContextTranslateCTM(bitmap, 0, -rect.size.height);
 break;
 }
 case UIImageOrientationRight:
 {
 CGContextRotateCTM(bitmap, _Radians(-90));
 CGContextTranslateCTM(bitmap, -rect.size.width, 0);
 }
 case UIImageOrientationUp:
 {
 break;
 }
 case UIImageOrientationDown:
 {
 CGContextTranslateCTM(bitmap, rect.size.width, rect.size.height);
 CGContextRotateCTM(bitmap, _Radians(-180.));
 break;
 }
 }
 
 CGContextDrawImage(bitmap, CGRectMake(0, 0, rect.size.width, rect.size.height), imageRef);
 CGImageRef ref = CGBitmapContextCreateImage(bitmap);
 
 UIImage *resultImage=[UIImage imageWithCGImage:ref];
 CGImageRelease(imageRef);
 CGContextRelease(bitmap);
 CGImageRelease(ref);
 
 return resultImage;
 }*/

- (UIImage *)cropImageInRect:(CGRect)rect
{
    UIImage *image;
    CGImageRef ref;
    CGFloat scale = UIScreen.mainScreen.scale;
    rect.origin.x *= scale;
    rect.origin.y *= scale;
    rect.size.width *= scale;
    rect.size.height *= scale;
    ref = CGImageCreateWithImageInRect(self.CGImage, rect);
    image = [UIImage imageWithCGImage:ref scale:scale orientation:self.imageOrientation];
    CGImageRelease(ref);
    return image;
}

//
- (UIImage *)maskImageWithImage:(UIImage *)mask
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, UIUtil::ScreenScale());
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    CGImageRef maskRef = mask.CGImage;
    CGImageRef maskImage = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                             CGImageGetHeight(maskRef),
                                             CGImageGetBitsPerComponent(maskRef),
                                             CGImageGetBitsPerPixel(maskRef),
                                             CGImageGetBytesPerRow(maskRef),
                                             CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask(self.CGImage, maskImage);
    CGImageRelease(maskImage);
    
    CGContextDrawImage(context, rect, masked);
    CGImageRelease(masked);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

//
- (CGAffineTransform)orientationTransform:(CGSize *)newSize
{
    CGImageRef img = self.CGImage;
    CGFloat width = CGImageGetWidth(img);
    CGFloat height = CGImageGetHeight(img);
    CGSize size = CGSizeMake(width, height);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat origHeight = size.height;
    switch (self.imageOrientation)
    {
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(width, 0.0f);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0f, height);
            transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
            break;
        case UIImageOrientationLeftMirrored:
            size.height = size.width;
            size.width = origHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            transform = CGAffineTransformRotate(transform, 3.0f * M_PI / 2.0f);
            break;
        case UIImageOrientationLeft:
            size.height = size.width;
            size.width = origHeight;
            transform = CGAffineTransformMakeTranslation(0.0f, width);
            transform = CGAffineTransformRotate(transform, 3.0f * M_PI / 2.0f);
            break;
        case UIImageOrientationRightMirrored:
            size.height = size.width;
            size.width = origHeight;
            transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0f);
            break;
        case UIImageOrientationRight:
            size.height = size.width;
            size.width = origHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0f);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0f);
            break;
        default:
            break;
    }
    *newSize = size;
    return transform;
}

//
- (UIImage *)straightenAndScaleImage:(NSUInteger)maxDimension
{
    CGImageRef img = self.CGImage;
    CGFloat width = CGImageGetWidth(img);
    CGFloat height = CGImageGetHeight(img);
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGSize size = bounds.size;
    if (width > maxDimension || height > maxDimension)
    {
        CGFloat ratio = width/height;
        if (ratio > 1.0f)
        {
            size.width = maxDimension;
            size.height = size.width / ratio;
        }
        else
        {
            size.height = maxDimension;
            size.width = size.height * ratio;
        }
    }
    CGFloat scale = size.width/width;
    
    CGAffineTransform transform = [self orientationTransform:&size];
    size.width *= scale;
    size.height *= scale;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip
    UIImageOrientation orientation = self.imageOrientation;
    if (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scale, scale);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scale, -scale);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, bounds, img);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)codeImageWithString:(NSString *)string size:(CGFloat)size {
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *outputImage=[filter outputImage];
    
    CGRect extent = CGRectIntegral(outputImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:outputImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
@end


#pragma mark UIImage methods

@implementation UIView (ViewEx)

//
- (void)removeSubviews
{
    while (self.subviews.count)
    {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

//
- (UIView *)findFirstResponder
{
    if ([self isFirstResponder]) {
        return self;
    }
    
    for (UIView *view in self.subviews)
    {
        UIView* ret = [view findFirstResponder];
        if (ret) {
            return ret;
        }
    }
    return nil;
}

//
- (UIView *)findSubview:(NSString *)cls
{
    for (UIView *child in self.subviews)
    {
        if ([child isKindOfClass:NSClassFromString(cls)]) {
            return child;
        }
        else {
            UIView *ret = [child findSubview:cls];
            if (ret) {
                return ret;
            }
        }
    }
    
    return nil;
}

- (void)addLine:(LinePosition )position left:(CGFloat)left right:(CGFloat)right {
    CGFloat lineWidth = 1;
    UIView *view = [UIView new];
    view.backgroundColor = [@"#ededed" toUIColor];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (position == Line_Top || position == Line_Bottom)
        {
            make.left.equalTo(self).mas_offset(left);
            make.right.equalTo(self).mas_offset(right);
            make.height.mas_equalTo(lineWidth);
            if (position == Line_Top)
            {
                make.top.equalTo(self);
            }
            else {
                make.bottom.equalTo(self);
            }
        }
        else {
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.width.mas_equalTo(lineWidth);
            if (position == Line_Left) {
                make.left.equalTo(self);
            }
            else {
                make.right.equalTo(self);
            }
        }
    }];
}

- (void)addLine:(LinePosition )position gap:(CGFloat)gap {
    [self addLine:position left:gap right:0];
}

//
- (void)fadeForAction:(SEL)action target:(id)target
{
    [self fadeForAction:action target:target duration:0.3];
}

//
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration
{
    [self fadeForAction:action target:target duration:duration delay:0];
}

//
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration delay:(CGFloat)delay
{
    [UIView beginAnimations:nil context:(void *)[[NSArray alloc] initWithObjects:target, [NSValue valueWithPointer:action], [NSNumber numberWithFloat:duration], [NSNumber numberWithFloat:delay], nil]];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadeInForAction: finished: context:)];
    self.alpha = (self.alpha == 0) ? 1 : 0;
    [UIView commitAnimations];
}

//
- (void)fadeInForAction:(NSString *)animationID finished:(NSNumber *)finished context:(NSArray *)context
{
    id target = [context objectAtIndex:0];
    NSValue *value = [context objectAtIndex:1];
    CGFloat duration = [[context objectAtIndex:2] floatValue];
    CGFloat delay = [[context objectAtIndex:3] floatValue];
    SEL action = (SEL)value.pointerValue;
    if (delay == 0)
    {
        [target performSelector:action withObject:self];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    if (delay != 0)
    {
        [UIView setAnimationDelay:delay];
        [UIView setAnimationDelegate:target];
        [UIView setAnimationDidStopSelector:action];
    }
    self.alpha = (self.alpha == 1) ? 0 : 1;
    [UIView commitAnimations];
}

@end

@implementation UIView (SegmentFrame)

- (CGFloat)zj_width {
    return self.frame.size.width;
}

- (CGFloat)zj_x {
    return self.frame.origin.x;
}

- (void)setZj_x:(CGFloat)zj_x {
    CGRect frame = self.frame;
    frame.origin.x = zj_x;
    self.frame = frame;
}

- (void)setZj_width:(CGFloat)zj_width {
    CGRect frame = self.frame;
    frame.size.width = zj_width;
    self.frame = frame;
}
@end

@implementation UIButton(Under)

- (void)textUnderImageButton
{
    // the space between the image and text
    CGFloat spacing = 2.0;
    
    // lower the text and push it left so it appears centered below the image
    CGSize imageSize = self.imageView.image.size;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing) - 5, 0.0);
    
    // raise the image and push it right so it appears centered above the text
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}
@end
