//
//  ImageCache.m
//  ShadowFiend
//
//  Created by tixa on 14-6-26.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "ImageCache.h"
#import "SFFileManager.h"

#define kQueueNameDownloadImage @"downloadImage"

@interface ImageCache ()

@property (atomic, strong) NSMutableDictionary *userInfoDicitonary;

@end

@implementation ImageCache

static ImageCache *sharedCacheInstance = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cacheDictionary = [[NSMutableDictionary alloc] init];
        _tempCacheDictionary = [[NSMutableDictionary alloc] init];
        _threadsArray = [[NSMutableArray alloc] init];
        _userInfoDicitonary = [[NSMutableDictionary alloc] init];
        _isDownloadingImage = NO;
    }
    return self;
}

+ (instancetype)sharedCache
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            sharedCacheInstance = [[self alloc] init];
        });
    }
    return sharedCacheInstance;
}



#pragma mark - Cache Management

// 清空图片缓存
- (void)clearCache
{
    [_cacheDictionary removeAllObjects];
    [_tempCacheDictionary removeAllObjects];
}

// 清空临时图片缓存
- (void)clearTempCache
{
    [_tempCacheDictionary removeAllObjects];
}



#pragma mark - Data Management

/**
 *  图片文件路径
 *
 *  @param  图片的url字符串
 *
 *  @return "ImageCache/"+(urlString的GBK编码字符串)
 */
- (NSString *)pathForImage:(NSString *)urlString
{
    return [NSString stringWithFormat:@"ImageCache/%@", urlString.GBKEncodedString];
}

// 读取缓存图片
- (UIImage *)loadImageWithPath:(NSString *)urlString
{
    return [SFFileManager loadCacheImage:[self pathForImage:urlString]];
}

// 获取默认图片
- (UIImage *)defaultImageWithType:(DefaultImageType)type
{
    if (type == DefaultImageTypeError) {
        return [UIImage imageNamed:@"image_error"];
    }else if (type == DefaultImageTypeHeadMale){
        return [UIImage imageNamed:@"head_default_male"];
    }else if (type == DefaultImageTypeHeadFemale){
        return [UIImage imageNamed:@"head_default_female"];
    }else if (type == DefaultImageTypeNormal){
        return [UIImage imageNamed:@"image_default"];
    }else if (type == DefaultImageTypeThumbnail){
        return [UIImage imageNamed:@"image_default_thumb"];
    }else if (type == DefaultImageTypeLogo){
        return [UIImage imageNamed:@"head_default_group"];
    }
    return nil;
    
}

// 加载指定文件路径的图片  Documents文件夹下
- (UIImage *)imageWithFile:(NSString *)filePath defaultType:(DefaultImageType)defaultType
{
    UIImage *image = [_cacheDictionary objectForKey:filePath];
    if (!image) {
        image = [SFFileManager loadImage:filePath];
        if (image) {
            [_cacheDictionary setObject:image forKey:filePath];
        }
    }
    return image ? image : [self defaultImageWithType:defaultType];
}

- (UIImage *)imageWithFile:(NSString *)filePath defaultImage:(UIImage *)defaultImage
{
    UIImage *image = [_cacheDictionary objectForKey:filePath];
    if (!image) {
        image = [SFFileManager loadImage:filePath];
        if (image) {
            [_cacheDictionary setObject:image forKey:filePath];
        }
    }
    return image ? image : defaultImage;
}

// 加载指定URL路径的图片
- (UIImage *)imageWithPath:(NSString *)urlString defaultImage:(UIImage *)defaultImage target:(id)target shouldDownload:(BOOL)shouldDownload
{
	UIImage *image = nil;
    if (urlString.length) {// 图片地址有效
        image = [_cacheDictionary objectForKey:urlString]; // 内存缓存
        
        if (!image) { // 无内存缓存
            image = [self loadImageWithPath:urlString]; // 本地文件缓存
            if (image) { // 有持久化本地文件缓存
                [_cacheDictionary setObject:image forKey:urlString];
            } else if (shouldDownload) { // 无持久化缓存文件,下载
                if (![_threadsArray containsObject:urlString]) { // 未正在加载
                    [_threadsArray addObject:urlString];
                    
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:urlString forKey:@"urlString"];
                    [userInfo setValue:[NSNumber numberWithBool:NO] forKey:@"isTemp"];
                    if (defaultImage) {
                        [userInfo setValue:defaultImage forKey:@"defaultImage"];
                    }
                    if (target) {
                        [userInfo setValue:[NSMutableArray arrayWithObject:target] forKey:@"target"];
                    }
                    [_userInfoDicitonary setValue:userInfo forKey:urlString];
                    
                    [self performSelectorInBackground:@selector(downloadImage:) withObject:userInfo];
                } else if (target) { // 正在加载且需要回调
                    NSMutableDictionary *userInfo = [_userInfoDicitonary valueForKey:urlString];
                    NSMutableArray *targetsArray = [userInfo valueForKey:@"target"];
                    targetsArray = targetsArray ? targetsArray : [NSMutableArray array];
                    if (![targetsArray containsObject:target]) {
                        [targetsArray addObject:target];
                        [userInfo setValue:targetsArray forKey:@"target"];
                    }
                }
                
                // 加载状态
                if ([target isKindOfClass:[UIImageView class]]) {
                    UIImageView *targetView = (UIImageView *)target;
                    
                    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[targetView viewWithTag:7788];
                    if (!indicatorView) {
                        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                        indicatorView.tag = 7788;
                        indicatorView.center = CGPointMake(CGRectGetMidX(targetView.bounds), CGRectGetMidY(targetView.bounds));
                        [targetView addSubview:indicatorView];
                        
                        [indicatorView startAnimating];
                    }
                }
            }
        }
    }
    return image ? image : defaultImage;
}

