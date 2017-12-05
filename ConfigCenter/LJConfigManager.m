//
//  LJConfigManager.m
//  ConfigCenter
//
//  Created by 刘健 on 06/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "LJConfigManager.h"
#import "ConfigDelegate.h"
#import "ConfigManager.h"
#import "ConfigUtils.h"

@interface LJConfigManager ()

@end

@implementation LJConfigManager

+ (instancetype)shareInstance {
    static LJConfigManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[LJConfigManager alloc] init];
            manager.keyArray = [[NSArray alloc] initWithObjects:@"login", @"pay", @"key3", nil];
        }
    });
    return manager;
}

- (void)createManager {
    // 注册key关联的model类名称
    [self ConfigRegister];
    if (self.isDeleteBD)
        [[ConfigManager shareInstance] deleteOldDB];
    long long recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *currentTime = [NSString stringWithFormat:@"%lld", recordTime];
    NSString *res = [NSString stringWithFormat:@"encryptid=%@secretKey=%@time=%@",@"1001", @"wubashenqi", currentTime];
    NSString *res_sha1 = [ConfigUtils SHA1:res];
    NSMutableDictionary *configParam = [[NSMutableDictionary alloc] init];
    [configParam setObject:self.keyArray forKey:@"modelkeyname"];
    [configParam setObject:@"10.37.18.173:8030" forKey:@"URL"];
    [configParam setObject:@"" forKey:@"DB"];
    [configParam setObject:@"suyun" forKey:@"app"];
    [configParam setObject:@"pt" forKey:@"platform"];
    [configParam setObject:[self.param objectForKey:@"appversion"] forKey:@"appversion"];
    [configParam setObject:@"-1" forKey:@"cityid"];
    NSString *versionStr = [[ConfigManager shareInstance] getConfigVersion];
    if ([versionStr isEqualToString:@""]) versionStr = @"-1";
    [configParam setObject:versionStr forKey:@"version"];
    [configParam setObject:@"1001" forKey:@"encryptid"];
    [configParam setObject:currentTime forKey:@"time"];
    [configParam setObject:res_sha1 forKey:@"res"];
    [[ConfigManager shareInstance] setupParams:configParam];
    [[ConfigManager shareInstance] addDelegate:self];
}

/**
 注册关联类
 */
- (void)ConfigRegister {
    [[ConfigManager shareInstance] registerWithKey:self.keyArray[0] modelClassName:@"test1"];
    [[ConfigManager shareInstance] registerWithKey:self.keyArray[1] modelClassName:@"test2"];
    [[ConfigManager shareInstance] registerWithKey:self.keyArray[2] modelClassName:@"test3"];
}

@end
