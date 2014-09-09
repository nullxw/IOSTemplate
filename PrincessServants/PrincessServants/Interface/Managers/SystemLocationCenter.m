//
//  SystemLocationUtil.m
//  ShadowFiend
//
//  Created by tixa on 14-6-30.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SystemLocationCenter.h"
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation UserLocation


@end

NSString *const authorizedUseLocationNotification = @"authorizedUseLocationNotification"; // 允许使用定位服务

NSString *const locationSucceedNotification = @"locationSucceedNotification";             // 定位成功通知
NSString *const locationFaildNotification = @"locationFaildNotification";                 // 定位失败通知


@interface SystemLocationCenter ()<MKMapViewDelegate,CLLocationManagerDelegate>
{
    // 地址解析
    CLGeocoder                 *_geocoder;
    CLGeocoder                 *_searchGeocoder;
    
    // 定位
    MKMapView                  *_mapView;
    // 上一次定位时间
    NSDate                     *_lastUpdateTime;
    // 当前第几次定位
    NSInteger                   _updateCount;
    // 未授权定位弹出框 是否弹出过
    BOOL                        _isAlert;
    
    // 经纬度--地址
    SuccessBlock                _geocodeFinish;
    FailBlock                   _geocodeFailure;
    
    // 地址--经纬度
    SuccessBlock                _searchFinish;
    FailBlock                   _searchFailure;
    
}

@property (nonatomic, strong) CLLocationManager    *locationManager;
@property (nonatomic, strong) UserLocation         *geocodeLocation;   // 保存逆地理解析得到的字符串地址
@property (nonatomic, strong) UserLocation         *searchLocation;    // 保存逆地理解析得到的经纬度

@end

@implementation SystemLocationCenter

static SystemLocationCenter *defaultCenterInstance = nil;

+ (instancetype)defaultCenter
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            defaultCenterInstance = [[self alloc] init];
        });
    }
    return defaultCenterInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _updateCount = 0;
        _isAlert = NO;
        _location = [[UserLocation alloc] init];
        _geocodeLocation = [[UserLocation alloc] init];
        _searchLocation = [[UserLocation alloc] init];
        
        _lastUpdateTime = [NSDate dateWithTimeIntervalSince1970:0];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _mapView = [[MKMapView alloc] init];

    }
    return self;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //    NSLog(@"status  ===%d", status);
    if (status == kCLAuthorizationStatusAuthorized) {
        [[NSNotificationCenter defaultCenter] postNotificationName:authorizedUseLocationNotification object:nil];
    }
}

// 检查位置信息是否需要更新   上次定位时间超过5分钟或者当前location无效返回YES(定位时间点只是定位触发更改,反地理解析经纬度和搜索地址解析经纬度都不会触发修改)
- (BOOL)shouldUpdateLocation
{
    return (!CLLocationCoordinate2DIsValid(self.location.userCoordinate) || [[NSDate date] timeIntervalSinceDate:_lastUpdateTime] >= 5 * 60);  // 更新间隔超过5分钟
}

#pragma mark -  定位失败提示

- (void)showFailToLocateAlert
{
    if (_isAlert == YES) {
        return;
    }
    _isAlert = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"定位失败" message:@"请在 [设置]—>[隐私]—>[定位服务] 中允许\n 确定您的位置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - 开始定位

- (void)startUpdatingLocation
{
    NSLog(@"startUpdatingLocation");
    
    if ([self shouldUpdateLocation]) {
        
        [self stopUpdatingLocation];
        if (![CLLocationManager locationServicesEnabled]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:locationFaildNotification object:nil];
            [self showFailToLocateAlert];
            return;
        }
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:locationSucceedNotification object:nil];
    }
    
}

- (void)stopUpdatingLocation
{
    NSLog(@"stopUpdatingLocation");
    
    _mapView.showsUserLocation = NO;
    _mapView.delegate = nil;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    _updateCount++;
    NSLog(@"第%d次定位--成功:  %f %f", _updateCount, userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    [self stopUpdatingLocation];
    
    if (_updateCount >= LOCATIONCOUNT) {
        _location.userCoordinate = userLocation.location.coordinate;
        _lastUpdateTime = [NSDate date];
        _updateCount = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:locationSucceedNotification object:nil];
        
    }else{
        [self startUpdatingLocation];
    }
    
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    _updateCount++;
    NSLog(@"第%d次定位--失败:  %@", _updateCount, error.description);
    [self stopUpdatingLocation];
    
    if (_updateCount >= LOCATIONCOUNT) {
        _updateCount = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:locationFaildNotification object:nil];
        
    }else{
        [self startUpdatingLocation];
    }
    
}

#pragma mark - 开始解析经纬度地址

