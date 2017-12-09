//
//  ConfigManager.h
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigAdaptor.h"

@protocol ConfigManagerDelegate <NSObject>

@optional
/**
 增量更新
 */
- (void) partKeysChange;
/**
 全量更新
 */
- (void) allKeysChange;
/**
 没有数据更新
 */
- (void) congfigNoChange;
/**
 网络问题，没有获取到数据
 */
- (void) failureNetWork:(NSDictionary *)errorDict;
@end

@interface ConfigManager : NSObject

@property (nonatomic, strong) NSString *cityid;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, assign) id<ConfigManagerDelegate> delegate;
/**
 YES：按模块获取数据
 NO：正常获取数据
 */
@property (nonatomic, assign) BOOL isGetModelData;


+ (instancetype)shareInstance;
- (void)setupParams:(NSDictionary *)params;
- (NSString *)getConfigVersion;
- (void)deleteOldDB;
- (void)getConfigDataFromNetWork;

/**
 城市变化
 城市发生变化的时候将config_metadata表以外的其他表都删除

 @param cityid 城市ID
 */
- (void)cityChanged:(NSString *)cityid;

/**
 获得配置中心数据所有表名
 */
- (NSArray *)getAllConfigCenterTableName;

- (NSArray *)getAllDataWithTableName:(NSString *)tabelName;
@end
