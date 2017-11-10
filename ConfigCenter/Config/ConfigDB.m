//
//  ConfigDB.m
//  ConfigCenter
//
//  Created by 刘健 on 09/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "ConfigDB.h"
#import "FMDatabase.h"

@interface ConfigDB ()

@property (nonatomic, strong) FMDatabase *configDB;

@end

@implementation ConfigDB

+ (instancetype)shareDB {
    static ConfigDB *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ConfigDB alloc] init];
    });
    return instance;
}

- (BOOL)openDB {
    return [self.configDB open];
}

- (BOOL)closeDB {
    return [self.configDB close];
}

- (void)hanldDataToDB:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) return;
    [[ConfigDB shareDB] openDB];
    for (NSString *key in dic) {
        if ([dic[key] isKindOfClass:[NSArray class]]) {
                for (NSDictionary *valueDict in dic[key]) {
                    NSNumber *status = [valueDict objectForKey:@"status"];
                    if ([status intValue] == 1) { // status == 1 为增加或修改数据
                        [self insertDataToDB:valueDict withTableName:key];
                    } else if ([status intValue] == -1) { // status == -1 删除数据
                        [self deletDataFromDB:valueDict withTableName:key];
                    }
                }
        }
    }
    [[ConfigDB shareDB] closeDB];
}

- (void)updateDataToDB:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) return;
    [[ConfigDB shareDB] openDB];
//    NSString *currentVersion = [dic[@"currentVersion"] stringValue];
//    NSString *cityID = [dic[@"cityId"] stringValue];
    for (NSString *key in dic) {
        if ([dic[key] isKindOfClass:[NSArray class]]) {
            if ([self createTable:key]) {
                for (NSDictionary *valueDict in dic[key]) {
                    [self insertDataToDB:valueDict withTableName:key];
                }
            } else {
                NSLog(@"配置中心创建表失败");
                [[ConfigDB shareDB] closeDB];
                return;
            }
        }
    }
    [[ConfigDB shareDB] closeDB];
}

#pragma mark - 数据库相关操作

- (BOOL)createTable:(NSString *)tableName {
    if (tableName == nil || [tableName isEqualToString:@""]) return NO;
    NSString *sql = [NSString stringWithFormat:@"create table IF NOT EXISTS %@ (id integer primary key autoincrement, key text, value text);", tableName];
    BOOL success = [self.configDB executeStatements:sql];
    return success;
}


/**
 把配置中心的版本号、城市ID单独放在此表中

 @return 创建表是否成功
 */
- (BOOL)createTable {
    NSString *sql = @"create table IF NOT EXISTS config_other (id integer primary key autoincrement, currentVersion text, cityId text);";
    BOOL success = [self.configDB executeStatements:sql];
    return success;
}

/**
 {
 "key": "dsad",
 "status": 1,
 "value": "dsadnn333"
 },
 
 */
- (void)insertDataToDB:(NSDictionary *)dic withTableName:(NSString *)tableName {
    if (![dic isKindOfClass:[NSDictionary class]] || tableName == nil || [tableName isEqualToString:@""]) return;
    
    NSString *key = [dic objectForKey:@"key"];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *value = [dic objectForKey:@"value"];
    
    if (key == nil || status == nil || value == nil) return;
    // status = 1 代表增加或修改
    if ([status intValue] == 1) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where key = '%@'",tableName,key];
        FMResultSet *result = [self.configDB executeQuery:sql];
        if ([result next]) {
            NSString *updataSql = [NSString stringWithFormat:@"UPDATE %@ SET value='%@' WHERE key = '%@'",tableName,value,key];
            BOOL success = [self.configDB executeUpdate:updataSql];
            if (!success) NSLog(@"配置中心修改数据失败");
        } else {
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (key, value) VALUES (?, ?)",tableName];
            BOOL success = [self.configDB executeUpdate:insertSql, key, value];
            if (!success) NSLog(@"配置中心插入数据失败");
        }
    }
    return;
}

/**
 从数据库中删除数据

 */
- (void)deletDataFromDB:(NSDictionary *)dic withTableName:(NSString *)tableName {
    if (![dic isKindOfClass:[NSDictionary class]] || tableName == nil || [tableName isEqualToString:@""]) return;
    
    NSString *key = [dic objectForKey:@"key"];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *value = [dic objectForKey:@"value"];
    
    if (key == nil || status == nil || value == nil) return;
    // status = -1 删除
    if ([status intValue] == -1) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where key = '%@'", tableName, key];
        BOOL success = [self.configDB executeUpdate:sql];
        if (!success) NSLog(@"配置中心删除数据失败");
    }
    return;
}

- (NSString *)selectDataFromDB:(NSString *)key withTableName:(NSString *)tableName {
    if (![key isKindOfClass:[NSString class]] || tableName == nil || [tableName isEqualToString:@""] || [key  isEqual: @""]) return @"";
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where key = '%@'",tableName,key];
    FMResultSet *result = [self.configDB executeQuery:sql];
    while ([result next]) {
        return [result stringForColumn:@"value"];
    }
    return @"";
}

#pragma mark - Lazy

- (FMDatabase *)configDB {
    if (!_configDB) {
//        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
//        NSString *filePath = [path stringByAppendingPathComponent:@"tmp.db"];
//        _configDB = [FMDatabase databaseWithPath:filePath];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
        NSString *filePath = [path stringByAppendingPathComponent:@"tmp.db"];
        _configDB = [FMDatabase databaseWithPath:filePath];
        
    }
    return _configDB;
}


@end
