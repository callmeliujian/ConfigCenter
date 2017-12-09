//
//  ConfigDB.h
//  ConfigCenter
//
//  Created by 刘健 on 09/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConfigDBDelegate <NSObject>
/**
 将数据库中的数据加载到内存
 */
- (void) dataFromDBToMemory:(NSDictionary *)dic;
- (void) getFailureData:(NSDictionary *)dic;

@end

@interface ConfigDB : NSObject

@property (nonatomic, weak) id<ConfigDBDelegate> delegate;

+ (instancetype)shareDB;

- (BOOL)openDB;

- (BOOL)closeDB;

/**
 判断是要增加数据还是要删除数据
 */
- (void)hanldDataToDB:(NSDictionary *)dic;

/**
 全量更新
 */
- (void)updateDataToDB:(NSDictionary *)dic;

/**
 原数据写入数据库
 */
- (BOOL)metaDataToDB:(NSDictionary *)dic;

/**
 根据表名删除表
 如果tableName为nil 则代表删除除了元数据表之外的所有表

 @param tableName 表名
 */
- (void)deleteTable:(NSString *)tableName;

- (NSArray *)recriveAllTbaleName;
/**
 获取tableName里所有数据
 */
- (NSArray *)selectAllDataFromDBWithTableName:(NSString *)tableName;
- (NSString *)selectDataFromDB:(NSString *)key withTableName:(NSString *)tableName;

@end
