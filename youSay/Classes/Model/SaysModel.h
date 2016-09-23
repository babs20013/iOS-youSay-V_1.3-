//
//  SaysModel.h
//  youSay
//
//  Created by Baban on 11/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaysModel : NSObject
@property (nonatomic,strong) NSString *say_id;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) NSString *say_color;
@property (nonatomic,strong) NSString *by;
@property (nonatomic,strong) NSString *user_id;
@property (nonatomic,strong) NSString *profile_image;
@property (nonatomic,strong) NSString *like_count;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *liked;
@property (nonatomic,readwrite) BOOL isHide;
@end