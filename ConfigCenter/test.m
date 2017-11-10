//
//  test.m
//  ConfigCenter
//
//  Created by 刘健 on 07/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "test.h"

@implementation test

- (void)deserialize:(NSArray *)map {
    
    for (NSDictionary *dic in map) {
        NSLog(@"%@",dic);
    }
    
}

@end
