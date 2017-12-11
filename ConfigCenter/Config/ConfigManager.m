//
//  ConfigManager.m
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "ConfigManager.h"
#import <UIKit/UIKit.h>
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
 是否重新获取过数据
 */
@property (nonatomic, assign) BOOL retrieveData;
/**
 是否根据model获取数据
 */
@property (nonatomic, assign) BOOL isGetDataFromModel;

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
/**
 是否正在进行请求
 */
@property (nonatomic, assign) BOOL isRequesting;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConfigDataFromNetWork) name:UIApplicationWillEnterForegroundNotification object:nil];
    if (!self.isRequesting) { // 如果当前有正在进行的请求则放弃当前的请求
        if (self.isGetModelData) {
            [self getConfigDataFromNetWork1];
        } else {
            [self getConfigDataFromNetWork];
        }
    }
}

- (void)getConfigDataFromNetWork {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSString *stringURL = [NSString stringWithFormat:@"http://%@/api/getall?app=%@&platform=%@&appversion=%@&cityid=%@&version=%@&encryptid=%@&time=%@&encryptRes=%@",[self.params objectForKey:@"URL"], [self.params valueForKey:@"app"], [self.params valueForKey:@"platform"], [self.params valueForKey:@"appversion"], [self.params valueForKey:@"cityid"], [self.params valueForKey:@"version"], [self.params valueForKey:@"encryptid"], [self.params valueForKey:@"time"], [self.params valueForKey:@"res"]];
    NSLog(@"-------------ConfigCenter发送的请求地址为-----------------");
    NSLog(@"%@",stringURL);
    NSLog(@"-------------------------------------------------------");
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]]];
    self.isRequesting = YES;
    [task resume];
}

- (void)getConfigDataFromNetWork1 {
    self.isGetDataFromModel = YES;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSString *stringURL = [NSString stringWithFormat:@"http://%@/api/getmoduledetail?app=%@&platform=%@&appversion=%@&cityid=%@&module=%@&version=%@&encryptid=%@&time=%@&encryptRes=%@",[self.params objectForKey:@"URL"], [self.params valueForKey:@"app"], [self.params valueForKey:@"platform"], [self.params valueForKey:@"appversion"], [self.params valueForKey:@"cityid"], [self.params valueForKey:@"modelName"], [self.params valueForKey:@"version"], [self.params valueForKey:@"encryptid"], [self.params valueForKey:@"time"], [self.params valueForKey:@"res"]];
    NSLog(@"-------------ConfigCenter发送的请求地址为-----------------");
    NSLog(@"%@",stringURL);
    NSLog(@"-------------------------------------------------------");
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]]];
    self.isRequesting = YES;
    [task resume];
    
}

/**
 解析数据
 */
- (void)analyticalDataWithtask:(NSURLSessionTask *)task {
    if (self.allData == nil) return;
    NSString *str = [[NSString alloc] initWithData:self.allData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    NSError *error = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:self.allData options:NSJSONReadingMutableLeaves error:&error];
    self.allData = nil;
    if (error) {
        NSLog(@"配置中心解析数据出错“%@",error);
        return;
    }
    if ([[responseDic valueForKey:@"code"] integerValue] == 0) { //请求成功
        CONFIG_ACTION actionInt = [responseDic[@"data"][@"action"] intValue];
        if (![self checkCityID:responseDic[@"data"]]) {
            [task resume];
            self.isRequesting = NO;
            return;
        }
        if (self.isGetDataFromModel) {
            if (![self checkModelName:responseDic[@"data"]]) {
                [task resume];
                self.isRequesting = NO;
                return;
            }
            //self.isGetDataFromModel = NO;
        }
        if (actionInt == ACTION_NOCHANGE) { // 没有更新
            if ([self.delegate respondsToSelector:@selector(congfigNoChange)])
                [self.delegate congfigNoChange];
            self.isGetDataFromModel = NO;
        } else if (actionInt == ACTION_APPEND) { //增量更新
            // 将数据缓存到数据库
            [self storageDataToDB:responseDic[@"data"]];
            if ([self.delegate respondsToSelector:@selector(partKeysChange)])
                [self.delegate partKeysChange];
            self.isGetDataFromModel = NO;
        } else if (actionInt == ACTION_FULL) { //全量更新
            // 删除旧数据库、将数据缓存到新数据库
            if (!self.isGetDataFromModel) {
                [self deleteOldDB];
            }
            self.isGetDataFromModel = NO;
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
    self.isRequesting = NO;
}

/**校验cityid是否正确 */
- (BOOL)checkCityID:(NSDictionary *)dic {
    NSString *cityID = [dic objectForKey:@"cityId"];
    BOOL isCityCorrect = false;
    if ([cityID isEqualToString:self.params[@"cityid"]]) {
        isCityCorrect = true;
    }
    return isCityCorrect;
}

- (BOOL)checkModelName:(NSDictionary *)dic {
    NSArray *modeulesArray = [dic objectForKey:@"modules"];
    NSDictionary *moduleDic = [modeulesArray firstObject];
    NSString *modelName = [moduleDic objectForKey:@"moduleName"];
    BOOL isModuleNameCorrect = false;
    if ([modelName isEqualToString:self.params[@"modelName"]]) {
        isModuleNameCorrect = true;
    }
    return isModuleNameCorrect;
}

/**
 增量更新时候使用
 数据存储到数据库
 
 */
- (void)storageDataToDB:(NSDictionary *)dic {
    [[ConfigDB shareDB] hanldDataToDB:dic];
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
}

- (void)cityChanged:(NSString *)cityid {
    [self deleteOldDB];
}

- (NSArray *)getAllConfigCenterTableName {
    _tableNameArray = [[ConfigDB shareDB] recriveAllTbaleName];;
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
        [self analyticalDataWithtask:task];
    } else {
        self.allData = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络请求失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        });
        NSLog(@"配置中心网络访问失败：%@",error);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.allData appendData:data];
}


#pragma mark - ConfigDBDelegate

- (void) getFailureData:(NSDictionary *)dic {
    if (!self.retrieveData) {
        NSString *cityId = [dic objectForKey:@"cityId"];
        NSString *currentVersion = [dic objectForKey:@"currentVersion"];
        NSArray *moduleNameArray = [dic objectForKey:@"failureModelName"];
        [self.params setValue:cityId forKey:@"cityid"];
        [self.params setValue:currentVersion forKey:@"version"];
        for (NSString *moduleName in moduleNameArray) {
            [self.params setValue:moduleName forKey:@"modelName"];
            [self getConfigDataFromNetWork1];
        }
    }
    self.retrieveData = YES;
}

#pragma mark - Lazy

- (NSMutableData *)allData {
    if (!_allData) {
        _allData = [[NSMutableData alloc] init];
    }
    return _allData;
}

- (NSMutableArray *)classNameArray {
    if (!_classNameArray) {
        _classNameArray = [NSMutableArray array];
    }
    return _classNameArray;
}

@end

