//
//  ConfigAdaptor.h
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigVersionModel.h"
#import "ConfigDataModel.h"

@interface ConfigAdaptor : NSObject

//存放DJConfigDataModel对象的数组
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) NSString *userGroup;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) ConfigVersionModel *versionModel;

- (void)updateVersion:(NSDictionary *)data;

-(void)registerModelWithKey:(NSString *)key modelClassName:(NSString *)className;

- (ConfigDataModel *)getDataModelWithKey:(NSString *)key;

- (id)getDataWithKey:(NSString *)key;
- (NSArray *)getArrayDataWithKey:(NSString *)key;

- (NSString *)version;

- (void)updateData:(NSDictionary *)dict;

@end
