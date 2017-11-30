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

//增量更新
- (void) partKeysChange:(NSDictionary *)keyValue;
//全量更新
- (void) allKeysChange:(NSDictionary *)keyValue;

//城市id变化
- (void) cityIdChange;

//数据变化
- (void) configDataChange;

//没有数据更新
- (void) congfigNoChange;

@end

@interface ConfigManager : NSObject

@property (nonatomic, strong) NSString *cityid;
@property (nonatomic, strong) ConfigAdaptor *adaptor;
@property (nonatomic, strong) NSDictionary *params;


+ (instancetype)shareInstance;
- (void)setupParams:(NSDictionary *)params;

- (void)addDelegate:(id<ConfigManagerDelegate>)delegate;
- (void)removeDelegate:(id<ConfigManagerDelegate>)delegate;

- (void)getConfigDataFromNetWork;
- (void)getVersionConfigFromDB:(NSString *)cityid;

- (NSString *)getUserGroupFromAdaptor;
- (NSString *)getActionFromAdaptor;
- (void)setAdaptorVersion:(NSString *)version;

//主动更新
- (NSDictionary *)getAllConfig;
- (NSDictionary *)getVersionConfig;

-(void)registerWithKey:(NSString *)key modelClassName:(NSString *)className;
- (id)getDataWithKey:(NSString *)key;
- (id)getArrayDataWithKey:(NSString *)key;

/**
 城市变化
 城市发生变化的时候将config_metadata表以外的其他表都删除

 @param cityid 城市ID
 */
- (void)cityChanged:(NSString *)cityid;

@end
