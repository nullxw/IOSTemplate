//
//  UIDevice+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (SFCategory)

/**
 *  设备唯一ID  7.0及以后使用self.identifierForVendor.UUIDString;  以前使用(MAC地址的MD5串)
 *  并且在钥匙串里面进行了存储,删除应用以后也不会改变    此处所说的UDID和开发者中心注册测试设备的UDID不是同一个
 *
 *  @return the udid string
 */
- (NSString *)UDID;

/**
 *  设备唯一ID(与UDID不同，每次创建产生新值。方法内已自动维护)
 *  6.0及以后使用self.identifierForVendor.UUIDString;  以前使用CFUUIDCreateString方法产生的uuid
 *  未在钥匙串里面进行存储
 *
 *  @return the uuid string
 */
- (NSString *)UUID;

/**
 *  获取设备MAC地址   7.0及以后返回的mac地址是一个固定字符串不具有唯一性
 *
 *  @return the mac address string
 */
- (NSString *)MACAddress;

@end
