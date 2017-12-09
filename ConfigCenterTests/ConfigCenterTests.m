//
//  ConfigCenterTests.m
//  ConfigCenterTests
//
//  Created by 叫我小贱🤪 on 2017/12/9.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConfigManager.h"

@interface ConfigCenterTests : XCTestCase

@property (nonatomic, strong) ConfigManager *configManager;

@end

@implementation ConfigCenterTests

- (void)setUp {
    [super setUp];
    
    self.configManager = [ConfigManager shareInstance];
    
}

- (void)tearDown {
    self.configManager = nil;
    [super tearDown];
}

- (void)testExample {
    [self test_shareInstance];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)test_shareInstance {
    XCTAssertEqualObjects(self.configManager, [ConfigManager shareInstance], @"shareInstance通过单元测试");
}

@end
