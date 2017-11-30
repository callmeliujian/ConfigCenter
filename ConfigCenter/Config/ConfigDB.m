//
//  ConfigDB.m
//  ConfigCenter
//
//  Created by 刘健 on 09/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//
// metadataDic 除了moudles里的数据都是metadata数据

#import "ConfigDB.h"
#import "FMDatabase.h"

@interface ConfigDB ()

@property (nonatomic, strong) FMDatabase *configDB;

/**
 存放model的key
 */
//@property (nonatomic, strong) NSMutableArray *modelKeyNameArray;

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
    // 1.将metadata放入metadataDic中
    NSMutableDictionary *metadataDic = [NSMutableDictionary dictionary];
    NSString *action = [[dic objectForKey:@"action"] stringValue];
    [metadataDic setObject:action forKey:@"action"];
    NSString *currentVersion = [[dic objectForKey:@"currentVersion"] stringValue];
    [metadataDic setObject:currentVersion forKey:@"currentVersion"];
    NSString *ciytId = [dic objectForKey:@"cityId"];
    [metadataDic setObject:ciytId forKey:@"ciytId"];
    // 2.处理modules的数据
    [self hanldModules:[dic objectForKey:@"modules"]];
    
    // 3.创建config_metadata表 将metadataDic存入config_metadata表
    [self createTable:@"config_metadata"];
    [self insertMetadata:metadataDic withTableName:@"config_metadata"];
}

/**
 处理Modules数组
 */
- (void)hanldModules:(NSArray *)modulesArray {
    if (![modulesArray isKindOfClass:[NSArray class]]) return;
    for (NSDictionary *moduleDic in modulesArray) {
        NSString *moduleName;
        for (NSString *key in moduleDic) {
            id object = [moduleDic valueForKey:key];
            if ([object isKindOfClass:[NSString class]]) { // moduleName 加上前缀config_即为表名
                moduleName = [@"config_" stringByAppendingString:object];
            } else if ([object isKindOfClass:[NSArray class]]) { // 处理moduleData
                //[self handleModuleData:object withModuleName:moduleName];
                // 1.创建表
                [self createTable:moduleName];
                // 2.写入数据
                for (NSDictionary *dic in object) {
                    [self handleDataToDB:dic withTableName:moduleName];
                }
                
            }
        }
    }
}

/**
 解析数据是增加或修改或删除
 
 @param dic 待处理字典
 @param tableName 表名
 */
- (void)handleDataToDB:(NSDictionary *)dic withTableName:(NSString *)tableName {
    if (![dic isKindOfClass:[NSDictionary class]] || tableName == nil || [tableName isEqualToString:@""]) return;
    
    NSString *key = [dic objectForKey:@"key"];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *value = [dic objectForKey:@"value"];
    
    if (key == nil || status == nil || value == nil) return;
    
    if ([status intValue] == 1) { // status = 1 代表增加或修改
        [self insertDataToDBWithKey:key withValue:value withTableName:tableName];
    } else if ([status intValue] == -1) { // status = -1 删除
        [self deletDataFromDB:dic withTableName:tableName];
    }
}

/**
 将Metadata插入数据库
 
 @param dic Metadata
 @param tableName 表名
 */
- (void)insertMetadata:(NSDictionary *)dic withTableName:(NSString *)tableName  {
    if (![dic isKindOfClass:[NSDictionary class]] || tableName == nil || [tableName isEqualToString:@""]) return;
    
    for (NSString *key in dic) {
        id object = [dic valueForKey:key];
        if (![object isKindOfClass:[NSString class]]) {
            object = [object stringValue];
        }
        if (key == nil || object == nil || [key isEqualToString:@""] || [object isEqualToString:@""]) break;
        [self insertDataToDBWithKey:key withValue:object withTableName:tableName];
    }
}

- (void)deleteTable:(NSString *)tableName {
    [[ConfigDB shareDB] openDB];
    if (tableName == nil) {
        
    } else {
        
    }
    [[ConfigDB shareDB] closeDB];
}

#pragma mark - 数据库相关操作

/**
 创建表

 @param tableName 表名
 @return 返回是否创建成功
 */
- (BOOL)createTable:(NSString *)tableName {
    if (tableName == nil || [tableName isEqualToString:@""]) return NO;
    NSString *sql = [NSString stringWithFormat:@"create table IF NOT EXISTS %@ (id integer primary key autoincrement, key text, value text);", tableName];
    [[ConfigDB shareDB] openDB];
    BOOL success = [self.configDB executeStatements:sql];
    [[ConfigDB shareDB] closeDB];
    return success;
}

- (void)insertDataToDBWithKey:(NSString *)key withValue:(NSString *)value withTableName:(NSString *)tableName {
    if (![key isKindOfClass:[NSString class]] || ![value isKindOfClass:[NSString class]] || ![tableName isKindOfClass:[NSString class]]
        || [key isEqualToString:@""] || [value isEqualToString:@""] || [tableName isEqualToString:@""]) return;
    
    [[ConfigDB shareDB] openDB];
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
    [[ConfigDB shareDB] closeDB];
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

/**
 把数据库的数据转化为数组字典
 
 @param modelNameArray 模块名即表名
 @return 数组字典
 */
- (NSDictionary *)dataFromDBToDic:(NSArray *)modelNameArray {
    if (modelNameArray == nil || modelNameArray.count == 0) return nil;
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    for (NSString *key in modelNameArray) {
        NSArray *array = [self dataFromDBToArray:key];
        if (!array) break;
        [mutableDic setObject:array forKey:key];
    }
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:mutableDic, @"data", nil];
    return dic;
}

/**
 将表里的元素装换为数组
 
 @param modelName 表名
 @return 表数组
 */
- (NSArray *)dataFromDBToArray:(NSString *)modelName {
    if (modelName == nil || [modelName isEqualToString:@""]) return nil;
    [self.configDB open];
    NSString *sql = [NSString stringWithFormat:@"select * from %@",modelName];
    FMResultSet *result = [self.configDB executeQuery:sql];
    NSMutableArray *mutableArray = [NSMutableArray array];
    while ([result next]) {
        NSString *key = [result stringForColumn:@"key"];
        NSString *value = [result stringForColumn:@"value"];
        if (key != nil && value != nil && ![key isEqualToString:@""] && ![value isEqualToString:@""] ) {
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:value, key, nil];
            [mutableArray addObject:dic];
        }
    }
    [self.configDB close];
    return mutableArray;
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
