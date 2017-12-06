//
//  CCPicekerViewDataSoure.h
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/6.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCPicekerViewDataSoure : NSObject

@property (nonatomic, strong) UIPickerView *allPicker;
@property (nonatomic, strong) UIPickerView *cityPicker;

@property (nonatomic, strong) NSArray *cityArray;
@property (nonatomic, strong) NSArray *appArray;
@property (nonatomic, strong) NSArray *platArray;
@property (nonatomic, strong) NSArray *userVersionArray;
@property (nonatomic, strong) NSArray *dbmodelArray;

@end
