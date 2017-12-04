//
//  CCAllDataView.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/4.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "CCAllDataView.h"

@implementation CCAllDataView

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    UILabel *cityLael = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 60, 30)];
    cityLael.text = @"城市：";
    [self addSubview:cityLael];
    UIPickerView *cityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(100, 50, 80, 100)];
    [self addSubview:cityPicker];
    
    UIPickerView *allPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 150, [UIScreen mainScreen].bounds.size.width, 100)];
    [self addSubview:allPicker];
    
    NSArray *appArray = [[NSArray alloc] initWithObjects:@"suyun", @"123", nil];
    NSArray *platArray = [[NSArray alloc] initWithObjects:@"ios", nil];
    NSArray *userVersionArray = [[NSArray alloc] initWithObjects:@"1", @"2", nil];
    
    
//    cityPicker.delegate = self;
//    cityPicker.dataSource = self;
//    allPicker.delegate = self;
//    allPicker.dataSource = self;
//
//    modelPicker.delegate = self;
//    self.modelPicker.dataSource = self;
//    self.textView.editable = NO;
    
    
    return self;
}

@end
