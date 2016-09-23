//
//  FeedViewController.h
//  youSay
//
//  Created by Baban on 26/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedViewController.h"
#import "WhoLikeThisViewController.h"
#import "AddNewSayViewController.h"

@interface FeedViewController : GAITrackedViewController  <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, LikeListDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) NSMutableArray *arrayFeed;

- (void) refreshFeed:(NSNotification *)notif;


@end