
#import "NSUtil.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <arpa/inet.h>
#import <ifaddrs.h>

#import <Security/Security.h>

@implementation NSString (utils)

- (UIColor *)toUIColor
{
    if (![self length])
    {
        return [UIColor blackColor];
    }
    
    unsigned int c;
    if ([self characterAtIndex:0] == '#')
    {
        [[NSScanner scannerWithString:[self substringFromIndex:1]] scanHexInt:&c];
    }
    else
    {
        [[NSScanner scannerWithString:self] scanHexInt:&c];
    }
    
    if ([self length] == 9)
    {
        return [UIColor colorWithRed:((c & 0xff000000) >> 24)/255.0 green:((c & 0xff0000) >> 16)/255.0 blue:((c & 0xff00) >> 8)/255.0 alpha:(c & 0xff)/100.0];
    }
    else if ([self length] == 8)
    {
        return [UIColor colorWithRed:((c & 0xff00000) >> 20)/255.0 green:((c & 0xff000) >> 12)/255.0 blue:((c & 0xff0) >> 4)/255.0 alpha:(c & 0xf)/100.0];
    }
    else if ([self length] == 7)
    {
        return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0 green:((c & 0xff00) >> 8)/255.0 blue:(c & 0xff)/255.0 alpha:1.0];
    }
    
    return [UIColor blackColor];
}

- (UIColor *)getUIColor :(CGFloat)alpha
{
    if (![self length])
    {
        return [UIColor blackColor];
    }
    
    unsigned int c;
    if ([self characterAtIndex:0] == '#')
    {
        [[NSScanner scannerWithString:[self substringFromIndex:1]] scanHexInt:&c];
    }
    else
    {
        [[NSScanner scannerWithString:self] scanHexInt:&c];
    }
    
    if ([self length] == 9)
    {
        return [UIColor colorWithRed:((c & 0xff000000) >> 24)/255.0 green:((c & 0xff0000) >> 16)/255.0 blue:((c & 0xff00) >> 8)/255.0 alpha:(c & 0xff)/100.0];
    }
    else if ([self length] == 8)
    {
        return [UIColor colorWithRed:((c & 0xff00000) >> 20)/255.0 green:((c & 0xff000) >> 12)/255.0 blue:((c & 0xff0) >> 4)/255.0 alpha:(c & 0xf)/100.0];
    }
    else if ([self length] == 7)
    {
        return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0 green:((c & 0xff00) >> 8)/255.0 blue:(c & 0xff)/255.0 alpha:alpha];
    }
    
    return [UIColor blackColor];
}

- (UIColor *)convertToUIColor
{
    if ([self intValue] == 0)
    {
        return [UIColor clearColor];
    }
    NSString *clor = [NSString stringWithFormat:@"%x",[self intValue]];
    
    NSRange range;
    range.location = 0;
    if (clor.length == 7)
    {
        range.length = 1;
    }
    else if(clor.length == 8)
    {
        range.length = 2;
    } else if(clor.length == 9)
    {
        range.length = 3;
    }
    else
    {
        range.length = 0;
    }
    
    NSString *aString = [clor substringWithRange:range];
    range.location = range.length + range.location;
    range.length = 2 ;
    
    NSString *rString = [clor substringWithRange:range];
    range.location = range.length + range.location;
    NSString *gString = [clor substringWithRange:range];
    range.location = range.length + range.location;
    NSString *bString = [clor substringWithRange:range];
    
    unsigned int a,  r, g, b ;
    
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:((float) a / 255.0f)];
}

- (NSMutableDictionary *)parseParams
{
    NSString *urlString = [NSString stringWithFormat:@"%@|", self];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSRange tempRange = [urlString rangeOfString:@"|"];
    while ([urlString length] && tempRange.length)
    {
        NSString *text = [urlString substringToIndex:tempRange.location];
        if (text)
        {
            NSRange range = [text rangeOfString:@"="];
            if (range.length)
            {
                [dict setObject:[text substringFromIndex:range.location+1] forKey:[text substringWithRange:NSMakeRange(0, range.location)]];
            }
        }
        
        urlString = [urlString stringByReplacingOccurrencesOfString:
                     [NSString stringWithFormat:@"%@|", text] withString:@""];
        
        tempRange = [urlString rangeOfString:@"|"];
    }
    
    return dict;
}