// 异步读取指定URL图片
- (void)downloadImage:(NSMutableDictionary *)userInfo
{
    @autoreleasepool {
        _isDownloadingImage = YES;
        NSString *urlString = [userInfo valueForKey:@"urlString"];
        // 此处是同步下载,如果网络不好有可能阻塞在这里.  超过默认时间之后返回的imageData将会是nil
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingMappedIfSafe error:nil];
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        UIImage *image = [UIImage imageWithData:imageData];
        _isDownloadingImage = NO;
        if ([[userInfo valueForKey:@"isTemp"] boolValue]) { // 临时图片
            if (!image) { // 图片损坏
                image = [userInfo valueForKey:@"defaultImage"];
            }
            [_tempCacheDictionary setObject:image forKey:urlString]; // 添加图片至临时内存缓存
        } else { // 非临时图片
            if (!image) { // 图片损坏
                image = [userInfo valueForKey:@"defaultImage"];
            } else { // 本地缓存图片文件
                [SFFileManager saveCacheObject:image filePath:[self pathForImage:urlString]];
            }
            
            if (image) { // 默认图片不是nil
                [_cacheDictionary setObject:image forKey:urlString]; // 添加图片至内存缓存
            }
            
        }
        [_threadsArray removeObject:urlString];
        
        // 刷新图片容器
        NSMutableArray *targetsArray = [[_userInfoDicitonary valueForKey:urlString] valueForKey:@"target"];
        for (id target in targetsArray) {
            // 去除加载状态
            if ([target isKindOfClass:[UIImageView class]]) {
                UIImageView *targetView = (UIImageView *)target;
                for (UIView *subview in targetView.subviews) {
                    if ([subview isKindOfClass:[UIActivityIndicatorView class]]) {
                        UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)subview;
                        [activityIndicatorView stopAnimating];
                        [activityIndicatorView removeFromSuperview];
                        break;
                    }
                }
            }
            
            if ([target isKindOfClass:[UIView class]] && [(UIView *)target superview]) {
                if ([target respondsToSelector:@selector(reloadData)]) {
                    [target performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                } else if ([target respondsToSelector:@selector(setImage:)]) {
                    [target performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                } else if ([target respondsToSelector:@selector(setImage:forState:)]) {
                    [target setImage:image forState:UIControlStateNormal];
                } else if ([target respondsToSelector:@selector(setNeedsDisplay)]) {
                    [target performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
                }
            }
        }
        // 清除下载时存储的信息
        [_userInfoDicitonary removeObjectForKey:urlString];
    }
    
}

// 加载指定URL路径的图片
- (UIImage *)imageWithPath:(NSString *)urlString defaultImage:(UIImage *)defaultImage target:(id)target
{
    return [self imageWithPath:urlString defaultImage:defaultImage target:target shouldDownload:YES];
}

// 加载指定URL路径的图片
- (UIImage *)imageWithPath:(NSString *)urlString defaultType:(DefaultImageType)defaultType target:(id)target
{
    return [self imageWithPath:urlString defaultImage:[self defaultImageWithType:defaultType] target:target shouldDownload:YES];
}

// 加载指定URL路径的临时图片
- (UIImage *)tempImageWithPath:(NSString *)urlString defaultType:(DefaultImageType)defaultType target:(id)target
{
	UIImage *image = nil;
    if (urlString.length) { // 图片地址有效
        image = [_tempCacheDictionary objectForKey:urlString]; // 临时缓存
        if (!image && ![_threadsArray containsObject:urlString]) { // 临时无缓存且未正在加载
            [_threadsArray addObject:urlString];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:urlString forKey:@"urlString"];
            [userInfo setValue:[NSNumber numberWithBool:YES] forKey:@"isTemp"];
            UIImage *defaultImage = [self defaultImageWithType:defaultType];
            if (defaultImage) {
                [userInfo setValue:defaultImage forKey:@"defaultImage"];
            }
            if (target) {
                [userInfo setValue:[NSMutableArray arrayWithObject:target] forKey:@"target"];
            }
            [_userInfoDicitonary setValue:userInfo forKey:urlString];
            [self performSelectorInBackground:@selector(downloadImage:) withObject:userInfo];
//            [NSThread detachNewThreadSelector:@selector(downloadImage:) toTarget:self withObject:userInfo];
        }
    }
    return image ? image : [self defaultImageWithType:defaultType];
}

@end
