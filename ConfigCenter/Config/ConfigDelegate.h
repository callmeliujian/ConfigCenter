//
//  ConfigDelegate.h
//  ConfigCenter
//
//  Created by 刘健 on 06/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConfigDelegate <NSObject>

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
