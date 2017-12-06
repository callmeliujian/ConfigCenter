//
//  ConfigManager.m
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "ConfigManager.h"
#import <UIKit/UIKit.h>
#import "ConfigDelegate.h"
#import "ConfigAdaptor.h"
#import "ConfigDB.h"

typedef NS_ENUM(int, CONFIG_ACTION)
{
    ACTION_NOCHANGE = 0, //不更新
    ACTION_FULL, //全量更新
    ACTION_APPEND //增量更新
};

@interface ConfigManager () <NSURLSessionDelegate, NSURLSessionTaskDelegate, ConfigDBDelegate>
/**
 存储获得到的网络数据
 */
@property (nonatomic, strong) NSMutableData *allData;
/**
 数据适配器
 */

@property (nonatomic, strong) NSMutableArray *delegates;

@property (nonatomic, strong) NSDictionary *allConfig;

@property (nonatomic, strong) NSDictionary *versionConfig;
/**
 将配置中心解析数据所有需要的model类的名字存在此数组中
 */
@property (nonatomic, strong) NSMutableArray *classNameArray;
/**
 model类名对应的key
 */
@property (nonatomic, strong) NSArray *modelKeyNameArray;

@property (nonatomic, strong) NSArray *tableNameArray;

@end

@implementation ConfigManager

+ (instancetype)shareInstance {
    static  ConfigManager *manager;
    static dispatch_once_t DJCONFIGMANAGER;
    dispatch_once(&DJCONFIGMANAGER, ^{
        manager = [[ConfigManager alloc] init];
        [ConfigDB shareDB].delegate = manager;
    });
    return manager;
}

- (void)setupParams:(NSDictionary *)params {
    self.params = params;
    self.delegates = [[NSMutableArray alloc] init];
    [self creatAdaptor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConfigDataFromNetWork) name:UIApplicationWillEnterForegroundNotification object:nil];
    if (self.isGetModelData) {
        [self getConfigDataFromNetWork1];
    } else {
        [self getConfigDataFromNetWork];
    }
    
}

- (void)addDelegate:(id<ConfigDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<ConfigDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

- (void)getConfigDataFromNetWork {
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSString *stringURL = [NSString stringWithFormat:@"http://%@/api/getall?app=%@&platform=%@&appversion=%@&cityid=%@&version=%@&encryptid=%@&time=%@&encryptRes=%@",[self.params objectForKey:@"URL"], [self.params valueForKey:@"app"], [self.params valueForKey:@"platform"], [self.params valueForKey:@"appversion"], [self.params valueForKey:@"cityid"], [self.params valueForKey:@"version"], [self.params valueForKey:@"encryptid"], [self.params valueForKey:@"time"], [self.params valueForKey:@"res"]];
    NSString *test = @"http://mockhttp.cn/mock/suyun/123";
    NSLog(@"-------------ConfigCenter发送的请求地址为-----------------");
    NSLog(@"%@",stringURL);
    NSLog(@"-------------------------------------------------------");
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]]];
    
    [task resume];

}

- (void)getConfigDataFromNetWork1 {
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSString *stringURL = [NSString stringWithFormat:@"http://%@/api/getmoduledetail?app=%@&platform=%@&appversion=%@&cityid=%@&module=%@&version=%@&encryptid=%@&time=%@&encryptRes=%@",[self.params objectForKey:@"URL"], [self.params valueForKey:@"app"], [self.params valueForKey:@"platform"], [self.params valueForKey:@"appversion"], [self.params valueForKey:@"cityid"], [self.params valueForKey:@"modelName"], [self.params valueForKey:@"version"], [self.params valueForKey:@"encryptid"], [self.params valueForKey:@"time"], [self.params valueForKey:@"res"]];
    NSString *test = @"http://mockhttp.cn/mock/suyun/123";
    NSLog(@"-------------ConfigCenter发送的请求地址为-----------------");
    NSLog(@"%@",stringURL);
    NSLog(@"-------------------------------------------------------");
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]]];
    
    [task resume];
    
}

/**
 解析数据
 */
