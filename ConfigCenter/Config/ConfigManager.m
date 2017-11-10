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

@interface ConfigManager () <NSURLSessionDelegate, NSURLSessionTaskDelegate>
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



@end

@implementation ConfigManager

+ (instancetype)shareInstance {
    static  ConfigManager *manager;
    static dispatch_once_t DJCONFIGMANAGER;
    dispatch_once(&DJCONFIGMANAGER, ^{
        manager = [[ConfigManager alloc] init];
    });
    return manager;
}

- (void)setupParams:(NSDictionary *)params {
    self.params = [[NSDictionary alloc] initWithDictionary:params];
    self.delegates = [[NSMutableArray alloc] init];
    [self creatAdaptor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConfigDataFromNetWork) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self getConfigDataFromNetWork];
}

- (void)addDelegate:(id<ConfigDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<ConfigDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

- (void)getConfigDataFromNetWork {
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mockhttp.cn/mock/suyun/123"]]];
    
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
    
    if ([[responseDic valueForKey:@"code"] integerValue] == 0) {
        //请求成功
        CONFIG_ACTION actionInt = [responseDic[@"data"][@"action"] intValue];
        NSString *cityID = [responseDic[@"data"][@"cityId"] stringValue];
        NSString *currentVersion = [responseDic[@"data"][@"currentVersion"] stringValue];
        
        if (actionInt == ACTION_NOCHANGE) { // 没有更新
            // 将配置中心数据反序列化到内存
            [self deserializeToMemory:responseDic];
        } else if (actionInt == ACTION_APPEND) { //增量更新
            // 操作数据库并将配置中心数据反序列化到内存
            [self storageDataToDB:responseDic[@"data"]];
        } else if (actionInt == ACTION_FULL) { //全量更新
            // 操作数据库并将配置中心数据反序列化到内存
            [self deserializeToMemory:responseDic];
            [self storageAllDataToDB:responseDic[@"data"]];
        }
    } else {
        //请求失败
        NSLog(@"配置中心网络请求失败“%@",[[responseDic valueForKey:@"codeMsg"] stringValue]);
    }
    
}

/**
 将配置中心数据反序列化到内存
 */
- (void)deserializeToMemory:(NSDictionary *)dic {
    //[self.adaptor updateVersion:data];
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

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        [self analyticalData];
    } else {
        self.allData = nil;
        NSLog(@"配置中心网络访问失败：%@",error);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.allData appendData:data];
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

////反序列化数据
//- (void)deserialize:(NSDictionary *)data
//{
//    [self.adaptor updateVersion:data];
//    [self.adaptor updateData:data[@"incrConfig"] withCityid:data[@"cityid"]];
//    [self.adaptor updateUserGroup:[NSString stringWithFormat:@"%@", data[@"userGroup"]]];
//}
//
////更新数据存储到DB中
//- (void)updataConfigStoreDB:(NSDictionary *)data
//{
//    [[DJConfigDB shareDB] updateVersionConfig:data];
//    
//    [[DJConfigDB shareDB] updateDataConfig:data];
//}
//
//- (void)getVersionConfigFromDB:(NSString *)cityid
//{
//    self.versionConfig = [[DJConfigDB shareDB] getVersionNumberListData:cityid];
//}
//
//- (NSString *)getUserGroupFromAdaptor
//{
//    return self.adaptor.userGroup;
//}
//
//- (void)setAdaptorVersion:(NSString *)version
//{
//    self.adaptor.version = version;
//}
//
//- (void)noticeFullUpdate:(NSDictionary *)dic
//{
//    for (id<DJConfigDelegate> delegate in self.delegates) {
//        if ([delegate respondsToSelector:@selector(allKeysChange:)]) {
//            [delegate allKeysChange:dic];
//        }
//    }
//}
//
//- (void)noticePartUpdate:(NSDictionary *)dic
//{
//    for (id<DJConfigDelegate> delegate in self.delegates) {
//        if ([delegate respondsToSelector:@selector(partKeysChange:)]) {
//            [delegate partKeysChange:dic];
//        }
//    }
//}
//
//- (void)noticeCityIdChange
//{
//    for (id<DJConfigDelegate> delegate in self.delegates) {
//        if ([delegate respondsToSelector:@selector(cityIdChange)]) {
//            [delegate cityIdChange];
//        }
//    }
//}
//
//- (void)noticeConfigDataChange
//{
//    for (id<DJConfigDelegate> delegate in self.delegates) {
//        if ([delegate respondsToSelector:@selector(configDataChange)]) {
//            [delegate configDataChange];
//        }
//    }
//}
//
//- (void)noticeConfigNoChange
//{
//    for (id<DJConfigDelegate> delegate in self.delegates) {
//        if ([delegate respondsToSelector:@selector(congfigNoChange)]) {
//            [delegate congfigNoChange];
//        }
//    }
//}
//
//- (NSDictionary *)deserializeVersion:(NSString *)cityid withVersion:(NSString *)version withUserGroup:(NSString *)userGroup
//{
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setValue:cityid forKey:@"cityid"];
//    [dic setValue:version forKey:@"version"];
//    [dic setValue:userGroup forKey:@"userGroup"];
//    return dic;
//}
//
////主动更新
//- (NSDictionary *)getAllConfig
//{
//    return self.allConfig;
//}
//
////获取版本号，userGroup
//- (NSDictionary *)getVersionConfig
//{
//    return self.versionConfig;
//}
//

//
//- (NSMutableArray *)ClassNameArr
//{
//    if (_ClassNameArr == nil) {
//        _ClassNameArr = [[NSMutableArray alloc] init];
//    }
//    return _ClassNameArr;
//}
//
//- (id)getDataWithKey:(NSString *)key
//{
//    return [self.adaptor getDataWithKey:key];
//}
//
//- (id)getArrayDataWithKey:(NSString *)key
//{
//    return [self.adaptor getArrayDataWithKey:key];
//}
//
//- (void)cityChanged:(NSString *)cityid
//{
//    if ([cityid isEqualToString:self.cityid])
//        return;
//    
//    self.cityid = cityid;
//    [self createAdaptor];
//    
//    [self noticeCityIdChange];
//    
//    // 从网络加载最新配置数据
//    [self getConfigDataFromNetWork];
//}
//
//- (DJConfigAdaptor *)adaptor
//{
//    if (!_adaptor)
//        [self createAdaptor];
//    return _adaptor;
//}
//
//- (void)createAdaptor
//{
//    if(!self.cityid)
//        return;
//    
//    _adaptor = [[DJConfigAdaptor alloc] init];
//    
//    //从数据库获取model并存放到modelArr
//    [[DJConfigDB shareDB] getConfigDataListData:(NSString *)self.cityid];
//    
//    [self registerClassName];
//    
//    [self getVersionConfigFromDB:self.cityid];
//    if (self.versionConfig.count != 0) {
//        [_adaptor updateVersion:self.versionConfig];
//    }
//}
//

//
//- (NSString *)getDynamicUrlWithURLKey:(NSString *)key
//{
//    NSString *url;
//    id model = [self getDataWithKey:@"dynamic_url"];
//    if ([model isKindOfClass:[NSArray class]]) {
//        id dic = [model lastObject];
//        if ([dic isKindOfClass:[NSDictionary class]]) {
//            url = dic[key];
//        }
//    }
//    return url;
//}

