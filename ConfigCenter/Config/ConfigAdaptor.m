//
//  ConfigAdaptor.m
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "ConfigAdaptor.h"



@implementation ConfigAdaptor

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modelArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)updateData:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) return;
    for (NSString *key in dic) {
        if ([dic[key] isKindOfClass:[NSArray class]]) {
            NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
            [mutableDic setValue:key forKey:@"key"];
            [mutableDic setValue:dic[key] forKey:@"value"];
            ConfigDataModel *dataModel = [self getDataModelWithKey:key];
            [dataModel assignWithDic:mutableDic];
        }
    }
}

-(void)registerModelWithKey:(NSString *)key modelClassName:(NSString *)className
{
    // 查找看看是否已经构建对应的model
    for (ConfigDataModel *model in self.modelArray) {
        if ([model.key isEqualToString:key])
        {
            model.className = className;
            return;
        }
    }
    
    ConfigDataModel *model = [[ConfigDataModel alloc] init];
    model.key = key;
    model.className = className;
    [self.modelArray addObject:model];
}

- (ConfigDataModel *)getDataModelWithKey:(NSString *)key
{
    for (ConfigDataModel *model in self.modelArray) {
        if ([model.key isEqualToString:key])
            return model;
    }
    
    ConfigDataModel *model = [[ConfigDataModel alloc] init];
    model.key = key;
    [self.modelArray addObject:model];
    return model;
}

- (id)getDataWithKey:(NSString *)key
{
    for (ConfigDataModel *model in self.modelArray) {
        if ([model.key isEqualToString:key])
        {
            return model.model;
        }
    }
    
    return nil;
}

- (NSArray *)getArrayDataWithKey:(NSString *)key
{
    if ([[self getDataWithKey:key] isKindOfClass:[NSArray class]]) {
        return (NSArray *)[self getDataWithKey:key];
    }
    return nil;
}

@end
