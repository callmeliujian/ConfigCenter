//
//  NSString+Utils.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/8.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

+ (BOOL)isEmptyString:(NSString *)str {
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (str == nil) {
        return YES;
    }
    if (str.length == 0 ||
        [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        return YES;
    }
    if ([str isEqualToString:@"null"]) {
        return YES;
    }
    return NO;
}

@end
