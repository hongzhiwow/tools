//
//  iRNetService.m
//  iRNetworkingDemo
//
//  Created by 王宏志 on 16/6/16.
//  Copyright © 2016年 iResearch.cloud. All rights reserved.
//

#import "iRNetService.h"
#import "iRSessionManager.h"

@implementation iRNetService

+ (NSURLSessionDataTask *)requestWithMethod:(NSString *)method
               URLString:(NSString *)URLString
                 success:(void (^)(id JSONObject,NSURLResponse * response))success
                 failure:(void (^)(NSError * error))failure
{
    NSParameterAssert(URLString);
    NSParameterAssert(method);    
    return [[iRSessionManager sharedManager] requestURLString:URLString HTTPMethod:method parameters:nil success:success failure:failure];
}

+ (NSURLSessionDataTask *)requestGetWithURLString:(NSString *)URLString
                       success:(void (^)(id JSONObject,NSURLResponse * response))success
                       failure:(void (^)(NSError * error))failure
{
    NSParameterAssert(URLString);
    return [[iRSessionManager sharedManager] requestURLString:URLString HTTPMethod:@"GET" parameters:nil success:success failure:failure];

}

+ (NSURLSessionDataTask *)requestGetWithURLString:(NSString *)URLString
                    parameters:(id) parameters
                       success:(void (^)(id JSONObject,NSURLResponse * response))success
                       failure:(void (^)(NSError * error))failure
{
    NSParameterAssert(URLString);
    NSParameterAssert(parameters);
    return [[iRSessionManager sharedManager] requestURLString:URLString HTTPMethod:@"GET" parameters:parameters success:success failure:failure];

}

+ (NSURLSessionDataTask *)requestPostWithURLString:(NSString *)URLString
                        success:(void (^)(id JSONObject,NSURLResponse * response))success
                        failure:(void (^)(NSError * error))failure
{
    NSParameterAssert(URLString);
    return [[iRSessionManager sharedManager] requestURLString:URLString HTTPMethod:@"POST" parameters:nil success:success failure:failure];

}

+ (NSURLSessionDataTask *)requestPostWithURLString:(NSString *)URLString
                     parameters:(id) parameters
                        success:(void (^)(id JSONObject,NSURLResponse * response))success
                        failure:(void (^)(NSError * error))failure
{
    NSParameterAssert(URLString);
    NSParameterAssert(parameters);    
    return [[iRSessionManager sharedManager] requestURLString:URLString HTTPMethod:@"POST" parameters:parameters success:success failure:failure];

}

@end
