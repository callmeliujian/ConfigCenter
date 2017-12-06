//
//  CCPicekerViewDataSoure.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/6.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "CCPicekerViewDataSoure.h"
#import "ConfigManager.h"
#import "LJConfigManager.h"

@interface CCPicekerViewDataSoure () <UIPickerViewDataSource, ConfigManagerDelegate>

@property (nonatomic, strong) LJConfigManager *configManager;

@end

@implementation CCPicekerViewDataSoure

- (instancetype)init
{
    self = [super init];
    if (self) {
        [ConfigManager shareInstance].delegate = self;
        self.configManager = [LJConfigManager shareInstance];
        [self configParam];
        self.configManager.param = self.param;
        [self.configManager createManager];
    }
    return self;
}

- (void)configParam {
    self.param = [NSMutableDictionary dictionary];
    [self.param setObject:@"1" forKey:@"appversion"];
    [self.param setObject:@"" forKey:@"modelName"];
    [self.param setObject:@"suyunUser" forKey:@"app"];
    [self.param setObject:@"pt" forKey:@"platform"];
}

/**
 指定picker有几个表盘
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.allPicker) {
        return 3;
    } else
        return 1;
}

/**
 每个表盘显示几行
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.cityPicker) {
        return  self.cityArray.count;
    } else if (pickerView == self.allPicker) {
        if (component == 0) {
            return self.appArray.count;
        } else if (component == 1) {
            return self.platArray.count;
        } else if (component == 2) {
            return self.userVersionArray.count;
        } else {
            return 1;
        }
    }
    else {
        return self.dbmodelArray.count;
        return 0;
    }
    
}

#pragma mark - ConfigManagerDelegate

- (void) allKeysChange {
    self.dbmodelArray = self.configManager.allTableNames;
    [self useDelegateMethod];
}

- (void) partKeysChange {
    self.dbmodelArray = self.configManager.allTableNames;
    [self useDelegateMethod];
}

- (void) congfigNoChange {
    self.dbmodelArray = self.configManager.allTableNames;
    [self useDelegateMethod];
}

- (void) failureNetWork:(NSDictionary *)errorDict {
    
}

- (void)useDelegateMethod {
    if ([self.delegate respondsToSelector:@selector(roaldPickerView)]) {
        [self.delegate roaldPickerView];
    }
}

#pragma mark - Lazy

- (NSArray *)cityArray {
    if (!_cityArray) {
        _cityArray = [[NSArray alloc] initWithObjects:@"全国", nil];
    }
    return _cityArray;
}

- (NSArray *)appArray {
    if (!_appArray) {
        _appArray = [[NSArray alloc] initWithObjects:@"suyunUser", @"suyun", @"123", @"banjiaguesttest", nil];
    }
    return _appArray;
}

- (NSArray *)platArray {
    if (!_platArray) {
        _platArray = [[NSArray alloc] initWithObjects:@"pt", @"Android", @"ios",nil];;
    }
    return _platArray;
}

- (NSArray *)userVersionArray {
    if (!_userVersionArray) {
        _userVersionArray = [[NSArray alloc] initWithObjects:@"1", @"1.1.1", @"6.6.6", @"4.8.3", @"4.8.2", @"1.0", @"7.7.7", @"1.2.3", @"2.2.2", @"3.3.3", @"4.4.4", @"5.5.5", nil];
    }
    return _userVersionArray;
}

@end
