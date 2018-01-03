//
//  LJConfigManager.h
//  ConfigCenter
//
//  Created by 刘健 on 06/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigManager.h"

@interface LJConfigManager : NSObject <ConfigManagerDelegate>

@property (nonatomic, strong) NSDictionary *param;
/**
 是否删除老数据库
 */
@property (nonatomic, assign) BOOL isDeleteBD;
/**
 YES：按模块获取数据
 NO：正常获取数据
 */
@property (nonatomic, assign) BOOL isGetModelData;
/**
 所有的表名
 */
@property (nonatomic, strong) NSArray *allTableNames;

+ (instancetype)shareInstance;
- (void)createManager;

@end
