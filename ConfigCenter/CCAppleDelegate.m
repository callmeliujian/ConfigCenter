//
//  CCAppleDelegate.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/4.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "CCAppleDelegate.h"
#import "CCExampleListViewController.h"

@implementation CCAppleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: CCExampleListViewController.new];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