- (BOOL)judgeCanSender
{
    NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return (string.length >0 && self.length < 1000);
}

- (NSString *)stringByAppendingStringInSafeWay:(NSString *)aString
{
    return  [self stringByAppendingString:aString ? aString : @""];
}

- (NSArray *)formatStringBySeparated:(NSString *)string
{
    NSString *temp = self;
    if (self.length > 1 && [[self substringFromIndex:self.length - 1] isEqualToString:@","])
    {
        temp = [temp substringToIndex:self.length - 1];
    }
    if (temp.length == 0) {
        return nil;
    }
    return [temp componentsSeparatedByString:string];
}
@end


@implementation UIImage (scale)

- (UIImage *)zip:(float)targetWidth
{
    
    if (self.size.width<targetWidth)
    {
        return self;
    }
    
    float k = self.size.height/self.size.width;
    CGSize targetSize = CGSizeMake(targetWidth , k*targetWidth);
    UIImage *newImage = nil;
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end


@implementation UIColor (uic)

- (NSNumber *)toNumber
{
    CGFloat red = 0.0f;
    CGFloat green = 0.0f;
    CGFloat blue = 0.0f;
    CGFloat alpha = 0.0f;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    int i;
    alpha *= 255;
    green *= 255;
    blue  *= 255;
    red  *= 255;
    NSString *aString = [NSString stringWithFormat:@"0x%02X%02X%02X%02X",(int)alpha,(int)red,(int)green,(int)blue];
    sscanf([aString cStringUsingEncoding:NSASCIIStringEncoding], "%x", &i);
    return [NSNumber numberWithInt:i];
}

- (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return [UIColor whiteColor];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor whiteColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (NSString *)changeUIColorToRGB
{
    const CGFloat *cs = CGColorGetComponents(self.CGColor);
    NSString *r = [NSString stringWithFormat:@"%@", [self ToHex:cs[0] * 255]];
    NSString *g = [NSString stringWithFormat:@"%@", [self ToHex:cs[1] * 255]];
    NSString *b = [NSString stringWithFormat:@"%@", [self ToHex:cs[2] * 255]];
    return [NSString stringWithFormat:@"#%@%@%@", r, g, b];
}

- (NSString *)ToHex:(int)tmpid
{
    NSString *endtmp = @"";
    NSString *nLetterValue;
    NSString *nStrat;
    int ttmpig = tmpid % 16;
    int tmp = tmpid / 16;
    switch (ttmpig) {
        case 10:
            nLetterValue = @"A"; break;
        case 11:
            nLetterValue = @"B"; break;
        case 12:
            nLetterValue = @"C"; break;
        case 13:
            nLetterValue = @"D"; break;
        case 14:
            nLetterValue = @"E"; break;
        case 15:
            nLetterValue = @"F"; break;
        default:nLetterValue = [[NSString alloc] initWithFormat:@"%i", ttmpig];
    }
    switch (tmp) {
        case 10:
            nStrat = @"A"; break;
        case 11:
            nStrat = @"B"; break;
        case 12:
            nStrat = @"C"; break;
        case 13:
            nStrat = @"D"; break;
        case 14:
            nStrat = @"E"; break;
        case 15:
            nStrat = @"F"; break;
        default:nStrat = [[NSString alloc] initWithFormat:@"%i", tmp];
    }
    endtmp = [[NSString alloc] initWithFormat:@"%@%@", nStrat, nLetterValue];
    return endtmp;
}
@end

@implementation NSDictionary (helper)

- (id)getStringValueWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return @"";
    }
    id object = self[key];
    return  ([object isEqual:[NSNull null]] || [object isKindOfClass:[NSNull class]]) ? @"" : (object ? object : @"") ;
}

