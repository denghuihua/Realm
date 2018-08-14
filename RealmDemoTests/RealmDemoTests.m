//
//  RealmDemoTests.m
//  RealmDemoTests
//
//  Created by huihuadeng on 2018/8/7.
//  Copyright © 2018年 huihuadeng. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PersonService.h"
#import <Realm/Realm.h>

@interface RealmDemoTests : XCTestCase

@end

@implementation RealmDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testInsertPerformanceExample {
    // This is an example of a performance test case.
    PersonService *db = [[PersonService alloc] init];
    [self measureBlock:^{
        [db insert];
    }];
}

- (void)test_PerInsertformanceExample {
    // This is an example of a performance test case.
    PersonService *db = [[PersonService alloc] init];
    [self measureBlock:^{
        [db perInsert];
    }];
}

- (void)test_ReadPerformanceExample {
    // This is an example of a performance test case.
    PersonService *db = [[PersonService alloc] init];
    [self measureBlock:^{
        [db read];
    }];
}


- (void)test_updatePerformanceExample {
    // This is an example of a performance test case.
    PersonService *db = [[PersonService alloc] init];
    RLMResults *resluts =  [db read];
    [self measureBlock:^{
        [db update:resluts];
    }];
}



@end
