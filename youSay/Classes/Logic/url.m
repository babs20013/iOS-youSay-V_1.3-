//
//  url.m
//  youSay
//
//  Created by Baban on 10/11/15.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "url.h"

NSString * HTTP_STAGING                          = @"https://yousayweb.com/yousay_dev/backend/api/";
NSString * HTTP_PRODUCTION                       = @"https://yousayweb.com/yousay/backend/api/";
NSString * HTTP_URL_SERVER                       = @"https://yousayweb.com/yousay/backend/api/";


//@"https://sharkbyte.co.il/yousay/backend/api/";
//@"https://yousayweb.com/yousay_dev/backend/api/apiclient.php";
//@"https://yousayweb.com/yousay_dev/backend/api/index.php";
//@"https://yousayweb.com/yousay/backend/api/";

static URL *instance = nil;

@implementation URL : NSObject

+ (void)setHTTPServer {
    if ([HTTP_URL_SERVER isEqualToString:HTTP_PRODUCTION]) {
        HTTP_URL_SERVER = HTTP_STAGING;
    }
    else {
        HTTP_URL_SERVER = HTTP_PRODUCTION;
    }
}


@end
