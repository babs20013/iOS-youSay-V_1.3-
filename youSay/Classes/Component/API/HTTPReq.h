//
//  HTTPReq.h
//  DRB-Hicom
//
//  Created by Baban on 10/13/15.
//  Copyright (c) 2015 Simplifijohan. All rights reserved.
//

#import "IQHTTPService.h"
#import "Serializable.h"

@interface HTTPReq : IQHTTPService

typedef void (^HTTPReqObjectCompletion)(id  result, NSError *error);
typedef void (^HTTPReqDictionaryCompletion)(NSDictionary * result, NSError *error);

//Get
+(IQURLConnection*)getRequestWithPath:(NSString*)path class:(Class)klass parameters:(NSDictionary*)parameters  completionBlock:(HTTPReqObjectCompletion)completionBlock;

//Post Method
+(IQURLConnection*)postRequestWithPath:(NSString*)path class:(Class)klass parameters:(NSDictionary*)parameters  completionBlock:(HTTPReqObjectCompletion)completionBlock ;
+(IQURLConnection*)postRequestWithPath:(NSString*)path class:(Class)klass object:(id)requestObj  completionBlock:(HTTPReqObjectCompletion)completionBlock;
//Using custom server url
+(IQURLConnection*)postRequestWithPath:(NSString*)path serverUrl:(NSString*)url class:(Class)klass object:(id)requestObj  completionBlock:(HTTPReqObjectCompletion)completionBlock;


@end
