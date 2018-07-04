
#import "UIUtil.h"
#import "NSUtil.h"

@implementation UIImage (ImageEx)

// Load image and scale to specified size if needed
+ (id)imageWithContentsOfFile:(NSString *)path image:(UIImage *)images scaleTo:(CGSize)size
{
    UIImage *image;
    if (path) {
        image = [UIImage imageWithContentsOfFile:path];
    }
    else if (images){
        image = images;
    }
    
    if (size.width == 0)
    {
        if (image.size.height)
        {
            size.width = image.size.width * size.height / image.size.height;
        }
    }
    else if (size.height == 0)
    {
        if (image.size.width)
        {
            size.height = image.size.height * size.width / image.size.width;
        }
    }
    
    if ((size.width == image.size.width) && (size.height == image.size.height))
    {
        return image;
    }
    
    // Scale image
    //#define _SCALE_IMAGE_METHOD_1
#ifdef _SCALE_IMAGE_METHOD_1
    CGImageRef imageRef = [image CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    if (alphaInfo == kCGImageAlphaNone)
    {
        alphaInfo = kCGImageAlphaNoneSkipLast;
    }
    CGFloat bytesPerRow = 4 * ((size.width > size.height) ? size.width : size.height);
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                size.width,
                                                size.height,
                                                8, //CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
                                                bytesPerRow, //4 * thumbRect.size.width,	// rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo);
    
    // Draw into the context, this scales the image
    CGRect rect = {0, 0, size.width, size.height};
    CGContextDrawImage(bitmap, rect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* scaledImage = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
#else
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#endif
    
    return scaledImage;
}

+ (UIImage *)imageClipWithColor:(UIImage *)image color:(UIColor *)color
{
    if (!color || !image)
    {
        return image;
    }
    
    CGSize contextSize = image.size;
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextClipToMask(c, CGRectMake(0, 0, contextSize.width, contextSize.height),
                        [image CGImage]);
    
    CGContextSetFillColorWithColor(c, color.CGColor);
    CGContextFillRect(c, CGRectMake(0, 0, contextSize.width, contextSize.height));
    
    UIImage* selImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return selImage;
}

- (UIImage *)imageFitInLeftTop:(CGSize)size
{
    if (!size.width || !size.height)
    {
        return nil;
    }
    
    float s_x = size.width/self.size.width;
    float s_y = size.height/self.size.height;
    
    if (s_x <= 1.f && s_y <= 1.f)
    {
        //return self;
    }
    
    float scale = s_x > s_y ? s_x : s_y;
    return [UIImage imageWithCGImage:self.CGImage scale:1.f/scale orientation:self.imageOrientation];
}

- (UIImage *)imageWithBackgroundColor:(UIColor *)color
{
    if (!color)
    {
        color = [UIColor blackColor];
    }
    
    CGSize contextSize = self.size;
    
    UIGraphicsBeginImageContext(contextSize);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, color.CGColor);
    CGContextFillRect(c, CGRectMake(0, 0, contextSize.width, contextSize.height));
    
    [self drawInRect:CGRectMake(0, 0, contextSize.width, contextSize.height)];
    
    UIImage* selImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return selImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color overColor:(UIColor *)overColor andSize:(CGSize)size
{
    if (!color)
    {
        color = [UIColor clearColor];
    }
    
    CGSize contextSize = size;
    
    UIImage *image = [UIImage imageNamed:@"NavigationBar.png"];
    
    UIGraphicsBeginImageContextWithOptions(contextSize, NO, 1.0);
    CGContextRef c = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(c, color.CGColor);
    //CGContextFillRect(c, CGRectMake(0, 0, contextSize.width, contextSize.height));
    
    CGContextSetFillColorWithColor(c, overColor.CGColor);
    CGContextFillRect(c, CGRectMake(0, 0, contextSize.width, contextSize.height));
    
    [image drawInRect:CGRectMake(0, 0, contextSize.width, contextSize.height)];
    
    UIImage* selImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return selImage;
}

+  (UIImage *)imageWithColor:(UIColor *)color size:(CGSize )size
{
    if (!color)
    {
        color = [UIColor clearColor];
    }
    
    CGSize contextSize = size;
    
    UIGraphicsBeginImageContextWithOptions(contextSize, NO, 1.0);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, color.CGColor);
    CGContextFillRect(c, CGRectMake(0, 0, contextSize.width, contextSize.height));
    
    UIImage* selImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return selImage;
    
}

- (UIImage *)adjustmentImageSize:(CGFloat)max {
    CGSize newSize = self.size;
    CGFloat width = newSize.width;
    CGFloat height = newSize.height;
    
    if (width > max && width >= height) {
        height = max * (height / width);
        width = max;
    }else if (height > max && height > width) {
        width = max * (width / height);
        height = max;
    }else {
        return self;
    }
    newSize.height = height;
    newSize.width = width;
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end

//
void UIUtil::PrintIndentString(NSUInteger indent, NSString *str)
{
	NSString *log = @"";
	for (NSUInteger i = 0; i < indent; i++)
	{
		log = [log stringByAppendingString:@"\t"];
	}
	log = [log stringByAppendingString:str];
	NSLog(@"%@", log);
}

// Print controller and sub-controllers
void UIUtil::PrintController(UIViewController *controller, NSUInteger indent)
{
	PrintIndentString(indent, [NSString stringWithFormat:@"<Controller Description=\"%@\">", [controller description]]);

	if (controller.modalViewController)
	{
		PrintController(controller, indent + 1);
	}
	
	if ([controller isKindOfClass:[UINavigationController class]])
	{
		for (UIViewController *child in ((UINavigationController *)controller).viewControllers)
		{
			PrintController(child, indent + 1);
		}
	}
	else if ([controller isKindOfClass:[UITabBarController class]])
	{
		UITabBarController *tabBarController = (UITabBarController *)controller;
		for (UIViewController *child in tabBarController.viewControllers)
		{
			PrintController(child, indent + 1);
		}

		if (tabBarController.moreNavigationController)
		{
			PrintController(tabBarController.moreNavigationController, indent + 1);
		}
	}

	PrintIndentString(indent, @"</Controller>");
}

// Print view and subviews
void UIUtil::PrintView(UIView *view, NSUInteger indent)
{
	PrintIndentString(indent, [NSString stringWithFormat:@"<View Description=\"%@\">", [view description]]);
	
	for (UIView *child in view.subviews)
	{
		PrintView(child, indent + 1);
	}
	
	PrintIndentString(indent, @"</View>");
	
}

//
UIImageView *UIUtil::ShowSplashView(UIView *fadeInView)
{
	//
	CGRect frame = UIUtil::ScreenFrame();
	UIImageView *splashView = [[UIImageView alloc] initWithFrame:frame];
	splashView.image = [UIImage imageWithContentsOfFile:NSUtil::BundlePath(UIUtil::IsPad() ? @"Default@iPad.png" : @"Default.png")];
	splashView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[UIUtil::KeyWindow() addSubview:splashView];

	//
	//UIImage *logoImage = [UIImage imageWithContentsOfFile:NSUtil::BundlePath(UIUtil::IsPad() ? @"Splash@2x.png" : @"Splash.png")];
	//UIImageView *logoView = [[[UIImageView alloc] initWithImage:logoImage] autorelease];
	//logoView.center = CGPointMake(frame.size.width / 2, (frame.size.height / 2));
	//logoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	//splashView.tag = (NSInteger)logoView;
	//[splashView addSubview:logoView];

	//
	fadeInView.alpha = 0;
	[UIView beginAnimations:@"Splash" context:nil];
	[UIView setAnimationDuration:0.6];
	[UIView setAnimationDelegate:splashView];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];

	//
	fadeInView.alpha = 1;
	splashView.alpha = 0;
	//splashView.frame = CGRectInset(frame, -frame.size.width / 2, -frame.size.height / 2);
	//splashView.frame = CGRectInset(frame, frame.size.width / 2, frame.size.height / 2);

	//
	[UIView commitAnimations];
	return splashView;
}
