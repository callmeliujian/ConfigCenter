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
    // 注册key关联的model类名称
    [self ConfigRegister];
    NSMutableDictionary *configParam = [[NSMutableDictionary alloc] init];
    [[ConfigManager shareInstance] setupParams:configParam];
    [[ConfigManager shareInstance] addDelegate:self];
}

/**
 注册关联类
 */
- (void)ConfigRegister {
    [[ConfigManager shareInstance] registerWithKey:@"login" modelClassName:@"test1"];
    [[ConfigManager shareInstance] registerWithKey:@"pay" modelClassName:@"test2"];
    [[ConfigManager shareInstance] registerWithKey:@"key3" modelClassName:@"test3"];
}

@end
