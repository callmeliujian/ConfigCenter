//
//  ConfigVersionModel.h
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConfigVersionCategory <NSObject>

+ (void)setUserGroupFunc:(NSString *)userGroup;

@end

@interface ConfigVersionModel : NSObject

/*
 cityid    int    城市id
 version    bigint    城市的版本号
 userGroup    varchar  用户所属分组（用户A/BTest）
 */
@property (nonatomic, strong) NSString *cityid;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *userGroup;


- (instancetype)initWithCity:(NSString *)cityid version:(NSString *)version userGroup:(NSString *)userGroup;

@end
