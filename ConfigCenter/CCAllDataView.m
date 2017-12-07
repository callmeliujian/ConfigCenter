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
#import "CCPicekerViewDataSoure.h"

@interface CCAllDataView () <UIPickerViewDelegate, UIPickerViewDataSource, CCPicekerViewDataSoureDelegate>

@property (nonatomic, strong) UIPickerView *cityPicker;
@property (nonatomic, strong) UIPickerView *allPicker;
@property (nonatomic, strong) UIPickerView *dbModelPicker;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSArray *cityArray;
@property (nonatomic, strong) NSArray *appArray;
@property (nonatomic, strong) NSArray *platArray;
@property (nonatomic, strong) NSArray *userVersionArray;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) NSMutableDictionary *param;


@property (nonatomic, strong) CCPicekerViewDataSoure *pickerDataSure;

@property (nonatomic, strong) LJConfigManager *configManager;

@end

@implementation CCAllDataView

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.configManager = [LJConfigManager shareInstance];
    
    self.pickerDataSure = [[CCPicekerViewDataSoure alloc] init];
    self.pickerDataSure.delegate = self;
    
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
    self.pickerDataSure.cityPicker = self.cityPicker;
    
    self.allPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 150, [UIScreen mainScreen].bounds.size.width, 100)];
    [self addSubview:self.allPicker];
    
    self.dbModelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 250, [UIScreen mainScreen].bounds.size.width, 100)];
    [self addSubview:self.dbModelPicker];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 350, [UIScreen mainScreen].bounds.size.width, 500)];
    self.textView.editable = NO;

    [self addSubview:self.textView];
    
    self.cityArray = self.pickerDataSure.cityArray;
    self.appArray = self.pickerDataSure.appArray;
    self.platArray = self.pickerDataSure.platArray;
    self.userVersionArray = self.pickerDataSure.userVersionArray;
    
    self.cityPicker.delegate = self;
    self.cityPicker.dataSource = self.pickerDataSure;
    self.allPicker.delegate = self;
    self.allPicker.dataSource = self;
    self.dbModelPicker.delegate = self;
    self.dbModelPicker.dataSource = self.pickerDataSure;
    
    return self;
}

- (void)roaldPickerView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dbModelPicker reloadAllComponents];
    });
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
        return self.pickerDataSure.dbmodelArray.count;
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
        return self.pickerDataSure.dbmodelArray[row];
    }
    else {
        return @"无数据";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.cityPicker) {
        self.configManager.isDeleteBD = YES;
        if (row == 0) {
            [self.pickerDataSure.param setObject:@"-1" forKey: @"cityid"];
        } else if (row == 1) {
            [self.pickerDataSure.param setObject:@"1" forKey: @"cityid"];
        }
        //[self.param setObject:@"-1" forKey: @"cityid"];
    } else if (pickerView == self.allPicker) {
        if (component == 0) {
            self.configManager.isDeleteBD = YES;
            [self.pickerDataSure.param setObject:self.appArray[row] forKey:@"app"];
        } else if (component == 1) {
            self.configManager.isDeleteBD = YES;
            [self.pickerDataSure.param setObject:self.platArray[row] forKey:@"platform"];
        } else {
            self.configManager.isDeleteBD = YES;
            [self.pickerDataSure.param setObject:self.userVersionArray[row] forKey:@"appversion"];
        }
    } else {
        if (self.pickerDataSure.dbmodelArray.count == 0) {
            NSLog(@"modelArray数组为空");
            return;
        }
        NSArray *array = [[ConfigManager shareInstance] getAllDataWithTableName:self.pickerDataSure.dbmodelArray[row]];
        NSString *tempString = [array componentsJoinedByString:@","];
        self.textView.text = tempString;
    }
}

- (void)buttonClicked {
    [self.configManager createManager];
}


@end
