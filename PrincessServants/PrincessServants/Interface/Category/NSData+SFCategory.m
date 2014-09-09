//
//  NSData+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "NSData+SFCategory.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (SFCategory)

- (NSString *)md5
{
    unsigned char result[16];
    CC_MD5(self.bytes, self.length, result);
    NSString *hash = [NSString stringWithFormat:
                      @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3],
                      result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11],
                      result[12], result[13], result[14], result[15]
                      ];
    return hash;
}

@end
