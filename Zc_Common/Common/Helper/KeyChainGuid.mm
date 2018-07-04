//
//  KeyChainGuid.m
//  epub
//
//  Created by virgil on 15/10/8.
//  Copyright © 2015年 xtownmobile. All rights reserved.
//

#import "KeyChainGuid.h"

#import <sys/utsname.h>

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CommonCrypto/CommonDigest.h>

@implementation KeyChainGuid

+ (NSString *)getGuid
{
    NSString *udid = [KeyChainGuid getUDIDFromKeyChain];
    if (!udid)
    {
        udid = [[UIDevice currentDevice].systemVersion floatValue] < 7.0 ? [self _macAddress] : [[UIDevice currentDevice].identifierForVendor UUIDString];
        
        [KeyChainGuid settUDIDToKeyChain:udid];
    }
    
    return udid;
}


+ (NSString *) _macAddress
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

+ (NSString*) md5:(NSString*)text
{
    if(nil==text || text.length<1) return nil;
    
    const char *value = [text UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *hash = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++)
        [hash appendFormat:@"%02x",outputBuffer[count]];
    return hash;
}

// 设备唯一号
+ (NSString *)xUniqueIdentifier
{
    NSString *mac = [[UIDevice currentDevice].systemVersion floatValue] < 7.0 ? [self _macAddress] : [[UIDevice currentDevice].identifierForVendor UUIDString];
    
    NSString *str = [[NSString alloc] initWithFormat:@"xIdm.%@", mac];
    NSString *uid = [self md5:str];
    return uid;
}

static const char kKeychainUDIDItemIdentifier[]  = "UUID";
static NSString *guid = nil;
#pragma mark -
#pragma mark Helper Method for make identityForVendor consistency

