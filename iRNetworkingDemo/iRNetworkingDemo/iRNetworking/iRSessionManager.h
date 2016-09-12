//
//  iRSessionManager.h
//  iRNetworkingDemo
//
//  Created by 王宏志 on 16/6/16.
//  Copyright © 2016年 iResearch.cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iRSessionManager : NSObject

+ (id)sharedManager;

- (NSURLSessionDataTask *)requestURLString:(NSString *)URLString
                                HTTPMethod:(NSString *)method
                                parameters:(id)parameters
                                   success:(void(^)(id JSONObject,NSURLResponse *  response))success
                                   failure:(void (^)(NSError * error))failure;

- (void)clearCookies;

@end
