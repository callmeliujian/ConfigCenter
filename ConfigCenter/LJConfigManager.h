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

@property (nonatomic, strong) NSArray *keyArray;

@property (nonatomic, strong) NSDictionary *param;

+ (instancetype)shareInstance;
- (void)createManager;

@end
