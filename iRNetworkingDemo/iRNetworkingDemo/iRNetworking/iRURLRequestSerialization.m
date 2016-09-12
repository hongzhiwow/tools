//
//  iRURLRequestSerialization.m
//  iRNetworkingDemo
//
//  Created by 王宏志 on 16/6/16.
//  Copyright © 2016年 iResearch.cloud. All rights reserved.
//

#import "iRURLRequestSerialization.h"

@interface iRURLRequestSerialization ()

@property (readwrite, nonatomic, strong) id  value;
@property (readwrite, nonatomic, strong) id  field;

@end

@implementation iRURLRequestSerialization

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (self) {
        _field = field;
        _value = value;

    }
    return self;
}

#pragma mark -  handle param （从AFNetworking 偷过来的）

FOUNDATION_EXPORT NSArray * iRQueryStringPairsFromDictionary(NSDictionary *dictionary);
FOUNDATION_EXPORT NSArray * iRQueryStringPairsFromKeyAndValue(NSString *key, id value);

+ (NSString *)iRQueryStringFromParameters:(NSDictionary *)parameters
{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (iRURLRequestSerialization *pair in iRQueryStringPairsFromDictionary(parameters)) {
        
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * iRQueryStringPairsFromDictionary(NSDictionary *dictionary)
{
    return iRQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * iRQueryStringPairsFromKeyAndValue(NSString *key, id value)
{
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:iRQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:iRQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:iRQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[iRURLRequestSerialization alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}


static NSString * iRPercentEscapedStringFromString(NSString *string)
{
    static NSString * const kiRCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kiRCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kiRCharactersGeneralDelimitersToEncode stringByAppendingString:kiRCharactersSubDelimitersToEncode]];
    
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(string.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

- (NSString *)URLEncodedStringValue
{
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return iRPercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", iRPercentEscapedStringFromString([self.field description]), iRPercentEscapedStringFromString([self.value description])];
    }
}

@end
