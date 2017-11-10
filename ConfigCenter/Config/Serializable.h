//
//  Serializable.h
//  ConfigCenter
//
//  Created by 刘健 on 08/11/2017.
//  Copyright © 2017 刘健. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Serializable <NSObject>

- (void)deserialize:(NSArray *)map;

@end
