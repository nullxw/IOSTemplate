//
//  ImageCache.h
//  ShadowFiend
//
//  Created by tixa on 14-6-26.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"

typedef enum {
    DefaultImageTypeError       = -1,  // 错误
    DefaultImageTypeNone        = 0,   // 未知
    DefaultImageTypeHeadMale    = 1,   // 男头像
    DefaultImageTypeHeadFemale  = 2,   // 女头像
    DefaultImageTypeNormal      = 3,   // 正常图
    DefaultImageTypeThumbnail   = 4,   // 小图
    DefaultImageTypeLogo        = 5,   // Logo
    
} DefaultImageType;

@interface ImageCache : SFObject
{
    NSMutableDictionary       *_cacheDictionary;        // 图片缓存
    NSMutableDictionary       *_tempCacheDictionary;    // 临时图片缓存
    NSMutableArray            *_threadsArray;           // 线程池模拟数组
}

@property (nonatomic) BOOL isDownloadingImage;          // 是否正在下载图片    // 此标记存在问题多个图片同时下载标记会发生混乱

+ (instancetype)sharedCache;

/**
 *  清空图片缓存和临时图片缓存两个字典  也就是清除内存缓存
 */
- (void)clearCache;
/**
 *  清空临时图片缓存字典
 */
- (void)clearTempCache;


// 获取默认图片   DefaultImageTypeNone 返回nil
- (UIImage *)defaultImageWithType:(DefaultImageType)type;

/**
 *  Documents文件夹下
 *
 *  @param filePath    文件路径
 *  @param defaultType 规定好的默认图片类型
 *
 *  @return 图片
 */
- (UIImage *)imageWithFile:(NSString *)filePath defaultType:(DefaultImageType)defaultType;

/**
 *  Documents文件夹下
 *
 *  @param filePath    文件路径
 *  @param defaultType 自定义的默认图片
 *
 *  @return 图片
 */
- (UIImage *)imageWithFile:(NSString *)filePath defaultImage:(UIImage *)defaultImage;


/**
 *  加载指定URL路径的图片
 *
 *  @param urlString      网络连接path  如果url无效,则会返回默认图片
 *  @param defaultImage   自定义的默认图片
 *  @param target         加载效果添加的target 一般是图片所在的imageView
 *  @param shouldDownload 是否进行下载 YES:没有缓存则会下载并进行缓存. NO:没有缓存则不会进行下载直接使用默认图片
 *
 *  @return 图片
 */
- (UIImage *)imageWithPath:(NSString *)urlString
              defaultImage:(UIImage *)defaultImage
                    target:(id)target
            shouldDownload:(BOOL)shouldDownload;

/**
 *  加载指定URL路径的图片  默认没有缓存则进行下载
 *
 *  @param urlString    网络连接path  如果url无效,则会返回默认图片
 *  @param defaultImage 自定义的默认图片
 *  @param target       加载效果添加的target 一般是图片所在的imageView
 *
 *  @return 图片
 */
- (UIImage *)imageWithPath:(NSString *)urlString defaultImage:(UIImage *)defaultImage target:(id)target;


/**
 *  加载指定URL路径的图片  默认没有缓存则进行下载
 *
 *  @param urlString    网络连接path  如果url无效,则会返回默认图片
 *  @param defaultImage 规定好的默认图片类型
 *  @param target       加载效果添加的target 一般是图片所在的imageView
 *
 *  @return 图片
 */
- (UIImage *)imageWithPath:(NSString *)urlString
               defaultType:(DefaultImageType)defaultType
                    target:(id)target;

/**
 *  不会持久化缓存临时图片
 *
 *  @param urlString   网络连接path  如果url无效,则会返回默认图片
 *  @param defaultType 规定好的默认图片类型
 *  @param target      加载效果添加的target 一般是图片所在的imageView
 *
 *  @return 图片
 */
- (UIImage *)tempImageWithPath:(NSString *)urlString defaultType:(DefaultImageType)defaultType target:(id)target;

@end
