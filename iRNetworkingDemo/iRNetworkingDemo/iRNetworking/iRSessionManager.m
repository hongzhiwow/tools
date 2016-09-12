//
//  iRSessionManager.m
//  iRNetworkingDemo
//
//  Created by 王宏志 on 16/6/16.
//  Copyright © 2016年 iResearch.cloud. All rights reserved.
//

#import "iRSessionManager.h"
#import "iRURLRequestSerialization.h"

@interface iRSessionManager ()<NSURLSessionDelegate>

@property(nonatomic,strong) NSURLSession *session;

@property(nonatomic,strong) NSURLSessionConfiguration *sessionConfiguration;
@property(nonatomic,strong) NSOperationQueue *defaultOperationQueue;

@end

@implementation iRSessionManager

#pragma mark -
#pragma mark - public
+ (id)sharedManager
{
    static id singleInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [[[self class] alloc] initInstance];
    });
    return singleInstance;
}

- (NSURLSessionDataTask *)requestURLString:(NSString *)URLString
                                HTTPMethod:(NSString *)method
                                parameters:(id)parameters
                                   success:(void(^)(id JSONObject,NSURLResponse *  response))success
                                   failure:(void (^)(NSError * error))failure
{
    NSParameterAssert(URLString);
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    if ([method isEqual:@"GET"] && ((NSDictionary *)parameters).count > 0) {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[URLString stringByAppendingString:@"?"] stringByAppendingString: [iRURLRequestSerialization iRQueryStringFromParameters:parameters]]]];
    }
    if (((NSDictionary *)parameters).count > 0 && ![method isEqual:@"GET"]) {
        request.HTTPBody = [[iRURLRequestSerialization iRQueryStringFromParameters:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    }
    request.HTTPMethod = method;
    if (((NSDictionary *)parameters).count > 0) {
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //缓存请求
        NSCachedURLResponse *cacheRespone = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
        [[NSURLCache sharedURLCache] storeCachedResponse:cacheRespone forRequest:request];
        
        [self handleResponseData:data response:response error:error success:success failure:failure];
    }];
    [dataTask resume];
    return dataTask;
}

- (void)clearCookies
{
    //查看cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //遍历cookie
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie]; //删除cookie
    }
}

#pragma mark -
#pragma mark - setter / getter
- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration
                                                 delegate:self
                                            delegateQueue:self.defaultOperationQueue];
    }
    return _session;
}

- (NSURLSessionConfiguration *)sessionConfiguration
{
    if (!_sessionConfiguration) {
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //设置缓存策略
        _sessionConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        _sessionConfiguration.timeoutIntervalForRequest = 60;
        //设置缓存大小
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
        _sessionConfiguration.allowsCellularAccess = YES; //允许使用蜂窝网络
    }
    return _sessionConfiguration;
}

- (NSOperationQueue *)defaultOperationQueue
{
    if (!_defaultOperationQueue) {
        _defaultOperationQueue = [[NSOperationQueue alloc] init];
        _defaultOperationQueue.name = @"com.iResearch.cloud.netService";
        _defaultOperationQueue.maxConcurrentOperationCount = 10;
    }
    return _defaultOperationQueue;
}

#pragma mark -
#pragma mark - private

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Invalid Initialize Method" reason:@"Please Use SingleInstance" userInfo:nil];
    return nil;
}

- (instancetype)initInstance
{
    self = [super init];
    [self sessionConfiguration];
    [self defaultOperationQueue];
    [self session];
    return self;
}

- (void)handleResponseData:(NSData *)data
                  response:(NSURLResponse *)response
                     error:(NSError *)error
                   success:(void(^)(id JSONObject,NSURLResponse *  response))success
                   failure:(void (^)(NSError * error))failure
{
    
    if (error) {
        failure(error);
        return;
    }
    NSError *serializationError = nil;
    id serializationResult = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&serializationError];
    if (serializationError) {
        failure(serializationError);
        return;
    }
    if ([NSJSONSerialization isValidJSONObject:serializationResult]) {
        success(serializationResult,response);
    } else {
        failure([NSError errorWithDomain:@"Invalid JSON" code:90000000 userInfo:nil]);
    }
}

- (NSData *)getPublicKeyBitsFromKey:(SecKeyRef)givenKey {
    
    static const uint8_t publicKeyIdentifier[] = "com.iResearch.cloud.keyService";
    NSData *publicTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
    
    OSStatus sanityCheck = noErr;
    NSData * publicKeyBits = nil;
    
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Temporarily add key to the Keychain, return as data:
    NSMutableDictionary * attributes = [queryPublicKey mutableCopy];
    [attributes setObject:(__bridge id)givenKey forKey:(__bridge id)kSecValueRef];
    [attributes setObject:@YES forKey:(__bridge id)kSecReturnData];
    CFTypeRef result;
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) attributes, &result);
    if (sanityCheck == errSecSuccess) {
        publicKeyBits = CFBridgingRelease(result);
        
        // Remove from Keychain again:
        (void)SecItemDelete((__bridge CFDictionaryRef) queryPublicKey);
    }
    
    return publicKeyBits;
}

- (SecKeyRef)getPublicKeyWithCertificateData:(SecCertificateRef)myCertificate
{
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
    SecTrustResultType trustResult;
    if (status == noErr) {
        SecTrustEvaluate(myTrust, &trustResult);
    }
    SecKeyRef localPBKey = SecTrustCopyPublicKey(myTrust);
    CFRelease(myPolicy);
    CFRelease(myTrust);
    
    return localPBKey;
}

#pragma mark -
#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        do {
            //TODO::添加证书  设置SSL钢钉
            //读取本地证书
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Geo_Trust_Der" ofType:@"der"];
            NSData *certificateData = [NSData dataWithContentsOfFile:path];
            SecCertificateRef localCertificate =  SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef)certificateData);
            //这个方法后面会有代码
            SecKeyRef localKey = [self getPublicKeyWithCertificateData:localCertificate];
            SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
            
            NSMutableArray *serverCertificates = [NSMutableArray array];
            CFIndex certCount = SecTrustGetCertificateCount(serverTrust);
            for (CFIndex certIndex = 0; certIndex < certCount; certIndex++) {
                SecCertificateRef   thisCertificate;
                thisCertificate = SecTrustGetCertificateAtIndex(serverTrust, certIndex);
                [serverCertificates addObject:(__bridge id)thisCertificate];
            }
            SecCertificateRef serverCertificate = (__bridge SecCertificateRef)([serverCertificates lastObject]);
            /*
             *读取公钥，在这里为什么这么说呢 ，证书有很多东西可以读取，包括指纹等等，不知道？ 自行百度
             */
            SecKeyRef serverKey = [self getPublicKeyWithCertificateData:serverCertificate];
            //这里我们判断两个公钥的二进制数据是否一致
            if ([[self getPublicKeyBitsFromKey:localKey] isEqualToData:[self getPublicKeyBitsFromKey:serverKey]]) {
                NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            } else {
                [challenge.sender cancelAuthenticationChallenge:challenge];
            }
            CFRelease(serverKey);
            
            CFRelease(localKey);
            CFRelease(localCertificate);
        } while (0);
    }  
    
    
}


@end
