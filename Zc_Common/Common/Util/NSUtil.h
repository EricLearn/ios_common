
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (utils)

- (UIColor *)toUIColor;
- (UIColor *)convertToUIColor;
- (NSMutableDictionary *)parseParams;
- (NSString *)localeLanuage;
- (NSString *)keyForUserRights;

- (NSString *)stringForSubject;

- (BOOL)judgeCanSender;

- (NSString *)stringByAppendingStringInSafeWay:(NSString *)aString;

- (NSArray *)formatStringBySeparated:(NSString *)string;
 
@end

@interface UIColor (uic)

- (NSNumber *)toNumber;
- (UIColor *)colorWithHexString:(NSString *)stringToConvert;
- (NSString *)changeUIColorToRGB;
@end

@interface UIImage (scale)
- (UIImage *)zip:(float)targetWidth;

@end

@interface NSDictionary (helper)

- (id)getStringValueWithKey:(NSString *)key;

-(NSMutableDictionary *)mutableDeepCopy;

@end

//

class NSUtil
{
#pragma mark Appcalition path methods
public:
    //
    NS_INLINE NSBundle *Bundle()
    {
        return [NSBundle mainBundle];
    }
    
    //
    NS_INLINE id BundleInfo(NSString *key)
    {
        return [Bundle() objectForInfoDictionaryKey:key];
    }
    
    //
    NS_INLINE NSString *BundleName()
    {
        return BundleInfo(@"CFBundleName");
    }
    
    //
    NS_INLINE NSString *BundleDisplayName()
    {
        return BundleInfo(@"CFBundleDisplayName");
    }
    
    //
    NS_INLINE NSString *BundleVersion()
    {
        return BundleInfo(@"CFBundleVersion");
    }
    
    //
    NS_INLINE NSString *BundlePath()
    {
        return [Bundle() bundlePath];
    }
    
    //
    NS_INLINE NSString *BundlePath(NSString *file)
    {
        return [BundlePath() stringByAppendingPathComponent:file];
    }
    
#pragma mark File manager methods
public:
    //
    NS_INLINE NSFileManager *FileManager()
    {
        return [NSFileManager defaultManager];
    }
    
    //
    NS_INLINE BOOL IsPathExist(NSString* path)
    {
        return [FileManager() fileExistsAtPath:path];
    }
    