- (void)startGeocoderAddressWithCoordinate:(CLLocationCoordinate2D)coordinate finish:(SuccessBlock)finish failure:(FailBlock)failure
{
    _geocodeFinish = finish;
    _geocodeFailure = failure;
    _geocodeLocation.userCoordinate = coordinate;
    NSLog(@"startGeocoderUserAddress:");
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) { // iOS5.0及以上系统
        [_geocoder cancelGeocode];
        if (!_geocoder) {
            _geocoder = [[CLGeocoder alloc] init];
        }
        
        [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            [self reverseGeocodeLocation:placemarks];
        }];
    } else { // iOS5.0以下系统
        if (_geocodeFailure) {
            _geocodeFailure(nil, @"需要iOS5.0及以上操作系统");
        }
    }
}

- (void)reverseGeocodeLocation:(NSArray *)placemarks
{
    //    NSLog(@"reverseGeocodeLocation==%@", placemarks);
    
    if (!placemarks.count) {
        if (_geocodeFailure) {
            _geocodeFailure(nil, @"地址解析失败");
        }
        return;
    }
    
    CLPlacemark *placeMark = placemarks.firstObject;
    
//    for (CLPlacemark *placeMark in placemarks) {
//        NSString *address = @"";
//        NSString *simpleAddress = @"";
//        if (placeMark.country != nil && ![placeMark.country isEqualToString:@"中国"]) {
//            address = [address stringByAppendingString:placeMark.country];
//        }
//        if (placeMark.administrativeArea != nil) {
//            address = [address stringByAppendingString:placeMark.administrativeArea];
//            NSLog(@"administrativeArea : %@", placeMark.administrativeArea);
//        }
//        if (placeMark.subAdministrativeArea != nil) {
//            address = [address stringByAppendingString:placeMark.subAdministrativeArea];
//            NSLog(@"subAdministrativeArea : %@", placeMark.subAdministrativeArea);
//        }
//        if (placeMark.locality != nil) {
//            address = [address stringByAppendingString:placeMark.locality];
//            simpleAddress = [simpleAddress stringByAppendingString:placeMark.locality];
//            //            NSLog(@"locality : %@", placeMark.locality);
//        }
//        if (placeMark.subLocality != nil) {
//            address = [address stringByAppendingString:placeMark.subLocality];
//            simpleAddress = [simpleAddress stringByAppendingString:placeMark.subLocality];
//            //            NSLog(@"subLocality : %@", placeMark.subLocality);
//        }
//        if (placeMark.thoroughfare != nil) {
//            address = [address stringByAppendingString:placeMark.thoroughfare];
//            //            NSLog(@"thoroughfare : %@", placeMark.thoroughfare);
//        }
//        if (placeMark.subThoroughfare != nil) {
//            address = [address stringByAppendingString:placeMark.subThoroughfare];
//            //            NSLog(@"subThoroughfare : %@", placeMark.subThoroughfare);
//        }
//    }
    
    NSString *address = @"";
    NSString *simpleAddress = @"";
    if (placeMark.country != nil && ![placeMark.country isEqualToString:@"中国"]) {
        address = ABCreateStringWithAddressDictionary(placeMark.addressDictionary,YES);
    }else{
        address = ABCreateStringWithAddressDictionary(placeMark.addressDictionary,NO);
    }
    
    if (placeMark.locality != nil) { // city
        simpleAddress = [simpleAddress stringByAppendingString:placeMark.locality];
    }
    if (placeMark.subLocality != nil) { // 地区
        simpleAddress = [simpleAddress stringByAppendingString:placeMark.subLocality];
    }
    
    _geocodeLocation.userPlacemark     = placeMark;
    _geocodeLocation.userAddress       = address;
    _geocodeLocation.userSimpleAddress = simpleAddress;
    if (address.length) {
        if (_geocodeFinish) {
            _geocodeFinish(nil, _geocodeLocation);
        }
    } else {
        if (_geocodeFailure) {
            _geocodeFailure(nil, @"地址解析失败");
        }
    }

}

// 搜索地址
- (void)startSearchAddressWithText:(NSString *)text inRegion:(CLRegion *)inRegion finish:(SuccessBlock)finish failure:(FailBlock)failure
{
    _searchFinish = finish;
    _searchFailure = failure;
    _searchLocation.userAddress = text;
    _searchLocation.userSimpleAddress = text;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) { // IOS5.0及以上系统
        [_searchGeocoder cancelGeocode];
        if (_searchGeocoder == nil) {
            _searchGeocoder = [[CLGeocoder alloc] init];
        }
        
        if (inRegion) { // 有搜索范围
            [_searchGeocoder geocodeAddressString:text inRegion:inRegion completionHandler:^(NSArray *placemarks, NSError *error) {
                [self reverseSearchGeocodeLocation:placemarks];
            }];
        } else {  // 无搜索范围
            [_searchGeocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error) {
                [self reverseSearchGeocodeLocation:placemarks];
            }];
        }
    } else {
        if (_searchFailure) {
            _searchFailure(nil, @"需要iOS5.0及以上操作系统");
        }
    }
}


