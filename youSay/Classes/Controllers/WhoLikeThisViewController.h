//
//  WhoLikeThisViewController.h
//  youSay
//
//  Created by Baban on 07/01/2016.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WhoLikeThisViewController;
@protocol LikeListDelegate <NSObject>
- (void) ListDismissedAfterClickProfile:(NSMutableDictionary*)data;
- (void) LikeListViewClosed:(NSString*)section;
@end

@interface WhoLikeThisViewController : GAITrackedViewController  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tblView;
@property (nonatomic, strong) NSString *say_id;
@property (nonatomic, readwrite) NSInteger section;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (nonatomic, weak) id <LikeListDelegate> delegate;


@end