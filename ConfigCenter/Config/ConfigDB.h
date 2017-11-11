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

@end

@interface ConfigDB : NSObject

@property (nonatomic, weak) id<ConfigDBDelegate> delegate;

+ (instancetype)shareDB;

- (BOOL)openDB;

- (BOOL)closeDB;

/**
 判断是要增加数据还是要删除数据
 */
- (void)hanldDataToDB:(NSDictionary *)dic withModelKeyName:(NSArray *)modelKeyName;

/**
 全量更新
 */
- (void)updateDataToDB:(NSDictionary *)dic;

@end