+ (NSString*)getUDIDFromKeyChain
{
    if (guid == nil)
    {
        NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
        [dictForQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        
        // set Attr Description for query
        [dictForQuery setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]
                        forKey:(id)kSecAttrDescription];
        
        // set Attr Identity for query
        NSData *keychainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier
                                                length:strlen(kKeychainUDIDItemIdentifier)];
        [dictForQuery setObject:keychainItemID forKey:(id)kSecAttrGeneric];
        
        // The keychain access group attribute determines if this item can be shared
        // amongst multiple apps whose code signing entitlements contain the same keychain access group.
        NSString *accessGroup = [KeyChainGuid bundleSeedID];
        if (accessGroup != nil)
        {
#if TARGET_IPHONE_SIMULATOR
            // Ignore the access group if running on the iPhone simulator.
            //
            // Apps that are built for the simulator aren't signed, so there's no keychain access group
            // for the simulator to check. This means that all apps can see all keychain items when run
            // on the simulator.
            //
            // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
            // simulator will return -25243 (errSecNoAccessForItem).
#else
            [dictForQuery setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
        }
        
        [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecMatchCaseInsensitive];
        [dictForQuery setValue:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
        [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
        
        OSStatus queryErr   = noErr;
        CFTypeRef   udidValue = NULL;
        
        queryErr = SecItemCopyMatching((CFDictionaryRef)dictForQuery, &udidValue);
        
        CFTypeRef dict = nil;
        [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
        queryErr = SecItemCopyMatching((CFDictionaryRef)dictForQuery, &dict);
        
        if (queryErr == errSecItemNotFound) {
            NSLog(@"KeyChain Item: %@ not found!!!", [NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]);
        }
        else if (queryErr != errSecSuccess) {
            NSLog(@"KeyChain Item query Error!!! Error code:%d", (int)queryErr);
        }
        if (queryErr == errSecSuccess) {
            NSLog(@"KeyChain Item: %@", udidValue);
            
            if (udidValue) {
                guid = [NSString stringWithUTF8String:(const char *)[(__bridge_transfer NSData *)udidValue bytes]];
                
            }
        }
    }
    return guid;
}

+ (BOOL)settUDIDToKeyChain:(NSString*)udid
{
    NSMutableDictionary *dictForAdd = [[NSMutableDictionary alloc] init];
    
    [dictForAdd setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [dictForAdd setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier] forKey:(id)kSecAttrDescription];
    
    [dictForAdd setValue:@"UUID" forKey:(id)kSecAttrGeneric];
    
    // Default attributes for keychain item.
    [dictForAdd setObject:@"" forKey:(id)kSecAttrAccount];
    [dictForAdd setObject:@"" forKey:(id)kSecAttrLabel];
    
    
    // The keychain access group attribute determines if this item can be shared
    // amongst multiple apps whose code signing entitlements contain the same keychain access group.
    NSString *accessGroup = [KeyChainGuid bundleSeedID];
    if (accessGroup != nil)
    {
#if TARGET_IPHONE_SIMULATOR
        // Ignore the access group if running on the iPhone simulator.
        //
        // Apps that are built for the simulator aren't signed, so there's no keychain access group
        // for the simulator to check. This means that all apps can see all keychain items when run
        // on the simulator.
        //
        // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
        // simulator will return -25243 (errSecNoAccessForItem).
#else
        [dictForAdd setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
    }
    
    const char *udidStr = [udid UTF8String];
    NSData *keyChainItemValue = [NSData dataWithBytes:udidStr length:strlen(udidStr)];
    [dictForAdd setValue:keyChainItemValue forKey:(id)kSecValueData];
    
    OSStatus writeErr = noErr;
    if ([KeyChainGuid getUDIDFromKeyChain]) {        // there is item in keychain
        [KeyChainGuid updateUDIDInKeyChain:udid];
        return YES;
    }
    else {          // add item to keychain
        writeErr = SecItemAdd((CFDictionaryRef)dictForAdd, NULL);
        if (writeErr != errSecSuccess)
        {
            NSLog(@"Add KeyChain Item Error!!! Error Code:%ld", (long)writeErr);
            return NO;
        }
        else
        {
            NSLog(@"Add KeyChain Item Success!!!");
            guid = udid;
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)removeUDIDFromKeyChain
{
    NSMutableDictionary *dictToDelete = [[NSMutableDictionary alloc] init];
    
    [dictToDelete setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    NSData *keyChainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier length:strlen(kKeychainUDIDItemIdentifier)];
    [dictToDelete setValue:keyChainItemID forKey:(id)kSecAttrGeneric];
    
    OSStatus deleteErr = noErr;
    deleteErr = SecItemDelete((CFDictionaryRef)dictToDelete);
    if (deleteErr != errSecSuccess) {
        NSLog(@"delete UUID from KeyChain Error!!! Error code:%ld", (long)deleteErr);
        return NO;
    }
    else {
        NSLog(@"delete success!!!");
        guid = nil;
    }
    
    return YES;
}

static NSString *seedId = nil;
+ (NSString *)bundleSeedID
{
    if (seedId == nil)
    {
        NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                               (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                               @"bundleSeedID", kSecAttrAccount,
                               @"", kSecAttrService,
                               (id)kCFBooleanTrue, kSecReturnAttributes,
                               nil];
        CFDictionaryRef result = nil;
        OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status == errSecItemNotFound)
            status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status == errSecSuccess || status == errSecItemNotFound )
        {
            seedId = [(__bridge NSDictionary *)result objectForKey:(id)kSecAttrAccessGroup];
        }
    }
    return seedId;
}

+ (BOOL)updateUDIDInKeyChain:(NSString*)newUDID
{
    NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
    
    [dictForQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    NSData *keychainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier
                                            length:strlen(kKeychainUDIDItemIdentifier)];
    [dictForQuery setValue:keychainItemID forKey:(id)kSecAttrGeneric];
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecMatchCaseInsensitive];
    [dictForQuery setValue:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    
    CFTypeRef queryResult = NULL;
    SecItemCopyMatching((CFDictionaryRef)dictForQuery, &queryResult);
    if (queryResult)
    {
        
        NSMutableDictionary *dictForUpdate = [[NSMutableDictionary alloc] init];
        [dictForUpdate setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier] forKey:(id)kSecAttrDescription];
        [dictForUpdate setValue:keychainItemID forKey:(id)kSecAttrGeneric];
        
        const char *udidStr = [newUDID UTF8String];
        NSData *keyChainItemValue = [NSData dataWithBytes:udidStr length:strlen(udidStr)];
        [dictForUpdate setValue:keyChainItemValue forKey:(id)kSecValueData];
        
        OSStatus updateErr = noErr;
        
        // First we need the attributes from the Keychain.
        NSMutableDictionary *updateItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary *) queryResult];
        
        // Second we need to add the appropriate search key/values.
        // set kSecClass is Very important
        [updateItem setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        
        updateErr = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)dictForUpdate);
        if (updateErr != errSecSuccess) {
            NSLog(@"Update KeyChain Item Error!!! Error Code:%ld", (long)updateErr);
            
            
            return NO;
        }
        else {
            NSLog(@"Update KeyChain Item Success!!!");
            guid = newUDID;
            return YES;
        }
    }
    
    return NO;
}

@end
