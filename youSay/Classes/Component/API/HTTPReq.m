//
//  HTTPReq.m
//  DRB-Hicom
//
//  Created by Baban on 10/13/15.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "HTTPReq.h"
#import "url.h"

#define kDefaultContentType @"application/json"
@implementation HTTPReq

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.logEnabled = YES;
        self.parameterType = IQRequestParameterTypeApplicationXWwwFormUrlEncoded;
        self.serverURL = HTTP_URL_SERVER;
    }
    return self;
}


+(IQURLConnection*)getRequestWithPath:(NSString*)path class:(Class)klass parameters:(NSDictionary*)parameters  completionBlock:(HTTPReqObjectCompletion)completionBlock {
    
    HTTPReq *req = [[HTTPReq alloc]init];
    return [req requestWithPath:path httpMethod:kIQHTTPMethodGET parameter:parameters completionHandler:^(NSDictionary *result, NSError *error){
        id obj = result;
        if ([klass isSubclassOfClass:[Serializable class]]) {
            if ([result isKindOfClass:[NSArray class]]) {
                NSArray *arr = (NSArray*)result;
                obj = [Serializable arrayObjectFromArray:arr withObjectClass:klass error:&error];
            }
            else if ([result isKindOfClass:[NSDictionary class]]) {
                obj = [[klass alloc] initWithDictionary:result error:&error];
            }
        }
        completionBlock(obj,error);
    }];
}

+(IQURLConnection*)postRequestWithPath:(NSString*)path class:(Class)klass parameters:(NSDictionary*)parameters  completionBlock:(HTTPReqObjectCompletion)completionBlock {
    HTTPReq *req = [[HTTPReq alloc]init];
    req.parameterType = IQRequestParameterTypeApplicationJSON;
    req.defaultContentType  = kDefaultContentType;
    
    return [req requestWithPath:path httpMethod:kIQHTTPMethodPOST parameter:parameters completionHandler:^(NSDictionary *result, NSError *error){
        id obj = result;
        if ([klass isSubclassOfClass:[Serializable class]]) {
            if ([result isKindOfClass:[NSArray class]]) {
                NSArray *arr = (NSArray*)result;
                obj = [Serializable arrayObjectFromArray:arr withObjectClass:klass error:&error];
            }
            else if ([result isKindOfClass:[NSDictionary class]]) {
                obj = [[klass alloc] initWithDictionary:result error:&error];
            }
        }
        
        completionBlock(obj,error);
    }];
}

+(IQURLConnection*)postRequestWithPath:(NSString*)path class:(Class)klass object:(id)requestObj  completionBlock:(HTTPReqObjectCompletion)completionBlock {
    NSDictionary *parameters = nil;
    if ([requestObj isKindOfClass:[Serializable class]]) {
        parameters = [requestObj toDictionary];
    }
    else if ([requestObj isKindOfClass:[NSDictionary class]]){
        parameters = (NSDictionary*)requestObj;
    }
    return [HTTPReq postRequestWithPath:path class:klass parameters:parameters completionBlock:completionBlock];
}

+(IQURLConnection*)postRequestWithPath:(NSString*)path serverUrl:(NSString*)url class:(Class)klass parameters:(NSDictionary*)parameters  completionBlock:(HTTPReqObjectCompletion)completionBlock {
    HTTPReq *req = [[HTTPReq alloc]init];
    req.parameterType = IQRequestParameterTypeApplicationJSON;
    req.defaultContentType  = kDefaultContentType;
    req.serverURL = url;
    
    return [req requestWithPath:path httpMethod:kIQHTTPMethodPOST parameter:parameters completionHandler:^(NSDictionary *result, NSError *error){
        id obj = result;
        if ([klass isSubclassOfClass:[Serializable class]]) {
            if ([result isKindOfClass:[NSArray class]]) {
                NSArray *arr = (NSArray*)result;
                obj = [Serializable arrayObjectFromArray:arr withObjectClass:klass error:&error];
            }
            else if ([result isKindOfClass:[NSDictionary class]]) {
                obj = [[klass alloc] initWithDictionary:result error:&error];
            }
        }
        
        completionBlock(obj,error);
    }];
}

+(IQURLConnection*)postRequestWithPath:(NSString*)path serverUrl:(NSString*)url class:(Class)klass object:(id)requestObj  completionBlock:(HTTPReqObjectCompletion)completionBlock {
    NSDictionary *parameters = nil;
    if ([requestObj isKindOfClass:[Serializable class]]) {
        parameters = [requestObj toDictionary];
    }
    else if ([requestObj isKindOfClass:[NSDictionary class]]){
        parameters = (NSDictionary*)requestObj;
    }
    return [HTTPReq postRequestWithPath:path serverUrl:url class:klass parameters:parameters completionBlock:completionBlock];
}
@end
