//
//  DatabaseCenter.m
//  ShadowFiend
//
//  Created by tixa on 14-6-27.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "DatabaseCenter.h"
#import "SFFileManager.h"
#import "FMDB.h"

@interface DatabaseCenter ()

@property (nonatomic, strong) NSMutableDictionary *dbCache;

@end

@implementation DatabaseCenter

static DatabaseCenter *defaultManagerInstance = nil;


+ (instancetype)defaultCenter
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            defaultManagerInstance = [[self alloc] init];
        });
    }
    return defaultManagerInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.dbCache = [[NSMutableDictionary alloc] init];
        // 往数据库中心注册数据库(Documents文件夹下)
        [self registerDocumentDBWithDBName:DatabaseName];
        // 往数据库中心注册数据库(程序内置数据库)
//        [self registerLocalDBWithDBName:DatabaseName];
        
    }
    return  self;
}

// 获得对应的数据库的存储path,并不是完整地址
- (NSString *)documentsDatabasePathWithDBName:(NSString *)DBName
{
    return [NSString stringWithFormat:@"Database/%@",DBName];
}

// 往数据库中心注册数据库(Documents文件夹下)
- (void)registerDocumentDBWithDBName:(NSString *)DBName
{
    if (!DBName.length) return;
    if ([_dbCache objectForKey:DBName]) return;
    
    // 如果数据库不存在将会创建数据库
    NSString *path = [self documentsDatabasePathWithDBName:DBName];
    
    if (![SFFileManager fileExistsAtPath:path]) {
        [SFFileManager createDirectoryAtPath:path];
    }
    
    FMDatabaseQueue *resgisterDB = [FMDatabaseQueue databaseQueueWithPath:path.documentFilePath];
    [_dbCache setObject:resgisterDB forKey:DBName];
    
}

// 往数据库中心注册数据库(程序内置数据库)
- (void)registerLocalDBWithDBName:(NSString *)DBName
{
    if (!DBName.length) return;
    if ([_dbCache objectForKey:DBName]) return;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:DBName ofType:@"db"];
    FMDatabaseQueue *resgisterDB = [FMDatabaseQueue databaseQueueWithPath:path];
    [_dbCache setObject:resgisterDB forKey:DBName];
}


#pragma mark - 数据库执行sql语句（增删改）

- (void)executeUpdateInDatabaseWithDBName:(NSString *)DBName
                                     sqls:(NSArray *)sqls
                                  success:(void (^)(FMDatabase *db))success
                                  failure:(void (^)(NSString *error))failure
{
    if (!DBName.length) {
        if (failure) failure (NSLocalizedString(@"请指定要操作的数据库名称", nil)); return;
    }
    if (!sqls.count) {
        if (failure) failure (NSLocalizedString(@"操作失败", nil));
        return;
    }
    FMDatabaseQueue *currentDB = [_dbCache objectForKey:DBName];
    if (!currentDB) {
        failure ([NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"没有", nil), DBName, NSLocalizedString(@"数据库", nil)]); return;
    }
    
    NSLog(@"self.dbQueue===%@", currentDB);
    
    [currentDB inDatabase:^(FMDatabase *db) {
        for (NSString *sql in sqls) {
            
            BOOL result = [db executeUpdate:sql];
            NSString *value = result? @"成功": @"失败";
            NSLog(@"sql:%@执行%@", sql, value);
        }
        if (success) success (db);
    }];
}

#pragma mark - 事务执行sql语句（增删改）

- (void)executeUpdateInTransactionWithDBName:(NSString *)DBName
                                        sqls:(NSArray *)sqls
                                     success:(void (^)(FMDatabase *db))success
                                     failure:(void (^)(NSString *error))failure
{
    if (!DBName.length) {
        if (failure) failure (NSLocalizedString(@"请指定要操作的数据库名称", nil)); return;
    }
    if (!sqls.count) {
        if (failure) failure (NSLocalizedString(@"操作失败", nil));
        return;
    }
    FMDatabaseQueue *currentDB = [_dbCache objectForKey:DBName];
    if (!currentDB) {
        failure ([NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"没有", nil), DBName, NSLocalizedString(@"数据库", nil)]); return;
    }
    
    [currentDB inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *sql in sqls) {
            BOOL result = [db executeUpdate:sql];
            NSString *value = result? @"成功": @"失败";
            NSLog(@"sql:%@执行%@", sql, value);
        }
        if (success) success (db);
    }];
}


