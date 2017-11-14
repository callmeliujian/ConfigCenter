//
//  ConfigDataModel.h
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConfigDataModelExt<NSObject>

/** 自定义生成Model对象 */
+ (id)customGenerateModel:(NSString *)targetClass
               parameters:(NSDictionary *)parameters;

@end

@interface ConfigDataModel : NSObject

/*cityid    int    城市id
 key    varchar 配置模块key
 value    varchar    配置模块value
 version    bigint    该模块的最后版本号
 updatetime    datetime    数据最后更新时间*/

//@property (nonatomic, strong) NSString *cityid;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *updatetime;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) id model;

- (instancetype)initWithDic:(NSDictionary *)dic;

- (void)assignWithDic:(NSDictionary *)params;

@end
