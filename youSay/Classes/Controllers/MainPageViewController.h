//
//  MainPageViewController.h
//  youSay
//
//  Created by Baban on 06/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewPagerController.h"
#import "ProfileViewController.h"
#import "FeedViewController.h"
#import "FriendModel.h"
#import "NotificationViewController.h"

@interface MainPageViewController : ViewPagerController<ViewPagerDataSource, ViewPagerDelegate>
@property (nonatomic,strong) NSDictionary * profileDictionary;
@property (nonatomic,strong) NSDictionary * colorDictionary;
@property (nonatomic, strong) NSMutableArray * saysArray;
@property (nonatomic, readwrite) BOOL isFriendProfile;
@property (nonatomic, readwrite) BOOL isFromFeed;
@property (nonatomic, readwrite) BOOL isAddSay;
@property (nonatomic, strong) NSString *requestedID;
@property (nonatomic, strong) NSString *sayID;
@property (nonatomic, strong) ProfileOwnerModel *profileModel;
@property (nonatomic, strong) FriendModel *friendModel;
@end