#pragma mark - 解析搜索地址描述

- (void)reverseSearchGeocodeLocation:(NSArray *)placemarks
{
//    NSLog(@"reverseGeocodeLocation");
    if (!placemarks.count) {
        if (_searchFailure) {
            _searchFailure(nil, @"地址解析失败");
        }
    }
    
    CLPlacemark *placeMark = placemarks.firstObject;
    
//    for (CLPlacemark *placeMark in placemarks) {
//        NSString *address = @"";
//        NSString *simpleAddress = @"";
//        if (placeMark.country != nil && ![placeMark.country isEqualToString:@"中国"]) {
//            address = [address stringByAppendingString:placeMark.country];
//        }
//        if (placeMark.administrativeArea != nil) {
//            address = [address stringByAppendingString:placeMark.administrativeArea];
//            NSLog(@"administrativeArea : %@", placeMark.administrativeArea);
//        }
//        if (placeMark.subAdministrativeArea != nil) {
//            address = [address stringByAppendingString:placeMark.subAdministrativeArea];
//            NSLog(@"subAdministrativeArea : %@", placeMark.subAdministrativeArea);
//        }
//        if (placeMark.locality != nil) {
//            address = [address stringByAppendingString:placeMark.locality];
//            simpleAddress = [simpleAddress stringByAppendingString:placeMark.locality];
//            //            NSLog(@"locality : %@", placeMark.locality);
//        }
//        if (placeMark.subLocality != nil) {
//            address = [address stringByAppendingString:placeMark.subLocality];
//            simpleAddress = [simpleAddress stringByAppendingString:placeMark.subLocality];
//            //            NSLog(@"subLocality : %@", placeMark.subLocality);
//        }
//        if (placeMark.thoroughfare != nil) {
//            address = [address stringByAppendingString:placeMark.thoroughfare];
//            //            NSLog(@"thoroughfare : %@", placeMark.thoroughfare);
//        }
//        if (placeMark.subThoroughfare != nil) {
//            address = [address stringByAppendingString:placeMark.subThoroughfare];
//            //            NSLog(@"subThoroughfare : %@", placeMark.subThoroughfare);
//        }
//        
//        UserLocation *location = [[UserLocation alloc] init];
//        
//        location.userCoordinate    = placeMark.location.coordinate;
//        location.userPlacemark     = placeMark;
//        location.userAddress       = address;
//        location.userSimpleAddress = simpleAddress;
//        if (address.length) {
//            if (_searchFinish)  _searchFinish (nil, location);
//        } else {
//            if (_searchFailure) _searchFailure (nil, @"解析地址失败");
//        }
//        return;
//    }
    
    NSString *address = @"";
    NSString *simpleAddress = @"";
    if (placeMark.country != nil && ![placeMark.country isEqualToString:@"中国"]) {
        address = ABCreateStringWithAddressDictionary(placeMark.addressDictionary,YES);
    }else{
        address = ABCreateStringWithAddressDictionary(placeMark.addressDictionary,NO);
    }
    
    if (placeMark.locality != nil) { // city
        simpleAddress = [simpleAddress stringByAppendingString:placeMark.locality];
    }
    if (placeMark.subLocality != nil) { // 地区
        simpleAddress = [simpleAddress stringByAppendingString:placeMark.subLocality];
    }
    
    _searchLocation.userPlacemark     = placeMark;
    _searchLocation.userCoordinate    = placeMark.location.coordinate;

    if (address.length) {
        if (_geocodeFinish) {
            _geocodeFinish(nil, _geocodeLocation);
        }
    } else {
        if (_geocodeFailure) {
            _geocodeFailure(nil, @"地址解析失败");
        }
    }

}

#pragma mark - 输入提示 搜索

- (void)searchTipsWithKey:(NSString *)key coordinateRegion:(MKCoordinateRegion)region finish:(SuccessBlock)finish failure:(FailBlock)failure
{
    if (key.length == 0){
        if (failure) failure(nil, @"参数错误");
        return;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.1) { // IOS6.1及以上系统
        
        MKLocalSearchRequest * localSearchRequest = [[MKLocalSearchRequest alloc] init];
        localSearchRequest.naturalLanguageQuery = key;
        localSearchRequest.region = region;
        MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:localSearchRequest];
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            
            if(error){
                if (failure) failure(nil,[NSString stringWithFormat:@"%@",error]);
            }else{
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for(MKMapItem * item in response.mapItems){
                    [array addObject:item.name];
                }
                if(finish) finish(nil,array);
            }
            
        }];
        
    }else{
        if (failure) failure(nil, @"需要iOS6.1及以上操作系统");
    }
    
}

@end
