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
#import "FMDatabaseQueue.h"
#import "ConfigManager.h"
#import "NSString+Utils.h"

@interface ConfigDB ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

/**
 该字典分为3种key-value
 1.key：cityid 存放获取数据失败的城市ID。
 2.key：version 配置的版本号。
 3.key：failureModelName，对应的value为failureModelName。
 */
@property (nonatomic, strong) NSMutableDictionary *failureMutableDic;
/**
 如果某个model下的key、status、value有一个为nil或者为@""，则将model的modelName放入此数组
 最后通过按model获取数据的接口再次请求数据，只请求一次。
 */
@property (nonatomic, strong) NSMutableArray *failureModelName;
/**
 当前的数据moduleData是否有无效的数据
 */
@property (nonatomic, assign) BOOL isFailureModel;
/**
 返回的数据moduleData中是否存在无效数据
 */
@property (nonatomic, assign) BOOL isExistFailUreModel;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.failureMutableDic = [NSMutableDictionary dictionary];
        self.failureModelName = [NSMutableArray array];
    }
    return self;
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
    
    // 4.失败数据处理
    if (self.isExistFailUreModel) {
        if ([self.delegate respondsToSelector:@selector(getFailureData:)]) {
            [self.delegate getFailureData:[self.failureMutableDic mutableCopy]];
            [self.failureMutableDic removeAllObjects];
            [self.failureModelName removeAllObjects];
            self.isExistFailUreModel = NO;
        }
    }
}

/**
 处理Modules数组
 */
- (void)hanldModules:(NSArray *)modulesArray {
    if (![modulesArray isKindOfClass:[NSArray class]]) return;
    for (NSDictionary *moduleDic in modulesArray) {
        NSString *moduleName;
        NSString *config_modelName;
        for (NSString *key in moduleDic) {
            id object = [moduleDic valueForKey:key];
            if ([object isKindOfClass:[NSString class]]) { // moduleName 加上前缀config_即为表名
                moduleName = object;
                config_modelName = [@"config_" stringByAppendingString:object];
            } else if ([object isKindOfClass:[NSArray class]]) { // 处理moduleData
                //[self handleModuleData:object withModuleName:moduleName];
                // 1.创建表
                [self createTable:config_modelName];
                // 2.写入数据
                for (NSDictionary *dic in object) {
                    [self handleDataToDB:dic withTableName:config_modelName];
                }
                // 3.是否有写入失败的数据
                if (self.isFailureModel) {
                    [self.failureModelName addObject:moduleName];
                    self.isFailureModel = NO;
                }
            }
        }
    }
    if (self.isExistFailUreModel) {
        NSString *cityId = [self selectDataFromTableName:@"config_metadata" WithKey:@"cityId"];
        if ([NSString isEmptyString:cityId]) {
            cityId = [[ConfigManager shareInstance].params objectForKey:@"cityid"];
        }
        NSString *currentVersion = [self selectDataFromTableName:@"config_metadata" WithKey:@"currentVersion"];
        if ([NSString isEmptyString:currentVersion]) {
            currentVersion = [[ConfigManager shareInstance].params objectForKey:@"version"];
        }
        [self.failureMutableDic setObject:cityId forKey:@"cityId"];
        [self.failureMutableDic setObject:currentVersion forKey:@"currentVersion"];
        [self.failureMutableDic setObject:self.failureModelName forKey:@"failureModelName"];
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
    
    if ([NSString isEmptyString:key] || status == nil || [NSString isEmptyString:value]) {
        self.isFailureModel = YES;
        self.isExistFailUreModel = YES;
        return;
    }
    
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

#pragma mark - 数据库相关操作

/**
 创建表

 @param tableName 表名
 @return 返回是否创建成功
 */
- (BOOL)createTable:(NSString *)tableName {
    if (tableName == nil || [tableName isEqualToString:@""]) return NO;
    NSString *sql = [NSString stringWithFormat:@"create table IF NOT EXISTS %@ (id integer primary key autoincrement, key text, value text);", tableName];
     __block BOOL success;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        success = [db executeStatements:sql];
    }];
    return success;
}

- (void)insertDataToDBWithKey:(NSString *)key withValue:(NSString *)value withTableName:(NSString *)tableName {
    if (![key isKindOfClass:[NSString class]] || ![value isKindOfClass:[NSString class]] || ![tableName isKindOfClass:[NSString class]]
        || [key isEqualToString:@""] || [value isEqualToString:@""] || [tableName isEqualToString:@""]) return;
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where key = '%@'",tableName,key];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:sql];
        if ([result next]) {
            NSString *updataSql = [NSString stringWithFormat:@"UPDATE %@ SET value='%@' WHERE key = '%@'",tableName,value,key];
            BOOL success = [db executeUpdate:updataSql];
            if (!success) NSLog(@"配置中心修改数据失败");
        } else {
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (key, value) VALUES (?, ?)",tableName];
            BOOL success = [db executeUpdate:insertSql, key, value];
            if (!success) NSLog(@"配置中心插入数据失败");
        }
    }];
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
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL success = [db executeUpdate:sql];
            if (!success) NSLog(@"配置中心删除数据失败");
        }];
        
    }
    return;
}

- (NSString *)selectDataFromTableName:(NSString *)tableName WithKey:(NSString *)key {
    // 1.参数校验
    if ([NSString isEmptyString:key] || [NSString isEmptyString:tableName] || ![key isKindOfClass:[NSString class]] || ![tableName isKindOfClass:[NSString class]]) {
        return nil;
    }
    // 2.获取数据库中的所有表，并查找传入的tableName是否存在，如果存在则进行查找，不存在返回nil
    NSArray *tableNameArray = [self getAllTbaleName];
    for (NSString *tableNameStr in tableNameArray) {
        if ([tableName isEqualToString:tableNameStr]) {
            NSString *sql = [NSString stringWithFormat:@"select * from %@ where key = '%@'",tableName,key];
            __block NSString *value = nil;
            [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
                FMResultSet *result = [db executeQuery:sql];
                while ([result next]) {
                    value = [result stringForColumn:@"value"];
                }
            }];
            return value;
        }
    }
    return nil;
}

- (NSArray *)selectAllDataFromDBWithTableName:(NSString *)tableName {
    if ([NSString isEmptyString:tableName] || ![tableName isKindOfClass:[NSString class]]) return nil;
    __block NSMutableArray *mutableArr = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[result stringForColumn:@"value"], [result stringForColumn:@"key"], nil];
            [mutableArr addObject:dic];
        }
    }];
    return mutableArr;
}

- (NSArray *)getAllTbaleName {
    NSString *sql = @"SELECT * FROM sqlite_master where type='table';";
    __block NSMutableArray *tableNameArray = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            NSString *tableName = [result stringForColumnIndex:1];
            [tableNameArray addObject:tableName];
        }
    }];
    return tableNameArray;
}

#pragma mark - Lazy

- (FMDatabaseQueue *)dbQueue {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"test"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _dbQueue = nil;
    }
    if (!_dbQueue) {
        NSString *filePath = [[NSBundle mainBundle] resourcePath];
        NSString *doc_path = [filePath stringByAppendingPathComponent:@"test"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] copyItemAtPath:doc_path toPath:path error:nil];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return _dbQueue;
}

@end
