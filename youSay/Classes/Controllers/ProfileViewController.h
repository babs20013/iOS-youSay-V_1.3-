//
//  ProfileViewController.h
//  youSay
//
//  Created by Baban on 07/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharmView.h"
#import "SelectCharmsViewController.h"
#import "AddNewSayViewController.h"
#import "WhoLikeThisViewController.h"
#import "FriendModel.h"
#import "ProfileTableViewCell.h"

@interface ProfileViewController : GAITrackedViewController <UITextViewDelegate, FBSDKAppInviteDialogDelegate, CharmChartDelegate, UIScrollViewDelegate, CharmSelectionDelegate, UIGestureRecognizerDelegate, AddNewSayDelegate, LikeListDelegate, FBSDKSharingDelegate, UIAlertViewDelegate>

@property (nonatomic,strong) ProfileOwnerModel *profileModel;
@property (nonatomic, strong) FriendModel *friendModel;
@property (nonatomic,strong) NSDictionary * profileDictionary;
@property (nonatomic,strong) NSDictionary * colorDictionary;
@property (nonatomic, strong) NSMutableArray * saysArray;
@property (nonatomic, strong) NSMutableArray * charmsArray;
@property (nonatomic, strong) IBOutlet UITextField * txtSearch;
@property (nonatomic, strong) IBOutlet UIView * searchView;
@property (nonatomic, readwrite) BOOL isFriendProfile;
@property (nonatomic, readwrite) BOOL isFromFeed;
@property (nonatomic, readwrite) BOOL isRequestingProfile;
@property (nonatomic, readwrite) BOOL isSameTab;
@property (nonatomic, readwrite) BOOL isAddSay;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *btnViewConstraint;
@property (nonatomic, strong) NSString *requestedID;
@property (nonatomic, strong) NSString *saysID;
@property (nonatomic, strong) UIButton *btnAddSay;

- (void) refreshPage:(NSNotification *)notif;
- (void)requestProfile:(NSString*)IDrequested;
- (void)requestCreateProfile:(FriendModel*)friendModel;
- (IBAction)btnShareProfileToFacebookClicked:(id)sender;

- (void)profileClicked:(id)sender;
- (void)profileClickeds:(CGPoint)p;
- (void)profileClickedss:(CGPoint)p;
- (void)ratesClicked:(CGPoint)p;

- (void)profileClickedsss:(id)sender;

- (IBAction)btnShareProfileClicked:(id)sender;
//TODO
- (void)profileCircularImageClicked:(id)sender Frame:(CGRect)frame;
- (void)ratesClickedabc:(id)sender Frame:(CGRect)frame ;

-(void)loadSharePopUp:(NSString *)imageName Title:(NSString *)title SubTitle:(NSString *)subTitle State:(BOOL)state;
-(void)closeButtonAppear;
-(void)loadFirstTimePopUp;
-(void)closeButtonAppear:(BOOL)isRating;

- (void)profileClickeded:(id)sender Frame:(CGRect)frame;
-(void)EnableEditingMode;
-(void)StartRateMode;
-(void)EnableCharmRateMode;
@end