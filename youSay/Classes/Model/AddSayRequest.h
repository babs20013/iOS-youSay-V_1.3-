//
//  AddSayRequest.h
//  youSay
//
//  Created by Baban on 21/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serializable.h"

@interface AddSayRequest : Serializable
@property (nonatomic,strong) NSString *request;
@property (nonatomic,strong) NSString *user_id;
@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) NSString *profile_id_to_add_to;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,assign) NSInteger color;

@end