-(NSMutableDictionary *)mutableDeepCopy
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:[self count]];
    //新建一个NSMutableDictionary对象，大小为原NSDictionary对象的大小
    NSArray *keys=[self allKeys];
    for(id key in keys)
    {//循环读取复制每一个元素
        id value=[self objectForKey:key];
        id copyValue;
        if ([value respondsToSelector:@selector(mutableDeepCopy)]) {
            //如果key对应的元素可以响应mutableDeepCopy方法(还是NSDictionary)，调用mutableDeepCopy方法复制
            copyValue=[value mutableDeepCopy];
        }
        else if ([value conformsToProtocol:@protocol(NSMutableCopying)])
        {
            copyValue=[value mutableCopy];
        }
        else
        {
            copyValue = value;
        }
        if(copyValue==nil)
            copyValue=[value copy];
        [dict setObject:copyValue forKey:key];
        
    }
    return dict;
}
@end


// Convert number to string
NSString *NSUtil::FormatNumber(NSNumber *number, NSNumberFormatterStyle style)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:style];
    NSString *result = [formatter stringFromNumber:number];
    return result;
}

// Convert date to string
NSString *NSUtil::FormatDate(NSDate *date, NSString *format)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringForObjectValue:date];
}

// Convert date to string
NSString *NSUtil::FormatDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:dateStyle];
    [formatter setTimeStyle:timeStyle];
    return [formatter stringForObjectValue:date];
}

// Convert string to date
NSDate *NSUtil::FormatDate(NSString *string, NSString *format, NSLocale *locale)
{
    if (string == nil) return nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    if (locale) formatter.locale = locale;
    return [formatter dateFromString:string];
}

// Convert string to date
NSDate *NSUtil::FormatDate(NSString *string, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle, NSLocale *locale)
{
    if (string == nil) return nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:dateStyle];
    [formatter setTimeStyle:timeStyle];
    if (locale) formatter.locale = locale;
    return [formatter dateFromString:string];
}

// Convert date to readable string. Return nil on fail
NSString *NSUtil::SmartDate(NSDate *date)
{
    NSDate *now = [NSDate date];
    NSTimeInterval t1 = [now timeIntervalSinceReferenceDate];
    NSTimeInterval t2 = [date timeIntervalSinceReferenceDate];
    NSTimeInterval t = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    NSInteger d1 = (t1 + t) / (24 * 60 * 60);
    NSInteger d2 = (t2 + t) / (24 * 60 * 60);
    NSInteger days = d2 - d1;
    switch (days)
    {
        case -2: return NSLocalizedString(@"Before Yesterday ", @"前天");
        case -1: return NSLocalizedString(@"Yesterday ", @"昨天");
        case 0: return NSLocalizedString(@"Today ", @"今天");
        case 1: return NSLocalizedString(@"Tomorrow ", @"明天");
        case 2: return NSLocalizedString(@"After Tomorrow ", @"后天");
    }
    return nil;
}


// Convert date to smart string
NSString *NSUtil::SmartDate(NSDate *date, NSString *format)
{
    NSString *string = SmartDate(date);
    return string ? string : FormatDate(date, format);
}

// Convert date to smart string
NSString *NSUtil::SmartDate(NSDate *date, NSDateFormatterStyle dateStyle)
{
    NSString *string = SmartDate(date);
    return string ? string : FormatDate(date, dateStyle, NSDateFormatterNoStyle);
}

// Convert date to smart string
NSString *NSUtil::SmartDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle)
{
    NSString *string = SmartDate(date);
    return string ? [string stringByAppendingFormat:@" %@", FormatDate(date, NSDateFormatterNoStyle, timeStyle)] : FormatDate(date, dateStyle, timeStyle);
}

NSMutableDictionary *NSUtil::getUrlParam(NSString *url)
{
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableDictionary *dictonary = [NSMutableDictionary dictionary];
    NSString *query = [URL query];
    if ([query length]) {
        NSArray *array = [query componentsSeparatedByString:@"&"];
        for (NSString *string in array) {
            NSArray *arr = [string componentsSeparatedByString:@"="];
            [dictonary setObject:[arr objectAtIndex:1] forKey:[arr objectAtIndex:0]];
        }
    }
    return dictonary;
}

