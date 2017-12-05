//
//  CCAllDataView.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/4.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "CCAllDataView.h"
#import "ConfigManager.h"

@interface CCAllDataView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *cityPicker;
@property (nonatomic, strong) UIPickerView *allPicker;
@property (nonatomic, strong) UIPickerView *modelPicker;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSArray *cityArray;
@property (nonatomic, strong) NSArray *appArray;
@property (nonatomic, strong) NSArray *platArray;
@property (nonatomic, strong) NSArray *userVersionArray;
@property (nonatomic, strong) NSArray *modelArray;

@end

@implementation CCAllDataView

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    UILabel *cityLael = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 60, 30)];
    cityLael.text = @"城市：";
    [self addSubview:cityLael];
    self.cityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(100, 50, 80, 100)];
    [self addSubview:self.cityPicker];
    
    self.allPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 150, [UIScreen mainScreen].bounds.size.width, 100)];
    [self addSubview:self.allPicker];
    
    self.modelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 250, [UIScreen mainScreen].bounds.size.width, 100)];
    [self addSubview:self.modelPicker];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 350, [UIScreen mainScreen].bounds.size.width, 500)];
    [self addSubview:self.textView];
    
    self.cityArray = [[NSArray alloc] initWithObjects:@"全国", nil];
    self.appArray = [[NSArray alloc] initWithObjects:@"suyun", @"123", nil];
    self.platArray = [[NSArray alloc] initWithObjects:@"ios", nil];
    self.userVersionArray = [[NSArray alloc] initWithObjects:@"1", @"2", nil];
    
    self.cityPicker.delegate = self;
    self.cityPicker.dataSource = self;
    self.allPicker.delegate = self;
    self.allPicker.dataSource = self;
    self.modelPicker.delegate = self;
    self.modelPicker.dataSource = self;

    self.textView.editable = NO;
    
    return self;
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
        return self.modelArray.count;
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
    else if (pickerView ==self.modelPicker){
        return self.modelArray[row];
    }
    else {
        return @"无数据";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.cityPicker) {
        NSLog(@"%ld",(long)row);
    } else {
        if (self.modelArray.count == 0) {
            NSLog(@"modelArray数组为空");
            return;
        }
        NSArray *array = [[ConfigManager shareInstance] getAllDataWithTableName:self.modelArray[row]];
        NSString *tempString = [array componentsJoinedByString:@","];
        self.textView.text = tempString;
    }
}

#pragma mark - Lazy

- (NSArray *)modelArray {
    _modelArray = [[ConfigManager shareInstance] getAllConfigCenterTableName];
    return _modelArray;
}


@end
