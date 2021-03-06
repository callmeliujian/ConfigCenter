//
//  LJConfigManager.m
//  ConfigCenter
//
//  Created by 刘健 on 06/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "LJConfigManager.h"
#import "ConfigManager.h"
#import "ConfigUtils.h"
#import "NSString+Utils.h"

@interface LJConfigManager ()

@end

@implementation LJConfigManager

+ (instancetype)shareInstance {
    static LJConfigManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[LJConfigManager alloc] init];
        }
    });
    return manager;
}

- (void)createManager {
    if (self.isDeleteBD){
        [[ConfigManager shareInstance] deleteOldDB];
        self.isDeleteBD = NO;
    }
    NSDictionary *configParamDic = [self configParam];
    [ConfigManager shareInstance].isGetModelData = self.isGetModelData;
    [[ConfigManager shareInstance] setupParams:configParamDic];
}

- (NSArray *)allTableNames {
    _allTableNames = [[ConfigManager shareInstance] getAllConfigCenterTableName];
    return _allTableNames;
}

- (NSDictionary *)configParam {
    long long recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *currentTime = [NSString stringWithFormat:@"%lld", recordTime];
    NSString *res = [NSString stringWithFormat:@"encryptid=%@secretKey=%@time=%@",@"1001", @"wubashenqi", currentTime];
    NSString *res_sha1 = [ConfigUtils SHA1:res];
    NSMutableDictionary *configParam = [[NSMutableDictionary alloc] init];
    [configParam setObject:@"10.37.18.43:8030" forKey:@"URL"];
    [configParam setObject:@"" forKey:@"DB"];
    [configParam setObject:[self.param objectForKey:@"app"]  forKey:@"app"];
    [configParam setObject:[self.param objectForKey:@"platform"] forKey:@"platform"];
    [configParam setObject:[self.param objectForKey:@"appversion"] forKey:@"appversion"];
    [configParam setObject:[self.param objectForKey:@"cityid"] forKey:@"cityid"];
    NSString *versionStr = [[ConfigManager shareInstance] getConfigVersion];
    if ([NSString isEmptyString:versionStr]) versionStr = @"-1";
    [configParam setObject:versionStr forKey:@"version"];
    [configParam setObject:@"1001" forKey:@"encryptid"];
    [configParam setObject:currentTime forKey:@"time"];
    [configParam setObject:res_sha1 forKey:@"res"];
    [configParam setObject:[self.param objectForKey:@"modelName"] forKey:@"modelName"];
    return configParam;
}

@end
