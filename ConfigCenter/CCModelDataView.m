//
//  CCModelDataView.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/4.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "CCModelDataView.h"

@interface CCModelDataView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *modelPicker;

@property (nonatomic, strong) NSArray *modelArray;

@end

@implementation CCModelDataView

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.modelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(100, 50, 80, 100)];
    self.modelPicker.delegate = self;
    self.modelPicker.dataSource = self;
    [self addSubview:self.modelPicker];
    
    self.modelArray = [[NSArray alloc] initWithObjects:@"login", @"pay", @"ha", nil];
    
    return self;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.modelPicker) {
        return self.modelArray.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.modelPicker) {
        return self.modelArray[row];
    }
    return @"无数据";
}



@end
