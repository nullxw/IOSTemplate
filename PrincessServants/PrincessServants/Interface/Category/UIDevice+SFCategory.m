//
//  UIDevice+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "UIDevice+SFCategory.h"
#import "NSString+SFCategory.h"
#import <Security/Security.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

static const char kKeychainUDIDItemIdentifier[] = "ShadowFiend";
//测试
//static const char kKeychainUDIDAccessGroup[]    = "Y56T56MN42.com.tixa.lianxi";
//Adhoc 内测
static const char kKeychainUDIDAccessGroup[]    = "G6JSA4XT55.com.tixa.sf";
//发布
//static const char kKeychainUDIDAccessGroup[]    = "57TJUXEWNK.com.lianxi.help";

@implementation UIDevice (SFCategory)

// 设备唯一ID(删除应用后重装ID不变)
- (NSString *)UDID
{
    NSString *UDID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UDID"];
    if (!UDID.length) {
        if (self.systemVersion.floatValue >= 7.0) { // 在keychain中持久化
            
            UDID = [self getUDIDFromKeychain];
            if (!UDID.length) {
                UDID = self.identifierForVendor.UUIDString;
                [self setUDIDToKeychain:UDID];
            }
        } else {//MAC地址的MD5串
            UDID = [self.MACAddress MD5EncodedString];
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:UDID forKey:@"UDID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //    NSLog(@"UDID %@", UDID);
    return [UDID stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

// 设备唯一ID(删除应用重装后ID可能变更)
- (NSString *)UUID
{
    NSString *UUID = nil;
    if (self.systemVersion.floatValue >= 6.0) {
        UUID = self.identifierForVendor.UUIDString;
    } else {
        UUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UUID"];
        if (!UUID.length) {
            CFUUIDRef UUIDRef = CFUUIDCreate(NULL);
            UUID = (__bridge NSString *)CFUUIDCreateString(NULL, UUIDRef);
            CFRelease(UUIDRef);
            
            [[NSUserDefaults standardUserDefaults] setValue:UUID forKey:@"UUID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return [UUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

#pragma mark - MAC Address

// 获取设备MAC地址
- (NSString *)MACAddress
{
    int                  mib[6];
    size_t               len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("macAddress: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("macAddress: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("macAddress: Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("macAddress: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    NSString *macAddress = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return macAddress;
}

#pragma mark - Keychain

// 将UDID存储keychain
- (BOOL)setUDIDToKeychain:(NSString*)UDID
{
    NSMutableDictionary *dictForAdd = [[NSMutableDictionary alloc] init];
    
    [dictForAdd setValue:(__bridge id)kSecClassGenericPassword                                  forKey:(__bridge id)kSecClass];
    [dictForAdd setValue:@""                                                                    forKey:(__bridge id)kSecAttrAccount];
    [dictForAdd setValue:@""                                                                    forKey:(__bridge id)kSecAttrLabel];
    [dictForAdd setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]            forKey:(__bridge id)kSecAttrDescription];
    [dictForAdd setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]            forKey:(__bridge id)kSecAttrGeneric];
    [dictForAdd setValue:[NSData dataWithBytes:UDID.UTF8String length:strlen(UDID.UTF8String)]  forKey:(__bridge id)kSecValueData];
    
    NSString *accessGroup = [NSString stringWithUTF8String:kKeychainUDIDAccessGroup];
    if (accessGroup) {
#if TARGET_IPHONE_SIMULATOR
        
#else
        [dictForAdd setValue:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
#endif
    }
    
    OSStatus writeErr = SecItemAdd((__bridge CFDictionaryRef)dictForAdd, NULL);
    if (writeErr == errSecSuccess) {
        //        NSLog(@"存储UDID到Keychain成功！");
        return YES;
    }else{
        //    NSLog(@"存储UDID到Keychain失败: %ld", writeErr);
        return NO;
    }
    
}

// 从keychain中获取UDID
- (NSString *)getUDIDFromKeychain
{
    NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
    [dictForQuery setValue:(__bridge id)kSecClassGenericPassword                                forKey:(__bridge id)kSecClass];
    [dictForQuery setValue:(__bridge id)kSecMatchLimitOne                                       forKey:(__bridge id)kSecMatchLimit];
    [dictForQuery setValue:(__bridge id)kCFBooleanTrue                                          forKey:(__bridge id)kSecMatchCaseInsensitive];
    [dictForQuery setValue:(__bridge id)kCFBooleanTrue                                          forKey:(__bridge id)kSecReturnData];
    [dictForQuery setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]          forKey:(__bridge id)kSecAttrDescription];
    [dictForQuery setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]          forKey:(__bridge id)kSecAttrGeneric];
    
    NSString *accessGroup = [NSString stringWithUTF8String:kKeychainUDIDAccessGroup];
    if (accessGroup) {
#if TARGET_IPHONE_SIMULATOR
        
#else
        [dictForQuery setValue:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
#endif
    }
    
    NSData *udidValue = nil;
    OSStatus queryErr = SecItemCopyMatching((__bridge CFDictionaryRef)dictForQuery, (void *)&udidValue);
    
    CFMutableDictionaryRef *dict = nil;
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    queryErr = SecItemCopyMatching((__bridge CFDictionaryRef)dictForQuery, (CFTypeRef *)&dict);
    if (queryErr == errSecSuccess) {
        NSString *udid = nil;
        if (udidValue) {
            udid = [NSString stringWithUTF8String:udidValue.bytes];
        }
        //        NSLog(@"从Keychain中获取UDID成功: %@", udid);
        return udid;
    } else {
        //        NSLog(@"从Keychain中获取UDID失败:%ld", queryErr);
        return nil;
    }
    
}

// 从keychain中移除UDID
- (BOOL)removeUDIDFromKeychain
{
    NSMutableDictionary *dictToDelete = [[NSMutableDictionary alloc] init];
    [dictToDelete setValue:(__bridge id)kSecClassGenericPassword                        forKey:(__bridge id)kSecClass];
    [dictToDelete setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]  forKey:(__bridge id)kSecAttrGeneric];
    
    OSStatus deleteErr = SecItemDelete((__bridge CFDictionaryRef)dictToDelete);
    if (deleteErr == errSecSuccess) {
        //        NSLog(@"从Keychain中删除UDID成功！");
        return YES;
    } else {
        //        NSLog(@"从Keychain中删除UDID失败: %ld", deleteErr);
        return NO;
    }
    
}

@end