NSDictionary *NSUtil::parseUrlToDict(NSString *url)
{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSRange range = [url rangeOfString:@"?"];
    if (range.location != NSNotFound && range.length != NSNotFound)
    {
        url = [url substringFromIndex:range.location + range.length];
    }
    NSArray *urlComponents = [url componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    return queryStringDictionary;
}

// Check email address
BOOL NSUtil::IsEmailAddress(NSString *emailAddress)
{
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:[emailAddress lowercaseString]];
}

BOOL NSUtil::IsValidateEmail(NSString *email)
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

BOOL NSUtil::IsPhoneNumber(NSString *phoneNumber)
{
    NSString *phone = @"[1][34578]\\d{9}";
    NSPredicate *phonePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phone];
    return [phonePredicate evaluateWithObject:[phoneNumber lowercaseString]];
}

// Check phone number equal
BOOL NSUtil::IsPhoneNumberEqual(NSString *phoneNumber1, NSString *phoneNumber2, NSUInteger minEqual)
{
    if (!phoneNumber1 || !phoneNumber2) return NO;
    
    const char *number1 = phoneNumber1.UTF8String;
    const char *number2 = phoneNumber2.UTF8String;
    
    const char *end1 = number1 + strlen(number1);
    const char *end2 = number2 + strlen(number2);
    const char *p1 = end1 - 1;
    const char *p2 = end2 - 1;
    while ((p1 >= number1) && (p2 >= number2))
    {
        if ((*p1 < '0') || (*p1 > '9'))
        {
            p1--;
        }
        else if ((*p2 < '0') || (*p2 > '9'))
        {
            p2--;
        }
        else if (*p1 == *p2)
        {
            p1--;
            p2--;
        }
        else
        {
            break;
        }
    }
    return ((p1 < number1) && (p2 < number2)) || (end1 - p1 >= minEqual);
}

// Calculate MD5
NSString *NSUtil::MD5(NSString *str)
{
    if (str == nil) return nil;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    const char *cstr = [str UTF8String];
    CC_MD5(cstr, strlen(cstr), result);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

// Calculate SHA1
NSString *NSUtil::HmacSHA1(NSString *text, NSString *secret)
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    return BASE64Encode(result, 20);
}

// BASE64 encode
NSString *NSUtil::BASE64Encode(const unsigned char *data, NSUInteger length, NSUInteger lineLength)
{
    // BASE64 table
    const static char c_baseTable[64] =
    {
        'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
        'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
        'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
        'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
    };
    
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    unsigned long ixtext = 0;
    unsigned long lentext = length;
    long ctremaining = 0;
    unsigned char inbuf[3], outbuf[4];
    short i = 0;
    short charsonline = 0, ctcopy = 0;
    unsigned long ix = 0;
    
    while (YES)
    {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0) break;
        
        for (i = 0; i < 3; i++)
        {
            ix = ixtext + i;
            if (ix < lentext)
            {
                inbuf[i] = data[ix];
            }
            else
            {
                inbuf [i] = 0;
            }
        }
        
        outbuf [0] = (inbuf [0] & 0xFC) >> 2;
        outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
        outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
        outbuf [3] = inbuf [2] & 0x3F;
        ctcopy = 4;
        
        switch (ctremaining)
        {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
        {
            [result appendFormat:@"%c", c_baseTable[outbuf[i]]];
        }
        
        for (i = ctcopy; i < 4; i++)
        {
            [result appendFormat:@"%c",'='];
        }
        
        ixtext += 3;
        charsonline += 4;
        
        if (lineLength > 0)
        {
            if (charsonline >= lineLength)
            {
                charsonline = 0;
                [result appendString:@"\n"];
            }
        }
    }
    
    return result;
}