#pragma mark - 事务执行sql语句（查）

- (void)executeQueryInTransactionWithDBName:(NSString *)DBName
                                       sqls:(NSArray *)sqls
                                    success:(void (^)(NSArray *results))success
                                    failure:(void (^)(NSString *error))failure
{
    if (!DBName.length) {
        if (failure) failure (NSLocalizedString(@"请指定要操作的数据库名称", nil)); return;
    }
    if (!sqls.count) {
        if (failure) failure (NSLocalizedString(@"操作失败", nil));
        return;
    }
    FMDatabaseQueue *currentDB = [_dbCache objectForKey:DBName];
    if (!currentDB) {
        failure ([NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"没有", nil), DBName, NSLocalizedString(@"数据库", nil)]); return;
    }
    [currentDB inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *resultsArray = [NSMutableArray array];
        
        for (NSString *sql in sqls) {
            FMResultSet *rs = [db executeQuery:sql];
            if (rs) {
                NSLog(@"查询sql=%@成功", sql);
            }
            while ([rs next])
            {
                NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
                for (NSInteger i = 0; i < rs.columnCount; i++) {
                    NSString *key = [rs columnNameForIndex:i];
                    if ([key isEqualToString:@"id"]) {
                        [resultDictionary setValue:[NSString stringWithFormat:@"%d", [rs intForColumnIndex:i]] forKey:key];
                    } else {
                        NSString *text = [rs stringForColumnIndex:i];
                        if (text) {
                            [resultDictionary setValue:text forKey:key];
                        }
                    }
                }
                [resultsArray addObject:resultDictionary];
            }
        }
        
        if (success) success(resultsArray);
    }];
}


#pragma mark - 基本接口(仅支持字符串字段)

// 数据库字符串
- (NSString *)sqlString:(id)value
{
    NSString *valueString = @"";
    if ([value isKindOfClass:[NSString class]]) {
        valueString = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    } else if ([value isKindOfClass:[NSURL class]]) {
        valueString = [[value absoluteString] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        valueString = [value stringValue];
    } else if ([value isKindOfClass:[NSDate class]]) {
        valueString = [[NSDateFormatter defaultDateFormatter] stringFromDate:value];
    }
    
    return valueString;
}

// 查询条件字段
- (NSString *)queryStatement:(NSDictionary *)queryDictionary
{
    NSString *queryStatement = @"";
    for (NSString *key in queryDictionary.allKeys) {
        NSString *valueString = [self sqlString:[queryDictionary valueForKey:key]];
        valueString = valueString ? valueString : @"";
        queryStatement = [queryStatement stringByAppendingFormat:@"%@='%@' AND ", key, valueString];
    }
    if (queryStatement.length) {
        queryStatement = [queryStatement substringToIndex:queryStatement.length - 4];
    }
    
    return queryStatement;
}

// 更新设置字段
- (NSString *)updateStatement:(NSDictionary *)valueDictionary
{
    NSString *updateStatement = @"";
    for (NSString *key in valueDictionary.allKeys) {
        NSString *valueString = [self sqlString:[valueDictionary valueForKey:key]];
        valueString = valueString ? valueString : @"";
        updateStatement = [updateStatement stringByAppendingFormat:@"%@=%@, ", key, valueString];
    }
    if (updateStatement.length) {
        updateStatement = [updateStatement substringToIndex:updateStatement.length - 2];
    }
    
    return updateStatement;
}


#pragma mark - 创建sql语句  仅仅只是创建sql语句,并未执行sql语句
/**
 *  生成创建表sql语句  已自动添加"id"自增列
 *
 *  @param name       表名
 *  @param columnKeys 列名数组
 *
 *  @return sql语句
 */
- (NSString *)createTableWithName:(NSString *)name
                       columnKeys:(NSArray *)columnKeys
{
    if (!name.length || !columnKeys.count) {
        NSLog(@"创建表“%@”失败: 参数错误", name);
        return nil;
    }
    
    NSString *columnsStatement = @"'id' INTEGER PRIMARY KEY AUTOINCREMENT";
    for (NSInteger i = 0; i < columnKeys.count; i++) {
        NSString *key = [columnKeys objectAtIndex:i];
        columnsStatement = [columnsStatement stringByAppendingFormat:@", '%@' TEXT", key];
    }
    NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", name, columnsStatement];
    NSLog(@"创建SQLITE语句为: %@", sqlString);
    
    return sqlString;
}

/**
 *  向指定表插入或更新单条数据(仅支持NSString、NSNumber、NSURL、NSDate)
 *
 *  @param tableName    表名
 *  @param recordID     "id"自增列的值,如果数据库中存在此值则覆盖所在记录的内容,如果数据库中不存在此值则插入一条记录
 *  @param columnKeys   列名数组
 *  @param columnValues 各列对应的value
 *
 *  @return sql语句
 */
- (NSString *)insertOrUpdateTable:(NSString *)tableName
                     withRecordID:(NSInteger)recordID
                       columnKeys:(NSArray *)columnKeys
                     columnValues:(NSArray *)columnValues
{
    if (!tableName.length || !columnKeys.count || !columnValues.count || columnKeys.count != columnValues.count) {
        NSLog(@"表“%@”插入数据失败: 参数错误", tableName);
        return nil;
    } else {
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id value in columnValues) {
            NSString *valueString = [self sqlString:value];
            valueString = valueString ? valueString : @"";
            [tempArray addObject:valueString];
        }
        
        NSString *sqlString = @"";
        if (recordID > 0) {
            sqlString = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ('id', '%@') VALUES ('%d', '%@')", tableName, [columnKeys componentsJoinedByString:@"', '"], recordID, [tempArray componentsJoinedByString:@"', '"]];
        } else {
            sqlString = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ('%@') VALUES ('%@') ", tableName, [columnKeys componentsJoinedByString:@"', '"], [tempArray componentsJoinedByString:@"', '"]];
        }
        NSLog(@"创建SQLITE语句为: %@", sqlString);
        
        return sqlString;
        
    }
    
    return nil;
}

