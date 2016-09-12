//
//  ViewController.m
//  iRNetworkingDemo
//
//  Created by 王宏志 on 16/6/15.
//  Copyright © 2016年 王宏志. All rights reserved.
//

#import "ViewController.h"

#import "iRNetService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    http://www.weather.com.cn/data/cityinfo/101010100.html
    
//    [iRNetworking sharedNetManager];
//    [iRNetworking hz_postRequestWithURL:@"http://www.weather.com.cn/data/cityinfo/101010100.html" HTTPMethod:@"GET" param:@{} result:^(id result, BOOL status) {
//        //
//    }];
}
- (IBAction)requestAction:(id)sender {
    
    [iRNetService requestPostWithURLString:@"http://www.weather.com.cn/data/cityinfo/101010100.html" success:^(id JSONObject, NSURLResponse *response) {
        NSLog(@"%@ -----------\n %@",JSONObject,response);
    } failure:^(NSError *error) {
        NSLog(@"%@ ",error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
