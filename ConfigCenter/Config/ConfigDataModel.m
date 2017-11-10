//
//  ConfigDataModel.m
//  ConfigCenter
//
//  Created by 刘健 on 27/10/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "ConfigDataModel.h"

@interface ConfigDataModel()<ConfigDataModelExt>

@end

@implementation ConfigDataModel

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self assignWithDic:dic];
    }
    return self;
}

- (void)assignWithDic:(NSDictionary *)params
{
    self.key = [NSString stringWithFormat:@"%@", params[@"key"]];
    self.model = [self createObjectWithClassName:self.className withParams:params[@"value"]];
    if (!self.model) {
        self.model = params[@"value"];
    }
}

- (void)setClassName:(NSString *)classname
{
    if ([_className isEqualToString:classname]) return;
    
    _className = classname;  //每次设置className都会重新构建model
    self.model = [self createObjectWithClassName:self.className withParams:self.model];
}

- (NSString *)classname
{
    if (_className) {
        _className = [self.key stringByAppendingString:@"Model"];
    }
    return _className;
}

//- (id)model
//{
//    if (!_model)
//    {
//        _model = [self createObjectWithClassName:self.className withParams:[DJConfigUtils dictionaryWithJsonString:self.value]];
//    }
//    return _model;
//}

// param是{key:value}
/*根据className反射类，假如失败，返回字典
 如果param里面的value是字典，返回一个类
 如果是数组，则返回一个装有类的数组*/
- (id)createObjectWithClassName:(NSString *)className withParams:(id)param
{
    Class targetClass = NSClassFromString(className);
    
    id model;
    if (targetClass == nil) {
        model = param;
    }
    else
    {
        if ([param isKindOfClass:[NSDictionary class]]) {
            model  = [[targetClass alloc] init];
            model = [self exeMethodWithtarget:model withParam:param];
        }
        else if ([param isKindOfClass:[NSArray class]])
        {
            model = [[NSMutableArray alloc] init];
            for (id dic in param) {
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    id obj  = [[targetClass alloc] init];
                    id target = [self exeMethodWithtarget:obj withParam:dic];
                    [model addObject:target];
                }
            }
        }
        else
        {
            model = nil;
        }
    }
    return model;
}

- (id)exeMethodWithtarget:(id)target withParam:(NSDictionary *)param
{
    if([[ConfigDataModel class] respondsToSelector:@selector(customGenerateModel:parameters:)]){
        target = [ConfigDataModel customGenerateModel:target parameters:param];
        return target;
    }
    
    SEL action = NSSelectorFromString(@"deserialize:");
    if (action && [target respondsToSelector:action]) {
        [target performSelector:action withObject:param];
        return target;
    }
    
    action = NSSelectorFromString(@"initWithDictionary:error:");
    if(action && [target respondsToSelector:action])
    {
        [target performSelector:action withObject:param withObject:nil];
    }
    return target;
}

@end
