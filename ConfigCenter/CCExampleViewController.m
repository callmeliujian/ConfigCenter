//
//  CCExampleViewController.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/4.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "CCExampleViewController.h"

@interface CCExampleViewController ()

@property (nonatomic, strong) Class viewClass;

@end

@implementation CCExampleViewController

- (id)initWithTitle:(NSString *)title viewClass:(Class)viewClass {
    self = [super init];
    if (!self) return nil;
    
    self.title = title;
    self.viewClass = viewClass;
    
    return self;
}

- (void)loadView {
    self.view = self.viewClass.new;
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
