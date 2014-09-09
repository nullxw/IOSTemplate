//
//  SystemLocationUtil.h
//  ShadowFiend
//
//  Created by tixa on 14-6-30.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"
#import <Mapkit/Mapkit.h>

#define LOCATIONCOUNT 2   // 定位次数 提高定位精确度     // 尚不确定可用性(songqg标记)

extern NSString *const authorizedUseLocationNotification;   // 允许使用定位服务触发通知

extern NSString *const locationSucceedNotification;         // 定位成功通知
extern NSString *const locationFaildNotification;           // 定位失败通知

#if NS_BLOCKS_AVAILABLE

typedef void (^SuccessBlock)(NSDictionary *userInfo, id JSONValue);
typedef void (^FailBlock)(NSDictionary *userInfo, NSString *error);

#endif

@interface UserLocation : SFObject

@property (nonatomic)         CLLocationCoordinate2D   userCoordinate;
@property (nonatomic, strong) NSString                *userAddress;         // 字符串地址 中国以外的地区包含国家
@property (nonatomic, strong) NSString                *userSimpleAddress;   // 从市开始的简要字符串地址
@property (nonatomic, strong) CLPlacemark             *userPlacemark;


@end

@interface SystemLocationCenter : SFObject


@property (nonatomic, strong) UserLocation *location;          // 保存定位得到的用户信息


+ (instancetype)defaultCenter;

/**
 *  定位成功返回的UserLocation 只有经纬度有效,并未进行反地理位置解析
 *
 */
- (void)startUpdatingLocation;


/**
 *  将经纬度 解析为字符串地址     返回结果中,经纬度保存的是被解析的经纬度,并不是userPlacemark的
 *  不允许在第一次解析未完成之前进行第二次解析调用,若如此操作第一次解析将被cancel,并进行第二次解析
 *  @param coordinate  需要解析的经纬度
 *  @param finish
 *  @param failure
 */
- (void)startGeocoderAddressWithCoordinate:(CLLocationCoordinate2D)coordinate
                                    finish:(SuccessBlock)finish
                                   failure:(FailBlock)failure;


/**
 *  搜索地址 解析为UserLocation    返回结果中,userAddress和userSimpleAddress是text,并不是userPlacemark的
 *  不允许在第一次解析未完成之前进行第二次解析调用,若如此操作第一次解析将被cancel,并进行第二次解析
 *  @param text     字符串地址
 *  @param inRegion 字符串地址所在的区域  可以为nil
 *  @param finish
 *  @param failure
 */
- (void)startSearchAddressWithText:(NSString *)text
                          inRegion:(CLRegion *)inRegion
                            finish:(SuccessBlock)finish
                           failure:(FailBlock)failure;


#pragma mark - 输入提示 搜索
/**
 *  搜索某个区域附近的一些和关键字相关的地址
 *  搜索得到的数据是一个MKMapItem对应name属性组成的数组
 *
 *  @param key        搜索的关键字
 *  @param region     搜索的关键字所在的区域
 *  @param finish
 *  @param failure
 */
- (void)searchTipsWithKey:(NSString *)key coordinateRegion:(MKCoordinateRegion)region finish:(SuccessBlock)finish failure:(FailBlock)failure;    // 需要iOS6.1及以上操作系统

@end
