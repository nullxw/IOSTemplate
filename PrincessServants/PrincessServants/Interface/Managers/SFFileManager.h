//
//  SFFileManager.h
//  ShadowFiend
//
//  Created by tixa on 14-6-26.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"

@interface SFFileManager : SFObject

//  读取Documents文件夹下的序列化对象
+ (id)loadObject:(NSString *)path;
+ (NSMutableArray *)loadArray:(NSString *)path;  // 不存在的话,返回空数组
+ (NSMutableDictionary *)loadDictionary:(NSString *)path;  // 不存在的话,返回空字典

+ (UIImage *)loadImage:(NSString *)path;         // 读取图片(Documents文件夹下)
+ (UIImage *)loadCacheImage:(NSString *)path;    // 读取图片(Library/Caches文件夹下)


//  存储Documents文件夹下的序列化对象
+ (BOOL)saveObject:(id)object filePath:(NSString *)path;
+ (BOOL)saveCacheObject:(id)object filePath:(NSString *)path; // 存储序列化对象(Library/Caches文件夹下)
+ (BOOL)saveData:(NSData *)data filePath:(NSString *)path;    // 存储数据(Documents文件夹下)

+ (BOOL)fileExistsAtPath:(NSString *)path;       // 是否存在指定文件(Documents文件夹下)
+ (BOOL)createDirectoryAtPath:(NSString *)path;  // 创建指定路径文件夹(Documents文件夹下)
+ (BOOL)deleteFile:(NSString *)path;             // 删除指定文件(Documents文件夹下)
+ (BOOL)deleteCacheFile:(NSString *)path;        // 删除指定文件(Library/Caches文件夹下)

@end
