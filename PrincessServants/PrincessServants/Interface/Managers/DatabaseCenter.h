//
//  DatabaseCenter.h
//  ShadowFiend
//
//  Created by tixa on 14-6-27.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"

#define DatabaseName  @"PrincessServants"   // 程序数据库会存在Documents/Database文件夹下   这是默认创建的数据库

@class FMDatabase;

@interface DatabaseCenter : SFObject

/**
 *  数据库中心单例生成 已经创建默认数据库
 *
 *  @return 数据库中心单例
 */
+ (instancetype)defaultCenter;

/**
 *  往数据库中心注册数据库(Documents文件夹下)
 *  默认已经加入的数据库:@"PrincessServants"
 *
 *  @param DBName 数据库名
 */
- (void)registerDocumentDBWithDBName:(NSString *)DBName;

/**
 *  往数据库中心注册数据库(程序内置数据库)
 *
 *  @param DBName 数据库名
 */
- (void)registerLocalDBWithDBName:(NSString *)DBName;


#pragma mark - 数据库执行sql语句(增删改)

/**
 *  数据库执行sql语句(增删改)
 *
 *  @param DBName  数据库名
 *  @param sqls    将要执行的sql语句字符串数组
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)executeUpdateInDatabaseWithDBName:(NSString *)DBName
                                     sqls:(NSArray *)sqls
                                  success:(void (^)(FMDatabase *db))success
                                  failure:(void (^)(NSString *error))failure;


#pragma mark - 事务执行sql语句(增删改)

/**
 *  事务执行sql语句(增删改)
 *
 *  @param DBName  数据库名
 *  @param sqls    将要执行的sql语句字符串数组
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)executeUpdateInTransactionWithDBName:(NSString *)DBName
                                        sqls:(NSArray *)sqls
                                     success:(void (^)(FMDatabase *db))success
                                     failure:(void (^)(NSString *error))failure;


#pragma mark - 事务执行sql语句(查)

/**
 *  事务执行sql语句(查)
 *
 *  @param DBName  数据库名
 *  @param sqls    将要执行的sql语句字符串数组
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)executeQueryInTransactionWithDBName:(NSString *)DBName
                                    sqls:(NSArray *)sqls
                                 success:(void (^)(NSArray *results))success
                                 failure:(void (^)(NSString *error))failure;

#pragma mark - 使用已知参数 创建表
/**
 *  创建表  已自动添加"id"自增列
 *
 *  @param tableName  表名
 *  @param columnKeys 列名数组
 *  @param success    成功回调
 *  @param failure    失败回调
 */
- (void)createTableWithName:(NSString *)tableName
                 columnKeys:(NSArray *)columnKeys
                    success:(void (^)(FMDatabase *db))success
                    failure:(void (^)(NSString *error))failure;


#pragma mark - 使用已知参数  (增删改)修改表
/**
 *  向指定表插入或更新单条数据(仅支持NSString、NSNumber、NSURL、NSDate)
 *
 *  @param tableName       表名
 *  @param recordID        "id"自增列的值,如果数据库中存在此值则覆盖所在记录的内容,如果数据库中不存在此值则插入一条记录
 *                         如果recordID小于等于0,则会在数据库尾部添加一条记录,"id"列自增
 *  @param valueDictionary 相应记录的设值字典   列名对应key,列值对应value  不必再考虑"id"自增列
 *  @param success         成功回调
 *  @param failure         失败回调
 */
- (void)insertOrUpdateTable:(NSString *)tableName
                     withRecordID:(NSInteger)recordID   // id自增列的值
                  valueDictionary:(NSDictionary *)valueDictionary
                          success:(void (^)(FMDatabase *db))success
                          failure:(void (^)(NSString *error))failure;

/**
 *  更新表数据(仅支持NSString、NSNumber、NSURL、NSDate)  上面方法和此方法类似,区别在于上面方法使用的是自增列判断.
 *  此方法使用的是条件字典,满足相应的条件的记录进行更新。有可能满足条件的不止一条记录
 *
 *  @param tableName       表名
 *  @param valueDictionary 设值字典
 *  @param queryDictionary 条件字典  where后面的条件
 *  @param otherStatement  其他条件
 *  @param success         成功回调
 *  @param failure         失败回调
 */
- (void)updateTableWithName:(NSString *)tableName
            valueDictionary:(NSDictionary *)valueDictionary
            queryDictionary:(NSDictionary *)queryDictionary
             otherStatement:(NSString *)otherStatement
                    success:(void (^)(FMDatabase *db))success
                    failure:(void (^)(NSString *error))failure;

/**
 *  删除指定表指定条件的数据
 *
 *  @param tableName       表名
 *  @param queryDictionary 条件字典  where后面的条件
 *  @param otherStatement  其他条件
 *  @param success         成功回调
 *  @param failure         失败回调
 */
- (void)deleteTableWithName:(NSString *)tableName
            queryDictionary:(NSDictionary *)queryDictionary
             otherStatement:(NSString *)otherStatement
                    success:(void (^)(FMDatabase *db))success
                    failure:(void (^)(NSString *error))failure;


#pragma mark - 使用已知参数 查询表

/**
 *  查询指定表指定字段的值(默认均为NSString)
 *
 *  @param tableName       表名
 *  @param selectKey       查询列  select后面的,不设置默认是 *
 *  @param queryDictionary 条件字典  where后面的条件
 *  @param otherStatement  其他条件
 *  @param success         成功回调
 *  @param failure         失败回调
 */
- (void)queryTable:(NSString *)tableName
     withSelectKey:(NSString *)selectKey
   queryDictionary:(NSDictionary *)queryDictionary
    otherStatement:(NSString *)otherStatement
           success:(void (^)(NSArray *results))success
           failure:(void (^)(NSString *error))failure;


@end
