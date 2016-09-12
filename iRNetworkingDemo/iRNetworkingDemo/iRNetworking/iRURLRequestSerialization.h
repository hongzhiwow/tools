//
//  iRURLRequestSerialization.h
//  iRNetworkingDemo
//
//  Created by 王宏志 on 16/6/16.
//  Copyright © 2016年 iResearch.cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WEAKOBJECT(object)  autoreleasepool{} __weak typeof(object) object##Weak = object;
#define STRONGOBJECT(object) 

@interface iRURLRequestSerialization : NSObject

+(NSString *)iRQueryStringFromParameters:(NSDictionary *)parameters;

@end
