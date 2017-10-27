//
//  ConfigVersionModel.m
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "ConfigVersionModel.h"

@implementation ConfigVersionModel

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.cityid = [NSString stringWithFormat:@"%@", dic[@"cityid"]];
        self.version = [NSString stringWithFormat:@"%@", dic[@"version"]];
        self.userGroup = [NSString stringWithFormat:@"%@", dic[@"userGroup"]];
    }
    return self;
}

- (instancetype)initWithCity:(NSString *)cityid version:(NSString *)version userGroup:(NSString *)userGroup
{
    self = [super init];
    if (self) {
        self.cityid = cityid;
        self.version = version;
        self.userGroup = userGroup;
    }
    return self;
}

- (void)setUserGroup:(NSString *)userGroup
{
    _userGroup = userGroup;
}

@end
