//
//  ConfigDB.h
//  ConfigCenter
//
//  Created by 刘健 on 09/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConfigDBDelegate <NSObject>

- (void) getFailureData:(NSDictionary *)dic;

@end

@interface ConfigDB : NSObject

@property (nonatomic, weak) id<ConfigDBDelegate> delegate;

+ (instancetype)shareDB;

/**
 判断是要增加数据还是要删除数据
 */
- (void)hanldDataToDB:(NSDictionary *)dic;

- (NSArray *)getAllTbaleName;
/**
 获取tableName里所有数据
 */
- (NSArray *)selectAllDataFromDBWithTableName:(NSString *)tableName;
- (NSString *)selectDataFromDB:(NSString *)key withTableName:(NSString *)tableName;

@end