/**
 *  更新表数据(仅支持NSString、NSNumber、NSURL、NSDate)  上面方法和此方法类似,区别在于上面方法使用的是自增列判断.
 *  此方法使用的是条件字典,满足相应的条件的记录进行更新。有可能满足条件的不止一条记录
 *
 *  @param tableName       表名
 *  @param valueDictionary 设值字典
 *  @param queryDictionary 条件字典  where后面的条件
 *  @param otherStatement  其他条件
 *
 *  @return sql语句
 */
- (NSString *)updateTableWithName:(NSString *)tableName
                  valueDictionary:(NSDictionary *)valueDictionary
                  queryDictionary:(NSDictionary *)queryDictionary
                   otherStatement:(NSString *)otherStatement
{
    if (!tableName.length || !valueDictionary.count || !queryDictionary.count) {
        NSLog(@"表“%@”更新数据失败: 参数错误", tableName);
        return nil;
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ %@", tableName, [self updateStatement:valueDictionary], [self queryStatement:queryDictionary], otherStatement.length ? otherStatement : @""];
    NSLog(@"创建SQLITE语句为: %@", sqlString);
	
	return sqlString;
}

/**
 *  删除指定表指定条件的数据
 *
 *  @param tableName       表名
 *  @param queryDictionary 条件字典  where后面的条件
 *  @param otherStatement  其他条件
 */
- (NSString *)deleteTableWithName:(NSString *)tableName
                  queryDictionary:(NSDictionary *)queryDictionary
                   otherStatement:(NSString *)otherStatement
{
    if (!tableName.length || !queryDictionary.count) {
        NSLog(@"表“%@”删除数据失败: 参数错误", tableName);
        return nil;
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ %@", tableName, [self queryStatement:queryDictionary], otherStatement.length ? otherStatement : @""];
    NSLog(@"创建SQLITE语句为: %@", sqlString);
    
    return sqlString;
}

// 查询SQL语句
- (NSString *)querySqlWithTable:(NSString *)table
                  withSelectKey:(NSString *)selectKey
                      queryKeys:(NSArray *)queryKeys
                    queryValues:(NSArray *)queryValues
                 otherStatement:(NSString *)otherStatement
{
    if (!table.length || queryKeys.count != queryValues.count) {
        NSLog(@"表“%@”查询数据失败: 参数错误", table);
    } else {
        NSString *selectStatement = selectKey.length ? selectKey : @"*";
        
        NSString *queryStatement = @"";
        for (NSInteger i = 0; i < queryKeys.count; i++) {
            NSString *key = [queryKeys objectAtIndex:i];
            NSString *value = [self sqlString:[queryValues objectAtIndex:i]];
            queryStatement = [queryStatement stringByAppendingFormat:@"%@='%@' AND ", key, value];
        }
        if (queryStatement.length) {
            queryStatement = [NSString stringWithFormat:@"WHERE %@", [queryStatement substringToIndex:queryStatement.length - 4]];
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT %@ FROM %@ %@ %@", selectStatement, table, queryStatement, otherStatement.length ? otherStatement : @""];
        NSLog(@"创建SQLITE语句为: %@", sqlString);
        return sqlString;
    }
    return nil;
}

#pragma mark - 使用已知参数 创建表

- (void)createTableWithName:(NSString *)tableName
                 columnKeys:(NSArray *)columnKeys
                    success:(void (^)(FMDatabase *db))success
                    failure:(void (^)(NSString *error))failure
{
    NSString *sql = [self createTableWithName:tableName columnKeys:columnKeys];
    if (!sql.length) {
        if (failure) {
            failure([NSString stringWithFormat:@"创建表“%@”失败: 参数错误", tableName]);
        }
    }else{
        [self executeUpdateInTransactionWithDBName:DatabaseName sqls:@[sql] success:success failure:failure];
    }
    
}


#pragma mark - 使用已知参数  (增删改)修改表
// 更新相应记录自增id对应的记录
- (void)insertOrUpdateTable:(NSString *)tableName
                     withRecordID:(NSInteger)recordID   // id自增列的值
                  valueDictionary:(NSDictionary *)valueDictionary
                    success:(void (^)(FMDatabase *db))success
                    failure:(void (^)(NSString *error))failure
{
    NSString *sql = [self insertOrUpdateTable:tableName withRecordID:recordID columnKeys:valueDictionary.allKeys columnValues:valueDictionary.allValues];
    if (!sql.length) {
        if (failure) {
            failure([NSString stringWithFormat:@"表“%@”插入更新数据失败: 参数错误", tableName]);
        }
    }else{
        [self executeUpdateInTransactionWithDBName:DatabaseName sqls:@[sql] success:success failure:failure];
    }
}

// 更新数据表满足相应条件的记录
- (void)updateTableWithName:(NSString *)tableName
                    valueDictionary:(NSDictionary *)valueDictionary
                    queryDictionary:(NSDictionary *)queryDictionary
                     otherStatement:(NSString *)otherStatement
                            success:(void (^)(FMDatabase *db))success
                            failure:(void (^)(NSString *error))failure
{
    NSString *sql = [self updateTableWithName:tableName valueDictionary:valueDictionary queryDictionary:queryDictionary otherStatement:otherStatement];
    if (!sql.length) {
        if (failure) {
            failure([NSString stringWithFormat:@"表“%@”更新数据失败: 参数错误", tableName]);
        }
    }else{
        [self executeUpdateInTransactionWithDBName:DatabaseName sqls:@[sql] success:success failure:failure];
    }
}

// 删除指定表指定条件的数据
- (void)deleteTableWithName:(NSString *)tableName
                  queryDictionary:(NSDictionary *)queryDictionary
                   otherStatement:(NSString *)otherStatement
                          success:(void (^)(FMDatabase *db))success
                          failure:(void (^)(NSString *error))failure
{
    NSString *sql = [self deleteTableWithName:tableName queryDictionary:queryDictionary otherStatement:otherStatement];
    if (!sql.length) {
        if (failure) {
            failure([NSString stringWithFormat:@"表“%@”删除数据失败: 参数错误", tableName]);
        }
    }else{
        [self executeUpdateInTransactionWithDBName:DatabaseName sqls:@[sql] success:success failure:failure];
    }
}

#pragma mark - 使用已知参数 查询表

// 查询指定表指定字段的值(默认均为NSString)
- (void)queryTable:(NSString *)tableName
     withSelectKey:(NSString *)selectKey
   queryDictionary:(NSDictionary *)queryDictionary
    otherStatement:(NSString *)otherStatement
           success:(void (^)(NSArray *results))success
           failure:(void (^)(NSString *error))failure
{
    NSString *sql = [self querySqlWithTable:tableName withSelectKey:selectKey queryKeys:queryDictionary.allKeys queryValues:queryDictionary.allValues otherStatement:otherStatement];
    if (!sql.length) {
        if (failure) {
            failure([NSString stringWithFormat:@"表“%@”查询数据失败: 参数错误", tableName]);
        }
    }else{
        [self executeQueryInTransactionWithDBName:DatabaseName sqls:@[sql] success:success failure:failure];
    }
}

@end
