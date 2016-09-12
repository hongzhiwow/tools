//
//  iRNetService.h
//  iRNetworkingDemo
//
//  Created by 王宏志 on 16/6/16.
//  Copyright © 2016年 iResearch.cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iRNetService : NSObject

/**
 *  不带参数的请求
 *
 *  @param method    请求方法
 *  @param URLString
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (NSURLSessionDataTask *)requestWithMethod:(NSString *)method
                URLString:(NSString *)URLString
                  success:(void (^)(id JSONObject,NSURLResponse * response))success
                  failure:(void (^)(NSError * error))failure;
/**
 *  不带参数的GET请求
 *
 *  @param URLString
 *  @param success
 *  @param failure
 */
+ (NSURLSessionDataTask *)requestGetWithURLString:(NSString *)URLString
                        success:(void (^)(id JSONObject,NSURLResponse * response))success
                        failure:(void (^)(NSError * error))failure;
/**
 *  带参数的GET请求
 *
 *  @param URLString
 *  @param parameters
 *  @param success
 *  @param failure
 */
+ (NSURLSessionDataTask *)requestGetWithURLString:(NSString *)URLString
                     parameters:(id) parameters
                        success:(void (^)(id JSONObject,NSURLResponse * response))success
                        failure:(void (^)(NSError * error))failure;
/**
 *  不带参数的POST请求
 *
 *  @param URLString
 *  @param success
 *  @param failure
 */
+ (NSURLSessionDataTask *)requestPostWithURLString:(NSString *)URLString
                         success:(void (^)(id JSONObject,NSURLResponse * response))success
                         failure:(void (^)(NSError * error))failure;
/**
 *  带参数的POST请求
 *
 *  @param URLString
 *  @param parameters
 *  @param success
 *  @param failure
 */
+ (NSURLSessionDataTask *)requestPostWithURLString:(NSString *)URLString
                      parameters:(id) parameters
                         success:(void (^)(id JSONObject,NSURLResponse * response))success
                         failure:(void (^)(NSError * error))failure;

@end
