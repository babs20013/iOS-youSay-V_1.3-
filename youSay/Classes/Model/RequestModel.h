//
//  RequestModel.h
//  youSay
//
//  Created by Baban on 09/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serializable.h"

@interface RequestModel : Serializable
@property (nonatomic,strong) NSString *request;
@property (nonatomic,strong) NSString *authorization_id;
@property (nonatomic,strong) NSString *authority_type;
@property (nonatomic,strong) NSString *authority_access_token;
@property (nonatomic,strong) NSString *app_name;
@property (nonatomic,strong) NSString *app_version;
@property (nonatomic,strong) NSString *device_info;

@end