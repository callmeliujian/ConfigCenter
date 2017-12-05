//
//  CCAllDataView.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/4.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "CCAllDataView.h"
#import "ConfigManager.h"
#import "LJConfigManager.h"
#import "ConfigManager.h"

@interface CCAllDataView () <UIPickerViewDelegate, UIPickerViewDataSource, ConfigManagerDelegate>

@property (nonatomic, strong) UIPickerView *cityPicker;
@property (nonatomic, strong) UIPickerView *allPicker;
@property (nonatomic, strong) UIPickerView *dbModelPicker;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSArray *cityArray;
@property (nonatomic, strong) NSArray *appArray;
@property (nonatomic, strong) NSArray *platArray;
@property (nonatomic, strong) NSArray *userVersionArray;
@property (nonatomic, strong) NSArray *dbmodelArray;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) NSMutableDictionary *param;

@property (nonatomic, strong) LJConfigManager *configManager;

@end

@implementation CCAllDataView

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    [ConfigManager shareInstance].delegate = self;
    
    UILabel *cityLael = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 60, 30)];
    cityLael.text = @"城市：";
    [self addSubview:cityLael];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(180, 80, 80, 30);
    [self.button setTitle:@"获取数据" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
    
    self.cityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(100, 50, 80, 100)];
    [self addSubview:self.cityPicker];
    
    self.allPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 150, [UIScreen mainScreen].bounds.size.width, 100)];
    [self addSubview:self.allPicker];
    
    self.dbModelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 250, [UIScreen mainScreen].bounds.size.width, 100)];
    [self addSubview:self.dbModelPicker];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 350, [UIScreen mainScreen].bounds.size.width, 500)];
    [self addSubview:self.textView];
    
    self.cityArray = [[NSArray alloc] initWithObjects:@"全国", nil];
    self.appArray = [[NSArray alloc] initWithObjects:@"suyun", @"123", nil];
    self.platArray = [[NSArray alloc] initWithObjects:@"ios", nil];
    self.userVersionArray = [[NSArray alloc] initWithObjects:@"1", @"1.1.1", nil];
    
    self.cityPicker.delegate = self;
    self.cityPicker.dataSource = self;
    self.allPicker.delegate = self;
    self.allPicker.dataSource = self;
    self.dbModelPicker.delegate = self;
    self.dbModelPicker.dataSource = self;

    self.textView.editable = NO;
    
    self.param = [NSMutableDictionary dictionary];
    [self.param setObject:@"1" forKey:@"appversion"];
    
    self.configManager = [LJConfigManager shareInstance];
    self.configManager.param = self.param;
    [self.configManager createManager];
    
    self.dbmodelArray = [NSArray array];
    
    return self;
}

- (void) allKeysChange {
    self.dbmodelArray = [[ConfigManager shareInstance] getAllConfigCenterTableName];
    [self.dbModelPicker reloadAllComponents];
    
}

- (void) partKeysChange {
    self.dbmodelArray = [[ConfigManager shareInstance] getAllConfigCenterTableName];
    [self.dbModelPicker reloadAllComponents];
    
}

- (void) congfigNoChange {
    self.dbmodelArray = [[ConfigManager shareInstance] getAllConfigCenterTableName];
    [self.dbModelPicker reloadAllComponents];
    
}

#pragma mark - UIPickerViewDataSource

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

#pragma mark - UIPickerViewDelegate

/**
 表盘显示的数据
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.cityPicker) {
        return  self.cityArray[row];
    }  else if (pickerView == self.allPicker) {
        if (component == 0) {
            return self.appArray[row];
        } else if (component == 1) {
            return self.platArray[row];
        } else {
            return self.userVersionArray[row];
        }
    }
    else if (pickerView ==self.dbModelPicker){
        return self.dbmodelArray[row];
    }
    else {
        return @"无数据";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.cityPicker) {
        [self.param setObject:@"-1" forKey: @"cityid"];
    } else if (pickerView == self.allPicker) {
        if (component == 0) {
            
        } else if (component == 1) {
            
        } else {
            self.configManager.isDeleteBD = YES;
            [self dbmodelArray];
            [self.param setObject:self.userVersionArray[row] forKey:@"appversion"];
        }
    } else {
        if (self.dbmodelArray.count == 0) {
            NSLog(@"modelArray数组为空");
            return;
        }
        NSArray *array = [[ConfigManager shareInstance] getAllDataWithTableName:self.dbmodelArray[row]];
        NSString *tempString = [array componentsJoinedByString:@","];
        self.textView.text = tempString;
    }
}

- (void)buttonClicked {
    [self.configManager createManager];
}

#pragma mark - Lazy

//- (NSArray *)dbmodelArray {
//    _dbmodelArray = [[ConfigManager shareInstance] getAllConfigCenterTableName];
//    return _dbmodelArray;
//}


@end
