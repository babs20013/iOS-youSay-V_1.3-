//
//  FriendModel.h
//  youSay
//
//  Created by Baban on 05/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendModel : NSObject
@property (nonatomic,strong) NSString *Name;
@property (nonatomic,strong) NSString *ProfileImage;
@property (nonatomic,strong) NSString *CoverImage;
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,assign) BOOL isNeedProfile;


@end
