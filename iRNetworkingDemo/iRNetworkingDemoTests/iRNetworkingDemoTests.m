//
//  iRNetworkingDemoTests.m
//  iRNetworkingDemoTests
//
//  Created by 王宏志 on 16/6/15.
//  Copyright © 2016年 王宏志. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "iRNetService.h"

@interface iRNetworkingDemoTests : XCTestCase

@end

@implementation iRNetworkingDemoTests

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

- (void)testRequest
{
//    [iRNetworking sharedNetManager];
//    [iRNetworking hz_postRequestWithURL:@"http://www.weather.com.cn/data/cityinfo/101010100.html" HTTPMethod:@"GET" param:@{} result:^(id result, BOOL status) {
//        //
//    }];
    for (int i = 0; i < 1000; i ++) {
        [iRNetService requestPostWithURLString:@"http://www.weather.com.cn/data/cityinfo/101010100.html" success:^(id JSONObject, NSURLResponse *response) {
            NSLog(@"%@ -----------\n %@",JSONObject,response);

        } failure:^(NSError *error) {
            NSLog(@"%@ ",error);
        }];
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
