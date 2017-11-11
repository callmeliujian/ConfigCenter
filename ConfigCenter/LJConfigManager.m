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
    NSMutableDictionary *configParam = [[NSMutableDictionary alloc] init];
    [configParam setObject:self.keyArray forKey:@"modelkeyname"];
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