// BASE64 decode
NSData *NSUtil::BASE64Decode(NSString *string)
{
    NSMutableData *mutableData = nil;
    
    if (string)
    {
        unsigned long ixtext = 0;
        unsigned long lentext = 0;
        unsigned char ch = 0;
        unsigned char inbuf[4], outbuf[4];
        short i = 0, ixinbuf = 0;
        BOOL flignore = NO;
        BOOL flendtext = NO;
        NSData *base64Data = nil;
        const unsigned char *base64data = nil;
        
        // Convert the string to ASCII data.
        base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
        base64data = (const unsigned char *)[base64Data bytes];
        mutableData = [NSMutableData dataWithCapacity:[base64Data length]];
        lentext = [base64Data length];
        
        while (YES)
        {
            if (ixtext >= lentext)
            {
                break;
            }
            ch = base64data[ixtext++];
            flignore = NO;
            
            if ((ch >= 'A') && (ch <= 'Z')) ch = ch - 'A';
            else if ((ch >= 'a') && (ch <= 'z')) ch = ch - 'a' + 26;
            else if ((ch >= '0') && (ch <= '9')) ch = ch - '0' + 52;
            else if (ch == '+') ch = 62;
            else if (ch == '=') flendtext = YES;
            else if (ch == '/') ch = 63;
            else flignore = YES;
            
            if (!flignore)
            {
                short ctcharsinbuf = 3;
                BOOL flbreak = NO;
                
                if (flendtext)
                {
                    if (!ixinbuf) break;
                    if ((ixinbuf == 1) || (ixinbuf == 2)) ctcharsinbuf = 1;
                    else ctcharsinbuf = 2;
                    ixinbuf = 3;
                    flbreak = YES;
                }
                
                inbuf[ixinbuf++] = ch;
                
                // Please ignore any warning here
                if (ixinbuf == 4)
                {
                    outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                    outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                    outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                    ixinbuf = 0;
                    
                    for (i = 0; i < ctcharsinbuf; i++)
                    {
                        [mutableData appendBytes:&outbuf[i] length:1];
                    }
                }
                
                if (flbreak)
                {
                    break;
                }
            }
        }
    }
    
    return mutableData;
}

NSString * NSUtil::MacAddress()
{
    int					mib[6];
    size_t				len;
    char				*buf;
    unsigned char		*ptr;
    struct if_msghdr	*ifm;
    struct sockaddr_dl	*sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0)
    {
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0)
    {
        return NULL;
    }
    
    if ((buf = (char*)malloc(len)) == NULL)
    {
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0)
    {
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}

#pragma mark Network methods

// Check network connection status
#ifdef _FRAMEWORK_SystemConfiguration
NSUtil::NetworkConnection NSUtil::NetworkConnectionStatus()
{
    NetworkConnection status = NetworkConnectionNONE;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [@"www.apple.com" UTF8String]);
    if (reachability)
    {
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags))
        {
            if (flags & kSCNetworkReachabilityFlagsReachable)
            {
                if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
                {
                    // if target host is reachable and no connection is required then we'll assume (for now) that your on Wi-Fi
                    status = NetworkConnectionWIFI;
                }
                
                if ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) ||
                    (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic))
                {
                    // ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs
                    if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                    {
                        // ... and no [user] intervention is needed
                        status = NetworkConnectionWIFI;
                    }
                }
                
                if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
                {
                    // ... but WWAN connections are OK if the calling application is using the CFNetwork (CFSocketStream?) APIs.
                    status = NetworkConnectionWWAN;
                }
            }
        }
        CFRelease(reachability);
    }
    
    return status;
}
#endif

// Check if the network is available.
BOOL NSUtil::IsNetworkAvailable()
{
    
    // Set address to 0.0.0.0 to check the local network..
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    return (isReachable && !needsConnection);
}

// 判断是否WiFi可用
BOOL NSUtil::IsWiFiAvailable()
{
    BOOL bRet = NO;
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    if (getifaddrs(&addresses) != 0) return bRet;
    
    cursor = addresses;
    while (cursor != NULL)
    {
        if (cursor -> ifa_addr -> sa_family == AF_INET && !(cursor -> ifa_flags & IFF_LOOPBACK))
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0 || strcmp(cursor -> ifa_name, "en1") == 0)
            {
                bRet = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    
    freeifaddrs(addresses);
    return bRet;
}
