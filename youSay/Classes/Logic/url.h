//
//  url.h
//  youSay
//
//  Created by Baban on 10/11/15.
//  Copyright © 2015 macbokpro. All rights reserved.
//
#import <Foundation/Foundation.h>

extern NSString * HTTP_STAGING;
extern NSString * HTTP_PRODUCTION;
extern NSString * HTTP_URL_SERVER;

@interface URL : NSObject{
	
}

+ (void)setHTTPServer;

@end