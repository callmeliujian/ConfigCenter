//
//  CCModelDataView.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/4.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "CCModelDataView.h"
#import "LJConfigManager.h"

@interface CCModelDataView () <UIPickerViewDelegate, UIPickerViewDataSource, ConfigManagerDelegate>

@property (nonatomic, strong) UIPickerView *modelPicker;

@property (nonatomic, strong) UIPickerView *dbModelPicker;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) NSArray *modelArray;
@property (nonatomic, strong) NSArray *dbmodelArray;

@property (nonatomic, strong) LJConfigManager *configManager;

@property (nonatomic, strong) NSMutableDictionary *param;

@property (nonatomic, strong) UITextView *textView;

@end

@implementation CCModelDataView

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    [ConfigManager shareInstance].delegate = self;
    
    self.dbmodelArray = [NSArray array];
    self.modelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(100, 50, 80, 100)];
    self.modelPicker.delegate = self;
    self.modelPicker.dataSource = self;
    [self addSubview:self.modelPicker];
    
    self.dbModelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 250, [UIScreen mainScreen].bounds.size.width, 100)];
    self.dbModelPicker.delegate = self;
    self.dbModelPicker.dataSource = self;
    [self addSubview:self.dbModelPicker];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(180, 80, 80, 30);
    [self.button setTitle:@"获取数据" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
    
    self.modelArray = [[NSArray alloc] initWithObjects:@"login", @"pay", @"ha", nil];
    self.param = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"login", @"modelName", nil];
    [self.param setObject:@"1" forKey:@"appversion"];
    
    self.configManager = [LJConfigManager shareInstance];
    self.configManager.isGetModelData = YES;
    
    self.configManager.param = self.param;
    
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 350, [UIScreen mainScreen].bounds.size.width, 500)];
    self.textView.editable = NO;
    
    [self addSubview:self.textView];
    
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.modelPicker) {
        return self.modelArray.count;
    } else if (pickerView == self.dbModelPicker) {
        return self.dbmodelArray.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.modelPicker) {
        return self.modelArray[row];
    } else if (pickerView == self.dbModelPicker) {
        return self.dbmodelArray[row];
    }
    return @"无数据";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.modelPicker) {
        [self.param setObject:self.modelArray[row] forKey:@"modelName"];
    } else if (pickerView == self.dbModelPicker) {
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



@end
