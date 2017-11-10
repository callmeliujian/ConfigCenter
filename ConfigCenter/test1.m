//
//  test1.m
//  ConfigCenter
//
//  Created by 刘健 on 08/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "test1.h"

@implementation test1

- (void)deserialize:(NSArray *)map {
    
    for (NSDictionary *dic in map) {
        NSLog(@"%@",dic);
    }
    
}

@end
