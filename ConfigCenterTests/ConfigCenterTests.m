//
//  ConfigCenterTests.m
//  ConfigCenterTests
//
//  Created by 叫我小贱🤪 on 2017/12/9.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConfigManager.h"
#import "ConfigDB.h"

@interface ConfigCenterTests : XCTestCase

@property (nonatomic, strong) ConfigManager *configManager;

@property (nonatomic, strong) ConfigDB *configDB;

@end

@implementation ConfigCenterTests

- (void)setUp {
    [super setUp];
    
    self.configManager = [ConfigManager shareInstance];
    self.configDB = [ConfigDB shareDB];
    
}

- (void)tearDown {
    self.configManager = nil;
    self.configDB = nil;
    [super tearDown];
}

- (void)testExample {
    [self test_shareInstance];
    [self test_getConfigVersion];
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

- (void)test_getConfigVersion {
    XCTAssertNotNil([self.configManager getConfigVersion], @"getConfigVersion通过单元测试");
}

- (void)test_shareDB {
    XCTAssertEqualObjects(self.configDB, [ConfigDB shareDB], @"shareDB通过单元测试");
}

- (void)test_openDB {
    XCTAssert([self.configDB openDB],@"openDB通过单元测试");
}

- (void)testCloseDB {
    XCTAssert([self.configDB closeDB],@"closeDB通过单元测试");
}

@end