- (void)analyticalData {
    if (self.allData == nil) return;
    
    NSString *str = [[NSString alloc] initWithData:self.allData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",str);
    
    NSError *error = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:self.allData options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"配置中心解析数据出错“%@",error);
        return;
    }
    
    if ([[responseDic valueForKey:@"code"] integerValue] == 0) { //请求成功
        CONFIG_ACTION actionInt = [responseDic[@"data"][@"action"] intValue];
    
        if (actionInt == ACTION_NOCHANGE) { // 没有更新
            if ([self.delegate respondsToSelector:@selector(congfigNoChange)])
                [self.delegate congfigNoChange];
        } else if (actionInt == ACTION_APPEND) { //增量更新
            // 将数据缓存到数据库
            [self storageDataToDB:responseDic[@"data"]];
            if ([self.delegate respondsToSelector:@selector(partKeysChange)])
                [self.delegate partKeysChange];
        } else if (actionInt == ACTION_FULL) { //全量更新
            // 删除旧数据库、将数据缓存到新数据库
            [self deleteOldDB];
            [self storageDataToDB:responseDic[@"data"]];
            if ([self.delegate respondsToSelector:@selector(allKeysChange)])
                [self.delegate allKeysChange];
        }
    } else { //请求失败, 加载本地数据
        NSLog(@"配置中心网络请求失败:%@",[responseDic valueForKey:@"codeMsg"]);
        NSLog(@"%@",[NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"配置中心配置请求失败" message:[responseDic valueForKey:@"codeMsg"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
        });

        if ([self.delegate respondsToSelector:@selector(failureNetWork:)]) {
            [self.delegate failureNetWork:responseDic];
        }
    }
    self.allData = nil;
}

/**
 将配置中心数据反序列化到内存
 */
- (void)deserializeToMemory:(NSDictionary *)dic {
    [self.adaptor updateData:dic[@"data"]];
}

/**
 增量更新时候使用
 数据存储到数据库
 
 */
- (void)storageDataToDB:(NSDictionary *)dic {
    [[ConfigDB shareDB] hanldDataToDB:dic];
}

/**
 全量更新时候使用
 所有数据存储到数据库
 
 */
- (void)storageAllDataToDB:(NSDictionary *)dic {
    [[ConfigDB shareDB] updateDataToDB:dic];
}

/**
 将元数据写入数据库
 元数据：城市ID、配置中心版本号等
 */
- (void)writeMetadataToDB:(NSDictionary *)dict {
    // 1.将元数据从字典中取出来，并组成一个新的元数据字典
    NSDictionary *tmpDict = [dict valueForKey:@"data"];
    NSMutableDictionary *metaDataMutableDict = [NSMutableDictionary dictionary];
    for (NSString *key in tmpDict.allKeys) {
        if (![key isEqualToString:@"modules"] && ![key isEqualToString:@"action"]) {
            [metaDataMutableDict setObject:[tmpDict objectForKey:key] forKey:key];
        }
    }
    // 2.将元数据字典写入数据库
    [[ConfigDB shareDB] metaDataToDB:metaDataMutableDict];
}

/**
 删除老版本数据库
 */
- (void)deleteOldDB {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sourcePath = [NSString stringWithFormat:@"%@/test.db", path];
    if ([[NSFileManager defaultManager]  fileExistsAtPath:sourcePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
        return;
    }
    //[[ConfigDB shareDB] deleteTable:nil];
}

- (void)cityChanged:(NSString *)cityid {
    [self deleteOldDB];
}

-(void)registerWithKey:(NSString *)key modelClassName:(NSString *)className {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:key forKey:@"key"];
    [dic setValue:className forKey:@"className"];
    [self.classNameArray addObject:dic];
}

- (void)registerClassName
{
    for (NSDictionary *dic in self.classNameArray) {
        [_adaptor registerModelWithKey:dic[@"key"] modelClassName:dic[@"className"]];
    }
}

- (NSArray *)getAllConfigCenterTableName {
    //if (!_tableNameArray) {
        _tableNameArray = [[ConfigDB shareDB] recriveAllTbaleName];;
    //}
    return _tableNameArray;
}

- (NSArray *)getAllDataWithTableName:(NSString *)tabelName {
    NSArray *dataArr = nil;
    dataArr = [[ConfigDB shareDB] selectAllDataFromDBWithTableName:tabelName];
    return dataArr;
}

- (NSString *)getConfigVersion {
    return [[ConfigDB shareDB] selectDataFromDB:@"currentVersion" withTableName:@"config_metadata"];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        [self analyticalData];
    } else {
        self.allData = nil;
        //[[ConfigDB shareDB] hanldDataToDB:[NSDictionary dictionary] withModelKeyName:self.params[@"modelkeyname"]];
        NSLog(@"配置中心网络访问失败：%@",error);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.allData appendData:data];
}


#pragma mark - ConfigDBDelegate

- (void) dataFromDBToMemory:(NSDictionary *)dic {
    [self deserializeToMemory:dic];
}

#pragma mark - Lazy

- (NSMutableData *)allData {
    if (!_allData) {
        _allData = [[NSMutableData alloc] init];
    }
    return _allData;
}

- (ConfigAdaptor *)adaptor {
    if (!_adaptor) {
        [self creatAdaptor];
    }
    return _adaptor;
}

- (void)creatAdaptor {
    _adaptor = [[ConfigAdaptor alloc] init];
    [self registerClassName];
}

- (NSMutableArray *)classNameArray {
    if (!_classNameArray) {
        _classNameArray = [NSMutableArray array];
    }
    return _classNameArray;
}

@end

