//
//  ConfigDB.h
//  ConfigCenter
//
//  Created by 刘健 on 09/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigDB : NSObject

+ (instancetype)shareDB;
- (BOOL)openDB;
- (BOOL)closeDB;
/**
 判断是要增加数据还是要删除数据
 */
- (void)hanldDataToDB:(NSDictionary *)dic;
//全量更新
- (void)updateDataToDB:(NSDictionary *)dic;

@end
