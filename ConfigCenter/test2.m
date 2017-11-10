//
//  test2.m
//  ConfigCenter
//
//  Created by 刘健 on 08/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import "test2.h"

@implementation test2

- (void)deserialize:(NSArray *)map {
    
    for (NSDictionary *dic in map) {
        NSLog(@"%@",dic);
    }
    
}

@end