    //
    NS_INLINE BOOL IsFileExist(NSString* path)
    {
        BOOL isDirectory;
        return [FileManager() fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory;
    }
    
    //
    NS_INLINE BOOL IsDirectoryExist(NSString* path)
    {
        BOOL isDirectory;
        return [FileManager() fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory;
    }
    
    //
    NS_INLINE BOOL RemovePath(NSString* path)
    {
        return [FileManager() removeItemAtPath:path error:nil];
    }
    
#pragma mark User directory methods
public:
    //
    NS_INLINE NSString *UserDirectoryPath(NSSearchPathDirectory directory)
    {
        return [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) lastObject];
    }
    
    //
    NS_INLINE NSString *DocumentPath()
    {
        return UserDirectoryPath(NSDocumentDirectory);
    }
    
    //
    NS_INLINE NSString *DocumentPath(NSString *file)
    {
        return [DocumentPath() stringByAppendingPathComponent:file];
    }
    
#pragma mark User defaults
public:
    //
    NS_INLINE NSUserDefaults *UserDefaults()
    {
        return [NSUserDefaults standardUserDefaults];
    }
    
    //
    NS_INLINE id DefaultForKey(NSString *key)
    {
        return [UserDefaults() objectForKey:key];
    }
    
    //
    NS_INLINE void SetDefaultForKey(NSString *key, id value)
    {
        return [UserDefaults() setObject:value forKey:key];
    }
    
    NS_INLINE BOOL SetSynchronize()
    {
        return [UserDefaults() synchronize];;
    }
    
    //
    NS_INLINE NSString *PhoneNumber()
    {
        return DefaultForKey(@"SBFormattedPhoneNumber");
    }
    
    //
    NS_INLINE NSString *DefaultLanguage()
    {
        return [[NSLocale preferredLanguages] objectAtIndex:0];
        //return [DefaultForKey(@"AppleLanguages") objectAtIndex:0];
    }
    
#pragma mark Cache methods
public:
    //
    NS_INLINE NSString *CachePath()
    {
        //return DocumentPath(@"Cache");
        return [UserDirectoryPath(NSCachesDirectory) stringByAppendingPathComponent:@"appCache"];
    }
    
    //
    NS_INLINE void RemoveCache()
    {
        [FileManager() removeItemAtPath:CachePath() error:nil];
    }
    
    //
    NS_INLINE NSString *CachePath(NSString *file)
    {
        NSString *dir = CachePath();
        if (IsDirectoryExist(dir) == NO)
        {
            [FileManager() createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return [dir stringByAppendingPathComponent:file];
    }
    //
    NS_INLINE NSString *CacheUrlPath(NSString *url)
    {
        unichar chars[256];
        NSRange range = {0, MIN(url.length, 256)};
        [url getCharacters:chars range:range];
        for (NSUInteger i = 0; i < range.length; i++)
        {
            switch (chars[i])
            {
                case '|':
                case '/':
                case '\\':
                case '?':
                case '*':
                case ':':
                case '<':
                case '>':
                case '"':
                    chars[i] = '_';
                    break;
            }
        }
        NSString *file = [NSString stringWithCharacters:chars length:range.length];
        return CachePath(file);
    }
    
#pragma mark Format methods
public:
    // Convert number to string
    static NSString *FormatNumber(NSNumber *number, NSNumberFormatterStyle style = NSNumberFormatterNoStyle);
    
    // Convert date to string
    static NSString *FormatDate(NSDate *date, NSString *format);
    
    // Convert date to string
    static NSString *FormatDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle = NSDateFormatterNoStyle);
    
    // Convert string to date
    static NSDate *FormatDate(NSString *string, NSString *format = @"yyyy-MM-dd HH:mm:ss", NSLocale *locale = nil);
    
    // Convert string to date
    static NSDate *FormatDate(NSString *string, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle = NSDateFormatterNoStyle, NSLocale *locale = nil);
    
    // Convert date to readable string. Return nil on fail
    static NSString *SmartDate(NSDate *date);
    
    // Convert date to smart string
    static NSString *SmartDate(NSDate *date, NSString *format);
    
    // Convert date to smart string
    static NSString *SmartDate(NSDate *date, NSDateFormatterStyle dateStyle);
    
    // Convert date to smart string
    static NSString *SmartDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle);
    
    static NSMutableDictionary *getUrlParam(NSString *url);
    
    static NSDictionary*parseUrlToDict(NSString *url);
    
#pragma mark Network methods
public:
    // Network connection enum
    enum NetworkConnection {NetworkConnectionNONE, NetworkConnectionWWAN, NetworkConnectionWIFI};
    
    // Check network connection status
    NetworkConnection NetworkConnectionStatus();
    
    // Check if the network is available.
   static BOOL IsNetworkAvailable();
    
   static BOOL IsWiFiAvailable();
    
#pragma mark Crypto methods
public:
    // Check email address
    static BOOL IsEmailAddress(NSString *emailAddress);
    
    static BOOL IsValidateEmail(NSString *email);
    
    static BOOL IsPhoneNumber(NSString *phoneNumber);
    
    // Check phone number equal
    static BOOL IsPhoneNumberEqual(NSString *phoneNumber1, NSString *phoneNumber2, NSUInteger minEqual = 10);
    
    // Calculate MD5
    static NSString *MD5(NSString *str);
    
    // Calculate HMAC SHA1
    static NSString *HmacSHA1(NSString *text, NSString *secret);
    
    // BASE64 encode
    static NSString *BASE64Encode(const unsigned char *data, NSUInteger length, NSUInteger lineLength = 0);
    
    // BASE64 decode
    static NSData *BASE64Decode(NSString *string);
    
    // BASE64 encode data
    NS_INLINE NSString *BASE64EncodeData(NSData *data, NSUInteger lineLength = 0)
    {
        return BASE64Encode((const unsigned char *)data.bytes, data.length, lineLength);
    }
    
    // BASE64 encode string
    NS_INLINE NSString *BASE64EncodeString(NSString *string, NSUInteger lineLength = 0)
    {
        return BASE64EncodeData([string dataUsingEncoding:NSUTF8StringEncoding], lineLength);
    }
    
    // BASE64 decode string
    NS_INLINE NSString *BASE64DecodeString(NSString *string)
    {
        NSData *data = BASE64Decode(string);
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    static NSString *MacAddress();
    
    
    NS_INLINE NSString *GetUUID()
    {
        return MD5(MacAddress());
    }
    
public:
    //
    NS_INLINE NSString *URLEscape(NSString *string)
    {
        CFStringRef result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                     (CFStringRef)string,
                                                                     NULL,
                                                                     CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                     kCFStringEncodingUTF8);
        return (__bridge NSString *)result;
    }
    
    //
    NS_INLINE NSString *URLUnEscape(NSString *string)
    {
        CFStringRef result = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                     (CFStringRef)string,
                                                                                     CFSTR(""),
                                                                                     kCFStringEncodingUTF8);
        return (__bridge NSString *)result;
    }
    
