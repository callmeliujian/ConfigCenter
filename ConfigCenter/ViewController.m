//
//  ViewController.m
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "ViewController.h"
#import "LJConfigManager.h"
#import "AFNetworking.h"

//#import "ConfigDB.h"
#import "FMDatabase.h"

@interface ViewController ()

@property (nonatomic, strong) FMDatabase *configDB;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:@"http://www.baidu.com" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    [[LJConfigManager shareInstance] createManager];
    
//    NSArray *array = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", nil];
//
//    [self createTable:@"wwww"];
//
//    [self arrayToDB:array withTableName:@"wwww"];
    
}

- (BOOL)createTable:(NSString *)tableName {
    if (tableName == nil || [tableName isEqualToString:@""]) return NO;
    NSString *sql = [NSString stringWithFormat:@"create table IF NOT EXISTS %@ (id integer primary key autoincrement, key text, value text);", tableName];
    [[self class] openDB];
    BOOL success = [self.configDB executeStatements:sql];
    [[self class] closeDB];
    return success;
}

- (void)arrayToDB:(NSArray *)array withTableName:(NSString *)tableName {
    if (array == nil || ![array isKindOfClass:[NSArray class]]) return;
    [[self class] openDB];
    for (NSString *key in array) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where key = '%@'",tableName,key];
        FMResultSet *result = [self.configDB executeQuery:sql];
        if ([result next]) {
            NSString *updataSql = [NSString stringWithFormat:@"UPDATE %@ SET key='%@' WHERE key = '%@'",tableName,key,key];
            BOOL success = [self.configDB executeUpdate:updataSql];
            if (!success) NSLog(@"配置中心修改数据失败");
        } else {
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (key) VALUES (?)",tableName];
            BOOL success = [self.configDB executeUpdate:insertSql, key];
            if (!success) NSLog(@"配置中心插入数据失败");
        }
    }
    [[self class] closeDB];
}

- (BOOL)openDB {
    return [self.configDB open];
}

- (BOOL)closeDB {
    return [self.configDB close];
}

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