    //
    NS_INLINE NSString *TS()
    {
        return [NSString stringWithFormat:@"%d", time(NULL)];
    }
    
    //
    NS_INLINE NSString *UUID()
    {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        return (__bridge NSString *)string;
    }
    
    NS_INLINE CGFloat FolderSize(NSString *dir)
    {
        //
        unsigned long long size = 0;
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:dir];
        for (NSString *file in files)
        {
            NSString *path = [dir stringByAppendingPathComponent:file];
            NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            size += [dict fileSize];
        }
        
        return size / (1024.0 * 1024.0);
    }
    
    NS_INLINE NSDate *ModifyDate(NSString *dir)
    {
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:dir error:nil];
        return [dict fileModificationDate];
    }
    NS_INLINE NSString *appendUrlParams(NSDictionary *params, NSString *url)
    {
        NSMutableString *paramsString = [NSMutableString string];
        NSRange range = [url rangeOfString:@"?"];
        url = [url stringByAppendingString:range.location == NSNotFound ? @"?" : @"&"];
        for(NSString *key in [params allKeys])
        {
            if (!key || ![params objectForKey:key]) {
                continue;
            }
            [paramsString appendFormat:@"%@=%@&",key,[params objectForKey:key]];
        }
        url = [NSString stringWithFormat: @"%@%@",url,paramsString];
        return url;
    }
    NS_INLINE NSString *converTimeToString(long long time,NSString *formater = @"yyyy-MM-dd HH:mm")
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:formater];
        return [timeFormatter stringFromDate:date];;
    }
    
    NS_INLINE NSAttributedString * formateGoodsPrice(NSString *price,UIFont * font,UIFont * subFont,UIColor * color)
    {
        NSString * priceStr = [NSString stringWithFormat:@"¥%@",price];
        NSDictionary * attrDic = @{
                       NSFontAttributeName:font,
                       NSForegroundColorAttributeName:color
        };
        NSRange range = [priceStr rangeOfString:@"¥"];
        NSMutableAttributedString * attrs = [[NSMutableAttributedString alloc]initWithString:priceStr attributes:attrDic ];
        [attrs addAttribute:NSFontAttributeName value:subFont range:range];
        return attrs;
   }
    /**
     * 开始到结束的时间差
     */
    NS_INLINE NSString * dateTimeDifferenceWithStartTime(NSString *startTime,NSString *endTime){
        NSDateFormatter *date = [[NSDateFormatter alloc]init];
        [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *startD =[date dateFromString:startTime];
        NSDate *endD = [date dateFromString:endTime];
        NSTimeInterval start = [startD timeIntervalSince1970]*1;
        NSTimeInterval end = [endD timeIntervalSince1970]*1;
        NSTimeInterval value = end - start;
        NSInteger second = (NSInteger)value;
        NSInteger day = second / (60 * 60 * 24);
        second = second % (60 * 60 * 24);
        NSInteger house = second / (60*60);
        second = second % (60*60);
        NSInteger minute = second / 60;
        second = second % 60;
        NSString *str;
        str = [NSString stringWithFormat:@"%02ld:%02ld:%02ld:%02ld",day,house,minute,second];
        return str;
    }
    NS_INLINE NSString * dateTimeWithTimeInterval(NSTimeInterval value){
        NSInteger second = (NSInteger)value;
        NSInteger day = second / (60 * 60 * 24);
        second = second % (60 * 60 * 24);
        NSInteger house = second / (60*60);
        second = second % (60*60);
        NSInteger minute = second / 60;
        second = second % 60;
        NSString *str;
        str = [NSString stringWithFormat:@"%02ld:%02ld:%02ld:%02ld",day,house,minute,second];
        return str;
    }
    //json字符串转换为字典
    NS_INLINE NSDictionary * dictionaryWithJsonString(NSString * jsonString){
        if (jsonString == nil) {
            return nil;
        }
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if(err)
        {
            NSLog(@"json解析失败：%@",err);
            return nil;
        }
        return dic;
    }
    
   //字典转json格式字符串
    
    NS_INLINE NSString * dictionaryToJson(NSDictionary *dic)
    {
        NSError *parseError = nil;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
        
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
};
