//
//  ProfileViewController.m
//  youSay
//
//  Created by Baban on 07/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "ProfileTableViewCell.h"
#import "PeopleSayTableViewCell.h"
#import "ProfileOwnerModel.h"
#import "constant.h"
#import "url.h"
#import "HTTPReq.h"
#import "SlideNavigationController.h"
#import "CommonHelper.h"
#import "UIImageView+Networking.h"
#import "ProfileOwnerModel.h"
#import "RequestModel.h"
#import "CharmChart.h"
#import "AddNewSayViewController.h"
#import "ReportSayViewController.h"
#import <Social/Social.h>
#import "CustomActivityProvider.h"
#import "SearchViewController.h"
#import "MGInstagram.h"
#import "AQSFacebookMessengerActivity.h"
#import "UITooltip.h"
#import "CustomePopOverVC.h"
#import "ARSPopover.h"
#import "FirstTimePopUpViewController.h"
#import "SharePopUpViewController.h"

#define kColor10 [UIColor colorWithRed:241.0/255.0 green:171.0/255.0 blue:15.0/255.0 alpha:1.0]
#define kColor20 [UIColor colorWithRed:243.0/255.0 green:183.0/255.0 blue:63.0/255.0 alpha:1.0]
#define kColor30 [UIColor colorWithRed:186.0/255.0 green:227.0/255.0 blue:86.0/255.0 alpha:1.0]
#define kColor40 [UIColor colorWithRed:82.0/255.0 green:209.0/255.0 blue:131.0/255.0 alpha:1.0]
#define kColor50 [UIColor colorWithRed:108.0/255.0 green:196.0/255.0 blue:140.0/255.0 alpha:1.0]
#define kColor60 [UIColor colorWithRed:68.0/255.0 green:188.0/255.0 blue:168.0/255.0 alpha:1.0]
#define kColor70 [UIColor colorWithRed:47.0/255.0 green:181.0/255.0 blue:160.0/255.0 alpha:1.0]
#define kColor80 [UIColor colorWithRed:53.0/255.0 green:184.0/255.0 blue:202.0/255.0 alpha:1.0]
#define kColor90 [UIColor colorWithRed:31.0/255.0 green:175.0/255.0 blue:197.0/255.0 alpha:1.0]
#define kColor100 [UIColor colorWithRed:1.0/255.0 green:172.0/255.0 blue:197.0/255.0 alpha:1.0]
#define kColorDefault [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0]

#define kColorLabel [UIColor colorWithRed:27.0/255.0 green:174.0/255.0 blue:198.0/255.0 alpha:1.0]
#define kColorBG [UIColor colorWithRed:180.0/255.0 green:185.0/255.0 blue:187.0/255.0 alpha:1.0]

#define kColorSearch [UIColor colorWithRed:42.0/255.0 green:180.0/255.0 blue:202.0/255.0 alpha:1.0]

#define shareSayTag 55
#define shareAfterRateTag   56

#define IS_IPHONE_4 [[UIScreen mainScreen] bounds].size.height == 480.0f
#define IS_IPHONE_5 [[UIScreen mainScreen] bounds].size.height == 568.0f
#define IS_IPHONE_6 [[UIScreen mainScreen] bounds].size.height == 667.0f
#define IS_IPHONE_6PLUS [[UIScreen mainScreen] bounds].size.height == 736.0f

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate,ARSPopoverDelegate> {
    ProfileOwnerModel *friendsProfileModel;
    NSMutableDictionary *dictHideSay;
    UIImageView *imgViewRank;
    UIImageView *imgViewPopularity;
    ChartState chartState;
    CharmView *charmView;
    WhoLikeThisViewController *likelistVC;
    
    NSInteger charmIndexRow;
    NSMutableArray *arrayFilteredCharm;
    NSMutableArray *arrayOriginalCharm;
    NSMutableArray *arrActiveCharm;
    BOOL isAfterChangeCharm;
    BOOL isScrollBounce;
    SelectCharmsViewController *charmsSelection;
    BOOL isFirstLoad;
    BOOL isAfterCharm;
    BOOL isAfterAddNewSay;
    NSString *profileShared;
    NSString *sayShared;
    BOOL isProfileShared;
    BOOL isAfterShareFB;
    BOOL isAfterRate;
    BOOL displayMoreMenu;
    
    BOOL tooltipIsVisible;
    
    NSString *totalScoreAfterRate;
    
    BOOL editState,rateState;
}
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *viewSkip;
@property (nonatomic, weak) IBOutlet UIView *viewSkipBox;


@end

@implementation ProfileViewController

@synthesize requestedID;
@synthesize profileModel;
@synthesize profileDictionary;
@synthesize colorDictionary;
@synthesize saysArray;
@synthesize charmsArray;
@synthesize isFriendProfile;
@synthesize btnAddSay;
@synthesize saysID;

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
#pragma  mark ToolTip Methods from Pop Up Controller Close Button
-(void)closeButtonAppear:(BOOL)isRating {
    
    NSUserDefaults *firstTimeDefaults = [NSUserDefaults standardUserDefaults];
    //BOOL isNOTFirstTimeOnFriendProfile = [firstTimeDefaults boolForKey:@"FRIENDPROFILE_NOT_FIRSTTIME"];
    
    if (!isFriendProfile) {
        //Self Profile
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"SelfProfileClosePopUp"] && isRating) {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SelfProfileClosePopUp"];
            
            
            
            //TOOLTIP - Own profile Tips
            //1. Appear on first time only
            NSUserDefaults *firstTimeDefaults = [NSUserDefaults standardUserDefaults];
            
            //   BOOL isNOTFirstTime = [firstTimeDefaults boolForKey:@"OWNPROFILE_NOT_FIRSTTIME"];
            
            //if (isNOTFirstTimeOnFriendProfile) {
            tooltipIsVisible = YES;
            UIView *background = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            [background setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            if (!window)
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            [[[window subviews] objectAtIndex:0] addSubview:background];
            
            
            UITooltip *tip3 = [[UITooltip alloc]initWithFrame:CGRectMake((background.frame.size.width-150)/2, 63, 150, 72)];
            tip3.tipArrow = TipArrowTopLeft;
            tip3.tooltipText = @"Type your friend’s name to find their profile";
            [background addSubview:tip3];
            
            
            [tip3 onButtonTap:^{
                [tip3 closeToolTip];
                [background removeFromSuperview];
                tooltipIsVisible = NO;
                [firstTimeDefaults setBool:YES forKey:@"OWNPROFILE_NOT_FIRSTTIME"];
            }];
        }
    }else{
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FriendsProfileClosePopUp"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FriendsProfileClosePopUp"];
            
            //if(isFriendProfile && !isNOTFirstTimeOnFriendProfile && !tooltipIsVisible && friendsProfileModel){
            
            //  if (isNOTFirstTimeOnFriendProfile) {
            tooltipIsVisible = YES;
            UIView *background = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            [background setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            if (!window)
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            [[[window subviews] objectAtIndex:0] addSubview:background];
            
            CGFloat tip2y =  355;
            CGFloat tip2x =  70;
            
            if (IS_IPHONE_6) {
                tip2y = 495;
                tip2x = 100;
            }
            else if(IS_IPHONE_5){
                tip2y = 435;
                tip2x = 60;
            }
            else if(IS_IPHONE_6PLUS){
                tip2y = 525;
                tip2x = 120;
            }
            
            UITooltip *tip2 = [[UITooltip alloc]initWithFrame:CGRectMake(tip2x, tip2y, 170, 84)];
            tip2.tipArrow = TipArrowMiddleRight;
            tip2.tooltipText = [NSString stringWithFormat:@"Click on the + icon to write something awesome about %@", friendsProfileModel.Name];
            [tip2 showToolTip:background];
            
            
            [tip2 onButtonTap:^{
                [tip2 closeToolTip];
                [background removeFromSuperview];
                tooltipIsVisible = NO;
                [firstTimeDefaults setBool:YES forKey:@"FRIENDPROFILE_NOT_FIRSTTIME"];
            }];
        }
    }
    
    
}
#pragma  mark Default Methods
- (void)viewWillAppear:(BOOL)animated {
    dictHideSay = [[NSMutableDictionary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"myNotification"
                                               object:nil];
}


- (void)receiveNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"myNotification"]) {
        [self StartRateMode];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if ([dictHideSay allKeys].count >0) {
        [self requestHideSay];
    }
}
#pragma mark Custome PopOverOnclied Methods
- (void)profileClickeded:(id)sender Frame:(CGRect)frame {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    CustomePopOverVC *modalVC = (CustomePopOverVC *)[storyboard instantiateViewControllerWithIdentifier:@"CustomePopOverVC"];
    
    modalVC.parent = self;
    modalVC.objButton = sender;
    modalVC.x = frame.origin.x;
    modalVC.y = frame.origin.y;
    if (!isFriendProfile) {
        modalVC.strTitle = [NSString stringWithFormat:@"This is you"];
        modalVC.strDesc = @"Share to become more popular";
    }else{
        modalVC.strTitle = [NSString stringWithFormat:@"This is %@",[profileDictionary objectForKey:@"first_name"]];
        modalVC.strDesc = @"Let them know about this";
    }
    
    modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [self presentViewController:modalVC animated:NO completion:nil];
}
//- (void)profileClickeds:(CGPoint)p  {profileCircularImageClicked
- (void)profileCircularImageClicked:(id)sender Frame:(CGRect)frame{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    CustomePopOverVC *modalVC = (CustomePopOverVC *)[storyboard instantiateViewControllerWithIdentifier:@"CustomePopOverVC"];
    
    modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    modalVC.parent = self;
    
    modalVC.objButton = sender;
    UIButton *btn = (UIButton *)sender;
    
    modalVC.x = frame.origin.x;
    modalVC.y = frame.origin.y+btn.frame.size.height/2+30;
    
    if (!isFriendProfile) {
        modalVC.strTitle = [NSString stringWithFormat:@"This is how popular you are"];
        modalVC.strDesc = @"Share to become more popular";
    }else{//Popularity level
        modalVC.strTitle = [NSString stringWithFormat:@"Popularity level"];//@"This is how popular %@ is",[profileDictionary objectForKey:@"first_name"]];
        modalVC.strDesc = @" Help them to become more popular";
    }
    
    [self presentViewController:modalVC animated:NO completion:nil];
}

- (void)ratesClickedabc:(id)sender Frame:(CGRect)frame{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    CustomePopOverVC *modalVC = (CustomePopOverVC *)[storyboard instantiateViewControllerWithIdentifier:@"CustomePopOverVC"];
    
    modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    modalVC.parent = self;
    modalVC.objButton = sender;
    
    UIButton *btn = (UIButton *)sender;
    
    modalVC.x = frame.origin.x;
    modalVC.y = frame.origin.y+btn.frame.size.height/2;
    
    if (!isFriendProfile) {
        modalVC.strTitle = [NSString stringWithFormat:@"%@ people rated you anonymously",[profileDictionary objectForKey:@"num_users_rated"]];
        modalVC.strDesc = @"Share this to get more rates";
    }else{
        modalVC.strTitle = [NSString stringWithFormat:@" %@ people rated anonymously",[profileDictionary objectForKey:@"num_users_rated"]];//,[profileDictionary objectForKey:@"first_name"]
        modalVC.strDesc = [NSString stringWithFormat:@"Let them know about this"];//Share %@’s profile with them",[profileDictionary objectForKey:@"first_name"]
    }
    
    [self presentViewController:modalVC animated:NO completion:nil];
}
-(void)loadFirstTimePopUp{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    FirstTimePopUpViewController *modalVC = (FirstTimePopUpViewController *)[storyboard instantiateViewControllerWithIdentifier:@"FirstTimePopUpViewController"];
    modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (!isFriendProfile) {
        modalVC.strTitle = @"Your profile";
        modalVC.strDesc = @" Rate yourself and find out how others rated you";
    }else{
        modalVC.strTitle = [NSString stringWithFormat:@"This is %@",[profileDictionary objectForKey:@"first_name"]];
        modalVC.strDesc = @"Rate them anonymously now";
    }
    
    [self presentViewController:modalVC animated:NO completion:nil];
}

-(void)loadSharePopUp:(NSString *)imageName Title:(NSString *)title SubTitle:(NSString *)subTitle State:(BOOL)state{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SharePopUpViewController *modalVC = (SharePopUpViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SharePopUpViewController"];
    modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    modalVC.parent = self;
    modalVC.chartState = state;
    modalVC.strTitle = title;
    modalVC.strSubTitle = subTitle;
    modalVC.strImageName = imageName;
    [self presentViewController:modalVC animated:NO completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // [self loadSharePopUp];
    //[self loadFirstTimePopUp];
    self.screenName = @"Profile";
    isFirstLoad = YES;
    isAfterCharm = NO;
    chartState = ChartStateDefault;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    self.viewSkipBox.layer.cornerRadius = 0.015 * self.viewSkipBox.bounds.size.width;
    self.viewSkipBox.layer.masksToBounds = YES;
    self.viewSkipBox.layer.borderWidth = 1;
    self.viewSkipBox.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
    
    NSString *completeUrl=[NSString stringWithFormat:@"https://graph.facebook.com/"];
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    if (isFriendProfile == NO && [[[AppDelegate sharedDelegate].colorDict allKeys] count] == 0) {
    //        if ([defaults objectForKey:@"yousayuserid"] && [defaults objectForKey:@"yousaytoken"] ) {
    //            profileModel = [[ProfileOwnerModel alloc]init];
    //            profileModel.UserID = [defaults stringForKey:@"yousayuserid"];
    //            profileModel.token = [defaults stringForKey:@"yousaytoken"];
    //            [AppDelegate sharedDelegate].profileOwner = profileModel;
    //            [self requestProfile:[defaults objectForKey:@"yousayuserid"]];
    //        }
    //
    //        else {
    //
    //        }
    //    }
    //    else
    if ([[[AppDelegate sharedDelegate].ownerDict allKeys] count] == 0) {
        
        [self loadFaceBookData:completeUrl param:@{@"fields":@"",@"access_token":[FBSDKAccessToken currentAccessToken].tokenString}];
    }
    else if ([[AppDelegate sharedDelegate].colorDict allKeys].count > 0) {
        if ([[profileDictionary allKeys] count] == 0) {
            profileDictionary = [AppDelegate sharedDelegate].ownerDict;
            [self.tableView reloadData];
        }
    }
    
    isAfterChangeCharm = NO;
    CharmChart *chart = [[CharmChart alloc]init];
    chart.delegate = self;
    
    arrayOriginalCharm = [[NSMutableArray alloc]init];
    
    dictHideSay = [[NSMutableDictionary alloc] init];
    profileModel = [AppDelegate sharedDelegate].profileOwner;
    imgViewRank = [[UIImageView alloc]init];
    imgViewPopularity = [[UIImageView alloc]init];
    
    saysArray = [[NSMutableArray alloc] initWithArray:[profileDictionary valueForKey:@"says"]];
    charmsArray = [[NSMutableArray alloc]init];
    charmsArray = [profileDictionary valueForKey:@"charms"];
    
    
    UIImageView *imgMagnifyingGlass = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 15, 15)];
    imgMagnifyingGlass.image = [UIImage imageNamed:@"search"];
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [leftView addSubview:imgMagnifyingGlass];
    self.txtSearch.textColor = [UIColor whiteColor];
    self.txtSearch.leftView = leftView;
    self.txtSearch.leftViewMode = UITextFieldViewModeAlways;
    self.txtSearch.layer.cornerRadius = round(self.txtSearch.frame.size.height / 2);
    self.txtSearch.layer.borderWidth = 1;
    self.txtSearch.layer.borderColor = kColorSearch.CGColor;
    self.txtSearch.autocorrectionType = UITextAutocorrectionTypeNo;
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Search your friends" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.txtSearch.attributedPlaceholder = str;
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    
    btnAddSay = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-100, 485, 60, 60)];
    
    if (IS_IPHONE_4) {
        btnAddSay.frame = CGRectMake(self.tableView.frame.size.width-60, 350, 60, 60);
    }
    else if (IS_IPHONE_5) {
        btnAddSay.frame = CGRectMake(self.tableView.frame.size.width-70, 420, 80, 80);
    }
    else if (IS_IPHONE_6) {
        btnAddSay.frame = CGRectMake(self.tableView.frame.size.width-30, 478, 80, 80);
    }
    else if (IS_IPHONE_6PLUS) {
        btnAddSay.frame = CGRectMake(self.tableView.frame.size.width, 513, 80, 80);
    }
    
    [btnAddSay setImage:[UIImage imageNamed:@"AddButton"] forState:UIControlStateNormal];
    [btnAddSay setTitle:@"Add" forState:UIControlStateNormal];
    [btnAddSay addTarget:self action:@selector(btnAddSayTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnAddSay setHidden:YES];
    [self.view addSubview:btnAddSay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPage:)
                                                 name:@"notification"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Load Login credential

-(void)loadFaceBookData:(NSString*)fbURLString param:(NSDictionary*)param
{
    AFHTTPClient * client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:fbURLString]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"text/html"];
    [client getPath:@"me"
         parameters:param
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                NSString* facebook_id=@"";
                
                profileModel = [[ProfileOwnerModel alloc]init];
                profileModel.Name = [resultDic valueForKey:@"name"];
                profileModel.UserID = [resultDic objectForKey:@"user_id"];
                profileModel.FacebookToken = [FBSDKAccessToken currentAccessToken].tokenString;
                profileModel.FacebookID = [resultDic objectForKey:@"id"];
                
                //--Get profile picture
                NSDictionary *pictureDict = [[resultDic objectForKey:@"picture"] objectForKey:@"data"];
                NSString *pictureURL = [pictureDict objectForKey:@"url"];
                profileModel.ProfileImage = pictureURL;
                
                //--Get cover picture
                NSString *coverURL = [[resultDic objectForKey:@"cover"] objectForKey:@"source"];
                profileModel.CoverImage = coverURL;
                
                if([resultDic valueForKey:@"id"]&&[[resultDic valueForKey:@"id"]isKindOfClass:[NSString class]]){
                    facebook_id=[resultDic valueForKey:@"id"];
                }
                [AppDelegate sharedDelegate].profileOwner = profileModel;
                [self requestLogin];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Whoops!", nil) message:NSLocalizedString(@"It didn’t login.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Please try again!", nil) otherButtonTitles:nil, nil]show];
                [self logout];
            }];
}


- (void)requestHideSay {
    NSArray *keys = [dictHideSay allKeys];
    NSString *sayID = @"";
    for (int i = 0; i < keys.count; i++) {
        NSDictionary *dict = [saysArray objectAtIndex:i];
        if (i < keys.count-1) {
            sayID = [sayID stringByAppendingString:[NSString stringWithFormat:@"%@,",[dict objectForKey:@"say_id"]]];
        }
        else {
            sayID = [sayID stringByAppendingString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"say_id"]]];
        }
        
    }
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_HIDE_SAY forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token]  forKey:@"token"];
    [dictRequest setObject:sayID forKey:@"say_id"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                [dictHideSay removeAllObjects];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
        }
        else{
            
        }
        HideLoader();
    }];
}

- (void)requestLogin {
    ShowLoader();
    RequestModel *loginReq = [[RequestModel alloc]init];
    loginReq.request = REQUEST_LOGIN;
    loginReq.authorization_id = [[AppDelegate sharedDelegate].profileOwner FacebookID];
    loginReq.authority_type = AUTHORITY_TYPE_FB;
    loginReq.authority_access_token = [FBSDKAccessToken currentAccessToken].tokenString;
    loginReq.app_name = APP_NAME;
    loginReq.app_version = APP_VERSION;
    loginReq.device_info =  [[UIDevice currentDevice] model];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:loginReq completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                profileModel.UserID = [dictResult valueForKey:@"user_id"];
                profileModel.token = [dictResult valueForKey:@"token"];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[dictResult valueForKey:@"user_id"] forKey:@"yousayuserid"];
                [defaults setObject:[dictResult valueForKey:@"token"] forKey:@"yousaytoken"];
                [defaults setObject:[dictResult valueForKey:@"user_id"] forKey:@"yousayid"];
                
                [AppDelegate sharedDelegate].profileOwner = profileModel;
                profileDictionary = [result objectForKey:@"profile"];
                [AppDelegate sharedDelegate].ownerDict = profileDictionary;
                isFriendProfile = NO;
                requestedID = [dictResult valueForKey:@"user_id"];
                [AppDelegate sharedDelegate].isFirstLoad = NO;
                
                [self requestSayColor];
                if ([AppDelegate sharedDelegate].isNewToken == YES) {
                    [self requestAddUserDevice];
                }
                
                [AppDelegate sharedDelegate].num_of_new_notifications = [[dictResult valueForKey:@"num_of_new_notifications"] integerValue];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kNotificationUpdateNotification object:nil];
                
                NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                                                                     action:@"login"
                                                                                      label:@"login"
                                                                                      value:nil] build];
                [[GAI sharedInstance].defaultTracker send:event];
                [[GAI sharedInstance] dispatch];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
            
            
        }
        else{
            
        }
        HideLoader();
    }];
}

- (void)requestProfile:(NSString*)IDrequested {
    _isRequestingProfile = YES;
    isFirstLoad = NO;
    isAfterRate = NO;
    ShowLoader();
    if (profileModel == nil) {
        profileModel = [AppDelegate sharedDelegate].profileOwner;
    }
    if (IDrequested == nil) {
        IDrequested = profileModel.UserID;
        requestedID = profileModel.UserID;
    }
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_GET_PROFILE forKey:@"request"];
    [dictRequest setObject:profileModel.UserID forKey:@"user_id"];
    [dictRequest setObject:profileModel.token forKey:@"token"];
    [dictRequest setObject:IDrequested forKey:@"requested_user_id"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        HideLoader();
        _isRequestingProfile = NO;
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                profileDictionary = [dictResult objectForKey:@"profile"];
                [AppDelegate sharedDelegate].ownerDict = profileDictionary;
                saysArray = [[NSMutableArray alloc] initWithArray:[profileDictionary valueForKey:@"says"]];
                charmsArray = [profileDictionary valueForKey:@"charms"];
                isFriendProfile = YES;
                requestedID = [profileDictionary objectForKey:@"id"];
                if ([[[AppDelegate sharedDelegate].profileOwner UserID] isEqualToString:IDrequested]) {
                    isFriendProfile = NO;
                    [[AppDelegate sharedDelegate] profileOwner].Name = [profileDictionary objectForKey:@"name"];
                }
                isAfterChangeCharm = NO;
                //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                [self.tableView reloadData];
                if  ([[[AppDelegate sharedDelegate] colorDict].allKeys count] == 0) {
                    [self requestSayColor];
                }
                if (isAfterAddNewSay == YES) {
                    isAfterAddNewSay = NO;
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Yousay" message:@"Share your say! It's awesome" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Share", nil];
                    alert.tag = shareSayTag;
                    [alert performSelector:@selector(show) withObject:nil afterDelay:1];
                    
                    // [alert show];
                }
                else if (saysID){
                    for (int i = 0; i < saysArray.count; i++) {
                        NSDictionary *says = [saysArray objectAtIndex:i];
                        if ([[says objectForKey:@"say_id"] integerValue] == [saysID integerValue]) {
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i+1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            saysID = nil;
                            return;
                        }
                    }
                }
                else if (_isAddSay == YES) {
                    [self btnAddSayTapped:self];
                }
                else {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
                [AppDelegate sharedDelegate].num_of_new_notifications = [[dictResult valueForKey:@"num_of_new_notifications"] integerValue];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kNotificationUpdateNotification object:nil];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
        }
        else{
            
        }
    }];
}

- (void)requestSayColor {
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_SAY_COLOR forKey:@"request"];
    [dictRequest setObject:profileModel.UserID forKey:@"user_id"];
    [dictRequest setObject:profileModel.token forKey:@"token"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                colorDictionary = [result objectForKey:@"colors"];
                [AppDelegate sharedDelegate].colorDict = colorDictionary;
                saysArray = [[NSMutableArray alloc] initWithArray:[profileDictionary valueForKey:@"says"]];
                
                [self.tableView reloadData];
                if (saysID){
                    for (int i = 0; i < saysArray.count; i++) {
                        NSDictionary *says = [saysArray objectAtIndex:i];
                        if ([[says objectForKey:@"say_id"] integerValue] == [saysID integerValue]) {
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            saysID = nil;
                            return;
                        }
                    }
                }
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
        }
        else{
            
        }
        HideLoader();
    }];
    
}

- (void)requestEditCharm:(CharmView*)charm{
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_RATE_USER_CHARMS forKey:@"request"];
    [dictRequest setObject:profileModel.UserID forKey:@"user_id"];
    [dictRequest setObject:profileModel.token forKey:@"token"];
    [dictRequest setObject:requestedID forKey:@"profile_id_to_rate"];
    NSMutableArray *arrayRating = [[NSMutableArray alloc]init];
    for (CharmChart *charts in charm.charts ) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:charts.title forKey:@"charm"];
        [dict setObject:[NSString stringWithFormat:@"%li",(long)charts.score] forKey:@"rate"];
        if (charts.score >= 0 && charts.lblScore.hidden == NO) {
            [arrayRating addObject:dict];
        }
        
    }
    
    [dictRequest setObject:arrayRating forKey:@"rating"];
    
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                charmsArray = [dictResult objectForKey:@"charms"];
                totalScoreAfterRate = [NSString stringWithFormat:@"%@",[dictResult objectForKey:@"num_users_rated"]];
                
                isAfterChangeCharm = NO;
                isAfterRate = YES;
                NSMutableDictionary *event =
                [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                                        action:@"rating"
                                                         label:@"rating"
                                                         value:nil] build];
                [[GAI sharedInstance].defaultTracker send:event];
                [[GAI sharedInstance] dispatch];
                
                //NSString *firstName = [[[profileDictionary objectForKey:@"name"] componentsSeparatedByString:@" "] objectAtIndex:0];
                
                
                //                NSString *message = [NSString stringWithFormat:@"Whoa! Share your rates with %@", firstName];
                //                //--If rate charm is succesful, alert the user wether they want to share the rating
                //                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Yousay" message:message delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Share", nil];
                //                alert.tag = shareAfterRateTag;
                //                [alert performSelector:@selector(show) withObject:nil afterDelay:1];
                //                isAfterRate = YES;
                [self.tableView reloadData];
                
                //call the autoclose button here after rating..
                
                 //[[NSNotificationCenter defaultCenter] postNotificationName:@"closeViewNotification" object:self];
                
                chartState = ChartStateRate;
                
                if(chartState == ChartStateRate){
                  
                    rateState=YES;
                    editState=NO;
                    
                }
                
                [self performSelector:@selector(afterDonebutton) withObject:self afterDelay:0.1];

                
                
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
        }
        else{
            
        }
        HideLoader();
    }];
}

- (void)requestChangeCharm:(NSString*)charmIn andCharmOut:(NSString*)charmOut{
    ShowLoader();
    
    NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_CHANGE_CHARM forKey:@"request"];
    [dictRequest setObject:[AppDelegate sharedDelegate].profileOwner.UserID forKey:@"user_id"];
    [dictRequest setObject:[AppDelegate sharedDelegate].profileOwner.token  forKey:@"token"];
    [dictRequest setObject:charmIn forKey:@"charm_in"]; //Name of the charms that user choose
    [dictRequest setObject:charmOut forKey:@"charm_out"]; //Name of the chamrs that user wants to change(delete)
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                chartState = ChartStateDefault;
                charmsArray = [dictResult objectForKey:@"charms"];
                isAfterChangeCharm = YES;
                isAfterCharm = YES;
                [self requestProfile:[[AppDelegate sharedDelegate].profileOwner UserID]];
                NSMutableDictionary *event =
                [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                                        action:@"change_charm"
                                                         label:@"change_charm"
                                                         value:nil] build];
                [[GAI sharedInstance].defaultTracker send:event];
                [[GAI sharedInstance] dispatch];
                
                chartState = ChartStateEdit;
                
                if(chartState == ChartStateEdit){
                    
                    rateState=NO;
                    editState=YES;
                    
                }

                
                [self performSelector:@selector(afterDonebutton) withObject:self afterDelay:0.1 ];

                
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
        }
        else{
            
        }
        HideLoader();
        
        //call the autoclose button here after editing..
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"closeViewNotification" object:self];
        

    }];
}

- (void)requestAddUserDevice {
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_ADD_USER_DEVICE forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token]  forKey:@"token"];
    [dictRequest setObject:[AppDelegate sharedDelegate].deviceToken forKey:@"device_id"];
    [dictRequest setObject:[AppDelegate sharedDelegate].deviceToken forKey:@"registration_id"];
    [dictRequest setObject:@"ios" forKey:@"device_type"];
    [dictRequest setObject:[UIDevice currentDevice].model forKey:@"device_info"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
        }
        else if (error)
        {
        }
        else{
            
        }
    }];
}

- (void)requesLikeSay:(id)sender{
    NSMutableDictionary *feedDict = [[saysArray objectAtIndex:[sender tag]] mutableCopy];
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_LIKE_SAY forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token]  forKey:@"token"];
    [dictRequest setObject:[feedDict objectForKey:@"say_id"] forKey:@"say_id"];
    
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                NSInteger count = [[feedDict objectForKey:@"like_count"] integerValue]+1;
                [feedDict setObject:@"true" forKey:@"liked"];
                [feedDict setObject:[NSNumber numberWithInteger:count] forKey:@"like_count"];
                [saysArray replaceObjectAtIndex:[sender tag] withObject:feedDict];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]] withRowAnimation:UITableViewRowAnimationNone];
                
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                PeopleSayTableViewCell *cell =  [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
                [cell.likeButton setSelected:NO];
                NSInteger likeCount = [[cell.likesLabel text]integerValue] - 1;
                [cell.likesLabel setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
            }
        }
        else if (error)
        {
            PeopleSayTableViewCell *cell =  [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
            NSInteger likeCount = [[cell.likesLabel text]integerValue] - 1;
            [cell.likesLabel setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        }
        else{
            PeopleSayTableViewCell *cell =  [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
            [cell.likeButton setSelected:NO];
            NSInteger likeCount = [[cell.likesLabel text]integerValue] - 1;
            [cell.likesLabel setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        }
    }];
}

- (void)requesUnlikeSay:(id)sender{
    NSMutableDictionary *feedDict = [[saysArray objectAtIndex:[sender tag]] mutableCopy];
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_UNLIKE_SAY forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token]  forKey:@"token"];
    [dictRequest setObject:[feedDict objectForKey:@"say_id"] forKey:@"say_id"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                NSInteger count = [[feedDict objectForKey:@"like_count"] integerValue]-1;
                [feedDict setObject:@"false" forKey:@"liked"];
                [feedDict setObject:[NSNumber numberWithInteger:count] forKey:@"like_count"];
                [saysArray replaceObjectAtIndex:[sender tag] withObject:feedDict];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]] withRowAnimation:UITableViewRowAnimationNone];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                PeopleSayTableViewCell *cell =  [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
                [cell.likeButton setSelected:YES];
                NSInteger likeCount = [[cell.likesLabel text]integerValue] + 1;
                [cell.likesLabel setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
            }        }
        else if (error)
        {
            PeopleSayTableViewCell *cell =  [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
            [cell.likeButton setSelected:YES];
            NSInteger likeCount = [[cell.likesLabel text]integerValue] + 1;
            [cell.likesLabel setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        }
        else{
            PeopleSayTableViewCell *cell =  [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
            [cell.likeButton setSelected:YES];
            NSInteger likeCount = [[cell.likesLabel text]integerValue] + 1;
            [cell.likesLabel setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        }
    }];
}

- (void)requestCreateProfile:(FriendModel*)friendModel {
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_CREATE_PROFILE forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token] forKey:@"token"];
    [dictRequest setObject:friendModel.userID forKey:@"authentication_id"];
    [dictRequest setObject:AUTHORITY_TYPE_FB forKey:@"authority_type"];
    [dictRequest setObject:friendModel.Name forKey:@"name"];
    [dictRequest setObject:friendModel.ProfileImage forKey:@"avatar_url"];
    [dictRequest setObject:friendModel.CoverImage forKey:@"cover_image_url"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                chartState = ChartStateViewing;
                isFriendProfile = YES;
                profileDictionary = [dictResult objectForKey:@"profile"];
                requestedID = [profileDictionary objectForKey:@"id"];
                saysArray = [[NSMutableArray alloc] initWithArray:[profileDictionary valueForKey:@"says"]];
                charmsArray = [profileDictionary valueForKey:@"charms"];
                isAfterChangeCharm = NO;
                
                friendModel.userID = requestedID;
                
                [self convertModelToObject:friendModel];
                
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                
                [AppDelegate sharedDelegate].num_of_new_notifications = [[dictResult valueForKey:@"num_of_new_notifications"] integerValue];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kNotificationUpdateNotification object:nil];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else if ([[dictResult valueForKey:@"rc"] integerValue] == 204) {
                //user already exist so we request the profile
                [self requestProfile:[dictResult valueForKey:@"user_id"]];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
        }
        else{
            
        }
        HideLoader();
    }];
}


- (IBAction)ProfileIconClicked:(id)sender {
}

- (void)requestGetProfileImage:(NSInteger)tag withDescription:(NSString*)desc andID:(NSString*)IDRequested {
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_GET_PROFILE_IMG forKey:@"request"];
    [dictRequest setObject:IDRequested forKey:@"user_id"];
    
    profileShared = IDRequested;
    isProfileShared = YES;
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                if (tag == 1000) {//Means share to facebook
                    //MM -- 23 May 2016
                    //-- Change the description text for facebook
                    NSString *titleFB = [dictResult valueForKey:@"say_facebook_share_line1"];
                    NSString *descFB = [NSString stringWithFormat:@"%@", [dictResult valueForKey:@"say_facebook_share_line2"]];
                    
                    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                    content.contentDescription = descFB;
                    content.contentTitle = titleFB;
                    NSString *url = [NSString stringWithFormat:@"https://go.onelink.me/3683706271?pid=ios&c=profile%@&af_dp=yousay://&af_web_dp=http://yousayweb.com&af_force_dp=true&is_retargeting=true&profile=%@",[dictResult valueForKey:@"selected_image"], IDRequested];
                    content.contentURL = [NSURL URLWithString:url];
                    content.imageURL = [NSURL URLWithString:[dictResult valueForKey:@"url"]];
                    
                    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
                    dialog.fromViewController = self;
                    dialog.shareContent = content;
                    dialog.mode = FBSDKShareDialogModeNative;
                    if (![dialog canShow]) {
                        // fallback presentation when there is no FB app
                        dialog.mode = FBSDKShareDialogModeFeedBrowser;
                    }
                    HideLoader();
                    [dialog show];
                    dialog.delegate = self;
                }
                else {
                    UIImageView *imgView = [[UIImageView alloc]init];
                    [imgView setImageURL:[NSURL URLWithString:[dictResult objectForKey:@"url"]] withCompletionBlock:^(BOOL succes, UIImage *image, NSError *error) {
                        HideLoader();
                        NSString *url = [NSString stringWithFormat:@"https://go.onelink.me/3683706271?pid=ios&c=profile%@&af_dp=yousay://&af_web_dp=http://yousayweb.com&af_force_dp=true&is_retargeting=true&profile=%@",[dictResult valueForKey:@"selected_image"], IDRequested];
                        CustomActivityProvider *activityProvider = [[CustomActivityProvider alloc]initWithPlaceholderItem:@""];
                        activityProvider.urlString = url;
                        UIActivity *activity = [[AQSFacebookMessengerActivity alloc] init];
                        
                        //--Change the share text 23 May 2016
                        NSString *shareText = [dictResult valueForKey:@"say_generic_share"];
                        NSArray *activityItems = [NSArray arrayWithObjects:image, activityProvider, shareText, nil];
                        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[activity]];
                        activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        
                        [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
                            if (!completed) return;
                            [self requestProfileShared:profileShared];
                        }];
                        
                        [self presentViewController:activityViewController animated:YES completion:nil];
                    }];
                }
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                HideLoader();
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                HideLoader();
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
            HideLoader();
        }
        else{
            HideLoader();
        }
    }];
}

- (void)requestGetSayImage:(NSString *)sayID withDescription:(NSString*)desc isFB:(BOOL)isFacebook {
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_GET_SAY_IMG forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:sayID forKey:@"say_id"];
    sayShared = sayID;
    isProfileShared = NO;
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                if (isFacebook == YES) {//means facebook
                    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                    
                    //MM-- Specify title and desc specifically for facebook
                    NSString *title = [dictResult valueForKey:@"say_facebook_share_line1"];
                    NSString *description = [NSString stringWithFormat:@"%@", [dictResult valueForKey:@"say_facebook_share_line2"]];
                    
                    content.contentTitle = title;
                    NSString *url = [NSString stringWithFormat:@"https://go.onelink.me/3683706271?pid=ios&c=say%@&af_dp=yousay://&af_web_dp=http://yousayweb.com&af_force_dp=true&is_retargeting=true&profile=%@&sayid=%@",[dictResult valueForKey:@"selected_image"], requestedID, sayID];
                    content.contentURL = [NSURL URLWithString:url];
                    content.imageURL = [NSURL URLWithString:[dictResult objectForKey:@"url"]];
                    content.contentDescription = description;
                    
                    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
                    dialog.fromViewController = self;
                    dialog.shareContent = content;
                    dialog.mode = FBSDKShareDialogModeNative;
                    if (![dialog canShow]) {
                        // fallback presentation when there is no FB app
                        dialog.mode = FBSDKShareDialogModeFeedBrowser;
                    }
                    HideLoader();
                    [dialog show];
                    dialog.delegate = self;
                }
                else {
                    UIImageView *imgView = [[UIImageView alloc]init];
                    [imgView setImageURL:[NSURL URLWithString:[dictResult objectForKey:@"url"]] withCompletionBlock:^(BOOL succes, UIImage *image, NSError *error) {
                        HideLoader();
                        NSString *url = [NSString stringWithFormat:@"https://go.onelink.me/3683706271?pid=ios&c=say%@&af_dp=yousay://&af_web_dp=http://yousayweb.com&af_force_dp=true&is_retargeting=true&profile=%@&sayid=%@",[dictResult valueForKey:@"selected_image"], requestedID, sayID];
                        CustomActivityProvider *activityProvider = [[CustomActivityProvider alloc]initWithPlaceholderItem:@""];
                        activityProvider.urlString = url;
                        
                        //--Change share 23 May 2016
                        NSString *shareText = [dictResult valueForKey:@"say_generic_share"];
                        
                        NSArray *activityItems = [NSArray arrayWithObjects:image, activityProvider, shareText, nil];
                        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                        activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        
                        [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
                            if (!completed) return;
                            [self requestSayShared:sayShared];
                        }];
                        
                        [self presentViewController:activityViewController animated:YES completion:nil];
                    }];
                }
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                HideLoader();
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                HideLoader();
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
            HideLoader();
        }
        else{
            HideLoader();
        }
    }];
}

- (void)requestProfileShared:(NSString *)sharedUserID {
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_PROFILE_SHARED forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token] forKey:@"token"];
    [dictRequest setObject:sharedUserID forKey:@"shared_user_id"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                NSMutableDictionary *event =
                [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                                        action:@"shareProfile"
                                                         label:@"shareProfile"
                                                         value:nil] build];
                [[GAI sharedInstance].defaultTracker send:event];
                [[GAI sharedInstance] dispatch];
                
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
        }
        else{
            
        }
        HideLoader();
    }];
}

- (void)requestSayShared:(NSString *)sharedSayID {
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_SAY_SHARED forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token] forKey:@"token"];
    [dictRequest setObject:sharedSayID forKey:@"shared_say_id"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                NSMutableDictionary *event =
                [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                                        action:@"shareSay"
                                                         label:@"shareSay"
                                                         value:nil] build];
                [[GAI sharedInstance].defaultTracker send:event];
                [[GAI sharedInstance] dispatch];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
        }
        else{
            
        }
        HideLoader();
    }];
}

- (void)requestSkipRating {
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_SKIP_RATING forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token] forKey:@"token"];
    [dictRequest setObject:requestedID forKey:@"skip_user_id"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                NSMutableDictionary *event =
                [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                                        action:@"skipRating"
                                                         label:@"skipRating"
                                                         value:nil] build];
                [[GAI sharedInstance].defaultTracker send:event];
                [[GAI sharedInstance] dispatch];
                [self requestProfile:requestedID];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                HideLoader();
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                HideLoader();
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
            HideLoader();
        }
        else{
            HideLoader();
        }
    }];
}

#pragma mark TableView

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *thisView = [[UIView alloc]init];
    thisView.backgroundColor = [UIColor blackColor];//kColorBG;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.view.bounds.size.width-40, 37)];
    label.text = [NSString stringWithFormat:@"What people said about %@", [profileDictionary objectForKey:@"name"]];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont fontWithName:@"Arial" size:14];
    [thisView addSubview:label];
    return thisView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *thisView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)];
    thisView.backgroundColor = kColorBG;
    return thisView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section > 0) {
        return 30;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        CGFloat height=0;
        if (self.view.frame.size.height >= 667) {//6+
            height= self.view.frame.size.height - 95;
        }
        else if (self.view.frame.size.height > 568) {//6
            height= self.view.frame.size.height - 60;
        }
        else if (self.view.frame.size.height >= 480) {//5
            height= self.view.frame.size.height-10;
        }
        else{//4
            height= self.view.frame.size.height + 70;
        }
        return height;
    }
    else {
        NSString *index = [NSString stringWithFormat:@"%ld", (long)indexPath.section-1];
        if ([[dictHideSay objectForKey:index] isEqualToString:@"isHide"]) {
            return 90;
        }
        //        NSDictionary *currentSaysDict = [saysArray objectAtIndex:indexPath.row];
        //        NSString *string = [currentSaysDict valueForKey:@"text"];
        //        CGSize expectedSize = [CommonHelper expectedSizeForString:string width:tableView.frame.size.width-65 font:[UIFont fontWithName:@"Arial" size:14] attributes:nil];
        return 289; //144 + 145
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([saysArray count]>0){
        return [saysArray count]+1;
    }
    else if (profileModel ) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self constructCellForProfilePage:indexPath forTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)convertModelToObject:(FriendModel*)model {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Search"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K like %@", @"id", [[AppDelegate sharedDelegate].profileOwner UserID]];
    [request setPredicate:predicateID];
    
    NSError *Fetcherror;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&Fetcherror] mutableCopy];
    
    if (!mutableFetchResults) {
        // error handling code.
    }
    
    if ([[mutableFetchResults valueForKey:@"userID"]
         containsObject:model.userID]) {
        //notify duplicates
        return;
    }
    else
    {
        // Create a new managed object
        NSManagedObject *newSearch = [NSEntityDescription insertNewObjectForEntityForName:@"Search" inManagedObjectContext:context];
        
        [newSearch setValue:model.Name forKey:@"name"];
        [newSearch setValue:model.ProfileImage  forKey:@"profileImage"];
        [newSearch setValue:model.CoverImage  forKey:@"coverImage"];
        [newSearch setValue:model.userID  forKey:@"userID"];
        [newSearch setValue:[[AppDelegate sharedDelegate].profileOwner UserID]  forKey:@"id"];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            //    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        [[AppDelegate sharedDelegate].arrRecentSeacrh insertObject:newSearch atIndex:0];
    }
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    cString = [cString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (UITableViewCell*)constructCellForProfilePage:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView {
    static NSString *cellIdentifier = @"ProfileTableViewCell";
    ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(indexPath.section == 0)
    {
        static NSString *cellIdentifier = @"ProfileTableViewCell";
        ProfileTableViewCell *cel = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        ProfileOwnerModel *model = [[ProfileOwnerModel alloc]init];
        cel.parent = self;
        if (! isFriendProfile) {
            cel.imgEditIcon.image = [UIImage imageNamed:@"EditIcon.png"];
        }else{
            cel.imgEditIcon.image = [UIImage imageNamed:@""];
        }
        
        
        model.Name = [profileDictionary objectForKey:@"name"];
        model.ProfileImage = [profileDictionary objectForKey:@"picture"];
        model.CoverImage = [profileDictionary objectForKey:@"cover_url"];
        model.UserID = requestedID;
        
        if  ([[[AppDelegate sharedDelegate].profileOwner UserID] isEqualToString:[profileDictionary objectForKey:@"id"]]){
            //model = profileModel;
            chartState = chartState == ChartStateViewing ? ChartStateDefault : chartState;
            [btnAddSay setHidden:YES];
            [cel.lblYourCharm setText:@"Your traits (rated by friends)"];
        }
        else {
            
            model.Name = [profileDictionary objectForKey:@"name"];
            model.ProfileImage = [profileDictionary objectForKey:@"picture"];
            model.CoverImage = [profileDictionary objectForKey:@"cover_url"];
            model.UserID = requestedID;
            friendsProfileModel = model;
            //--To not show (null) Charms
            if (model.Name == nil) {
                model.Name = @"";
            }
            [cel.lblYourCharm setText:[NSString stringWithFormat:@"%@'s traits", model.Name]];
            
            chartState = chartState == ChartStateDefault ? ChartStateViewing : chartState;
            [btnAddSay setHidden:NO];
            
            cel.imgViewProfilePicture.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleFingerTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleSingleTap:)];
            [cel.imgViewProfilePicture addGestureRecognizer:singleFingerTap];
            singleFingerTap.delegate =  self;
        }
        
        
        //TOOLTIP - Own profile Tips
        //1. Appear on first time only
        NSUserDefaults *firstTimeDefaults = [NSUserDefaults standardUserDefaults];
        BOOL isNOTFirstTime = [firstTimeDefaults boolForKey:@"OWNPROFILE_NOT_FIRSTTIME"];
        if (!isFriendProfile && !isNOTFirstTime && !tooltipIsVisible) {
            tooltipIsVisible = YES;
            UIView *background = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            [background setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            if (!window)
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            //[[[window subviews] objectAtIndex:0] addSubview:background];
            //tip
            UITooltip *tip1 = [[UITooltip alloc]initWithFrame:CGRectMake((background.frame.size.width-180)/2, (background.frame.size.height-85)/2, 180, 85)];
            tip1.tipArrow = TipArrowBottomLeft;
            tip1.tooltipText = @"This is your profile, here you can see what your friends think about you";
            //[background addSubview:tip1]; /* hiide 1st own profile ToolTip */
            
            UITooltip *tip2 = [[UITooltip alloc]initWithFrame:CGRectMake((background.frame.size.width-205)/2, 130, 209, 85)];
            tip2.tipArrow = TipArrowBottomLeft;
            tip2.tooltipText = @"These are your best traits as rated  anonymously by your friends\nTap and hold to edit them";
            
            UITooltip *tip3 = [[UITooltip alloc]initWithFrame:CGRectMake((background.frame.size.width-150)/2, 63, 150, 72)];
            tip3.tipArrow = TipArrowTopLeft;
            tip3.tooltipText = @"Type your friend’s name to find their profile";
            
            
            [tip1 onButtonTap:^{
                [tip1 closeToolTip];
                [tip2 showToolTip:background];
            }];
            
            [tip2 onButtonTap:^{
                [tip2 closeToolTip];
                [tip3 showToolTip:background];
                
            }];
            
            [tip3 onButtonTap:^{
                [tip3 closeToolTip];
                [background removeFromSuperview];
                tooltipIsVisible = NO;
                // [firstTimeDefaults setBool:YES forKey:@"OWNPROFILE_NOT_FIRSTTIME"];
                
            }];
            [self loadFirstTimePopUp];
            [firstTimeDefaults setBool:YES forKey:@"OWNPROFILE_NOT_FIRSTTIME"];
        }
        else{
            
            
        }
        //FRIENDS PROFILE
        BOOL isNOTFirstTimeOnFriendProfile = [firstTimeDefaults boolForKey:@"FRIENDPROFILE_NOT_FIRSTTIME"];
        
        if(isFriendProfile && !isNOTFirstTimeOnFriendProfile && !tooltipIsVisible && friendsProfileModel){
            tooltipIsVisible = YES;
            UIView *background = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            [background setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            if (!window)
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            //[[[window subviews] objectAtIndex:0] addSubview:background];
            
            //tip
            UITooltip *tip1 = [[UITooltip alloc]initWithFrame:CGRectMake((background.frame.size.width-210)/2, (background.frame.size.height-99)/2, 240, 115)];
            tip1.tipArrow = TipArrowBottomLeft;
            tip1.tooltipText = [NSString stringWithFormat:@"These are %@’s best traits as rated  anonymously by their friends\nTap and hold to rate %@’s traits anonymously and see the final rates\n", [profileDictionary objectForKey:@"name"], [profileDictionary objectForKey:@"name"]];
            //[tip1 showToolTip:background];
            
            CGFloat tip2y =  355;
            CGFloat tip2x =  70;
            
            if (IS_IPHONE_6) {
                tip2y = 495;
                tip2x = 100;
            }
            else if(IS_IPHONE_5){
                tip2y = 435;
                tip2x = 60;
            }
            else if(IS_IPHONE_6PLUS){
                tip2y = 525;
                tip2x = 120;
            }
            
            UITooltip *tip2 = [[UITooltip alloc]initWithFrame:CGRectMake(tip2x, tip2y, 170, 84)];
            tip2.tipArrow = TipArrowMiddleRight;
            tip2.tooltipText = [NSString stringWithFormat:@"Click on the + icon to write something awesome about %@", friendsProfileModel.Name];
            
            [tip1 onButtonTap:^{
                [tip1 closeToolTip];
                [tip2 showToolTip:background];
            }];
            
            [tip2 onButtonTap:^{
                [tip2 closeToolTip];
                [background removeFromSuperview];
                tooltipIsVisible = NO;
                //[firstTimeDefaults setBool:YES forKey:@"FRIENDPROFILE_NOT_FIRSTTIME"];
            }];
            [self loadFirstTimePopUp];
            [firstTimeDefaults setBool:YES forKey:@"FRIENDPROFILE_NOT_FIRSTTIME"];
        }
        
        
        
        //--Profile Box
        NSURL *cover = [NSURL URLWithString:model.CoverImage];
        if  (cover && [cover scheme] && [cover host]) {
            [cel.imgViewCover setImageURL:cover];
        }
        else {
            [cel.imgViewCover setImageURL:[NSURL URLWithString:@"http://freephotos.atguru.in/hdphotos/best-cover-photos/best-friend-facebook-timeline-cover-image.png"]];
        }
        cel.imgViewCover.layer.cornerRadius = 0.015 * cel.imgViewCover.bounds.size.width;
        cel.imgViewCover.layer.masksToBounds = YES;
        cel.imgViewCover.layer.borderWidth = 1;
        cel.imgViewCover.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        
        NSURL *profile = [NSURL URLWithString:model.ProfileImage];
        if  (profile && [profile scheme] && [profile host]) {
            [cel.imgViewProfilePicture setImageURL:[NSURL URLWithString:model.ProfileImage]];
        }
        else {
            [cel.imgViewProfilePicture setImageURL:[NSURL URLWithString:@"http://2.bp.blogspot.com/-6QyJDHjB5XE/Uscgo2DVBdI/AAAAAAAACS0/DFSFGLBK_fY/s1600/facebook-default-no-profile-pic.jpg"]];
        }
        
        cel.imgViewProfilePicture.layer.cornerRadius = 0.5 * cel.imgViewProfilePicture.bounds.size.width;
        cel.imgViewProfilePicture.layer.masksToBounds = YES;
        cel.imgViewProfilePicture.layer.borderWidth = 1;
        cel.imgViewProfilePicture.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        [cel.imgViewProfilePicture.layer setBorderColor:[UIColor whiteColor].CGColor];
        [cel.imgViewProfilePicture.layer setBorderWidth:3.0];
        
        cel.lblName.text = model.Name;
        NSInteger popularity = [[profileDictionary objectForKey:@"popularity"] integerValue];
        NSInteger wiz = [[profileDictionary objectForKey:@"rank"] integerValue];
        [cel.lblRankCount setText:[NSString stringWithFormat:@"%ld", (long)wiz]];
        [cel.lblPopularityCount setText:[NSString stringWithFormat:@"%ld", (long)popularity]];
        
        [cel.newbie setImageURL:[NSURL URLWithString:[profileDictionary objectForKey:@"rank_picture"]]];
        [cel.popular setImageURL:[NSURL URLWithString:[profileDictionary objectForKey:@"popularity_picture"]]];
        
        
        cel.lblRankLevel.text = [profileDictionary objectForKey:@"rank_level"];
        cel.lblPopularityLevel.text = [profileDictionary objectForKey:@"popularity_level"];
        if ([profileDictionary objectForKey:@"num_users_rated"] && isAfterRate == NO) {
            cel.lblTotalScore.text = [NSString stringWithFormat:@"%@", [profileDictionary objectForKey:@"num_users_rated"]];
        }
        else {
            cel.lblTotalScore.text = totalScoreAfterRate;
        }
        
        cel.charmView.layer.cornerRadius = 0.015 * cel.charmView.bounds.size.width;
        cel.charmView.layer.masksToBounds = YES;
        cel.charmView.layer.borderWidth = 1;
        cel.charmView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        
        //--Charms Box
        if (!isFriendProfile && isAfterRate == NO) {
            charmsArray = [profileDictionary valueForKey:@"charms"];
        }
        if (chartState != ChartStateEdit && isAfterCharm == NO) {
            arrActiveCharm = [arrayFilteredCharm mutableCopy];
        }
        
        if (chartState != ChartStateEdit && !isAfterChangeCharm) {
            arrayFilteredCharm = [[NSMutableArray alloc]init];
            arrayOriginalCharm = [[NSMutableArray alloc]init];
            for (int i=0; i<charmsArray.count; i++) {
                NSDictionary *dict = [charmsArray objectAtIndex:i];
                if ([[dict objectForKey:@"active"] isEqualToString:@"true"]) {
                    [arrayFilteredCharm addObject:dict];
                    [arrayOriginalCharm addObject:dict];
                }
            }
        }
        
        for (int i = 0; i < arrActiveCharm.count; i++) {
            NSDictionary *dic = [arrActiveCharm objectAtIndex:i];
            for (int j=0; j<arrayFilteredCharm.count; j++) {
                NSDictionary *dic2 = [arrayFilteredCharm objectAtIndex:j];
                if ([[dic objectForKey:@"name"] isEqualToString:[dic2 objectForKey:@"name"]]) {
                    [arrActiveCharm replaceObjectAtIndex:i withObject:dic2];
                }
            }
        }
        
        [[cel.charmChartView subviews]
         makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        cel.charmChartView.delegate = self;
        NSMutableArray *arrScore = [[NSMutableArray alloc]init];
        NSMutableArray *arrNames = [[NSMutableArray alloc]init];
        NSMutableArray *arrLocked = [[NSMutableArray alloc]init];
        NSMutableArray *arrActive = [[NSMutableArray alloc]init];
        NSMutableArray *arrUserRatedScore = [[NSMutableArray alloc]init];
        if (arrActiveCharm.count == 0) {
            arrActiveCharm = arrayFilteredCharm;
        }
        if (chartState != ChartStateEdit && isAfterCharm == NO) {
            arrActiveCharm = arrayFilteredCharm;
        }
        for (NSDictionary *dict in arrActiveCharm) {
            [arrScore addObject:[dict valueForKey:@"rate"]];
            [arrNames addObject:[dict valueForKey:@"name"]];
            [arrLocked addObject:[dict valueForKey:@"rated"]];
            [arrActive addObject:[dict valueForKey:@"active"]];
            if ([dict valueForKey:@"current_user_rate"] == nil) {
                [arrUserRatedScore addObject:@"0"];
            }
            else {
                [arrUserRatedScore addObject:[dict valueForKey:@"current_user_rate"]];
            }
            
        }
        cel.charmChartView.chartScores  =  arrScore;
        cel.charmChartView.chartNames  =  arrNames;
        cel.charmChartView.chartLocked  =  arrLocked;
        cel.charmChartView.chartActive = arrActive;
        cel.charmChartView.chartUserRated = arrUserRatedScore;
        
        if ([[profileDictionary objectForKey:@"rated"] isEqualToString:@"false"] && isAfterRate == NO) {
            [cel.charmChartView setIsNeverRate:YES];
        }
        else {
            [cel.charmChartView setIsNeverRate:NO];
        }
        
        cel.charmChartView.state = chartState;
        charmView = cel.charmChartView;
        
        cell.btnShare.frame = CGRectMake(cell.btnShare.frame.origin.x, charmView.frame.size.height, cell.btnShare.frame.size.width, cell.btnShare.frame.size.height);
        
        [cel.cancelSkip setHidden:YES];
        [cel.lblNeverRate setHidden:YES];
        
        [cel.lblTotalRateTitle setHidden:NO];
        [cel.lblTotalScore setHidden:NO];
        [cel.imgHand setHidden:YES];
        [cel.btnSkip setHidden:YES];
        [cel.line setHidden:NO];
        
        if (chartState == ChartStateEdit) {
            [cel.longPressInfoView setHidden:YES];
            [cel.lblShare setHidden:YES];
            [cel.btnShare setHidden:YES];
            [cel.imgVShare setHidden:YES];
            [cel.buttonEditView setHidden:NO];
            
            [cel.btnDone setTitle:@"Done! Show how my friends rated me" forState:UIControlStateNormal];
            cel.btnDone.titleLabel.font = [UIFont systemFontOfSize:14.0];
            [cel.rankButton setHidden:YES];
            [btnAddSay setHidden:YES];
        }
        else if (chartState == ChartStateRate) {
            [cel.longPressInfoView setHidden:YES];
            [cel.lblShare setHidden:YES];
            [cel.btnShare setHidden:YES];
            [cel.imgVShare setHidden:YES];
            [cel.buttonEditView setHidden:NO];
            [cel.btnDone setTitle:[NSString stringWithFormat:@"Done! Show me %@'s rating",[profileDictionary objectForKey:@"first_name"]] forState:UIControlStateNormal];
            cel.btnDone.titleLabel.font = [UIFont systemFontOfSize:14.0];
            
            [cel.line setHidden:YES];
            [cell.contentView bringSubviewToFront:cel.charmChartView];
            cel.btnRate.translatesAutoresizingMaskIntoConstraints = YES;
            [cel.btnRate setFrame:CGRectMake(cel.contentView.frame.size.width, cel.btnRate.frame.origin.x, 0, 0)];
            
            if ([[profileDictionary objectForKey:@"rated"] isEqualToString:@"false"]) {
                [cel.btnSkip setHidden:NO];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSInteger animationCount = [[defaults objectForKey:@"animation"] integerValue];
                if (animationCount == 5) {
                    animationCount = animationCount+1;
                    [defaults setObject:[NSString stringWithFormat:@"%ld", (long)animationCount] forKey:@"animation"];
                }
                if (animationCount < 5 && isAfterRate == NO) {
                    [cel.imgHand setHidden:NO];
                    
                    CABasicAnimation *hover = [CABasicAnimation animationWithKeyPath:@"position"];
                    hover.additive = YES; // fromValue and toValue will be relative instead of absolute values
                    hover.fromValue = [NSValue valueWithCGPoint:CGPointZero];
                    hover.toValue = [NSValue valueWithCGPoint:CGPointMake(0.0, -100.0)]; // y increases downwards on iOS
                    hover.autoreverses = YES; // Animate back to normal afterwards
                    hover.duration = 1.5; // The duration for one part of the animation
                    hover.repeatCount = 1; // The number of times the animation should repeat
                    [cel.imgHand.layer addAnimation:hover forKey:@"myHoverAnimation"];
                    [self performSelector:@selector(hideImageAfterAnimation:) withObject:cel afterDelay:3.0];
                    animationCount = animationCount+1;
                    [defaults setObject:[NSString stringWithFormat:@"%ld", (long)animationCount] forKey:@"animation"];
                }
            }
            [cel.rankButton setHidden:YES];
            [btnAddSay setHidden:YES];
            [cel.defaultFooterView setHidden:YES];
            [cel.cancelSkip setHidden:NO];
            [cel.lblTotalRateTitle setHidden:YES];
            [cel.lblTotalScore setHidden:YES];
        }
        else if (isFriendProfile == YES) {
            [cel.longPressInfoView setHidden:YES];
            [cel.rankButton setHidden:NO];
            [cel.buttonEditView setHidden:YES];
            if ([[profileDictionary objectForKey:@"rated"] isEqualToString:@"false"] && isAfterRate == NO) {
                [cel.lblNeverRate setHidden:NO];
                [cel.lblNeverRate setText:[NSString stringWithFormat:@"Click to rate and reveal %@'s traits", [[model.Name componentsSeparatedByString:@" "] objectAtIndex:0]]];
                [cel.contentView bringSubviewToFront:cel.lblNeverRate];
                cel.lblNeverRate.layer.zPosition = 1;
            }
            
            //            [cel.lblTotalRateTitle setHidden:YES];
            //            [cel.lblTotalScore setHidden:YES];
        }
        else{
            [cel.rankButton setHidden:YES];
            [cel.longPressInfoView setHidden:NO];
            [cel.lblShare setHidden:NO];
            [cel.btnShare setHidden:NO];
            [cel.imgVShare setHidden:NO];
            [cel.buttonEditView setHidden:YES];
        }
        
        cel.lblWhatPeopleSay.text = [NSString stringWithFormat:@"What people said about %@", [profileDictionary objectForKey:@"name"]];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(EnableCharmRateMode)];
        longPress.delegate =  self;
        [cel.charmView addGestureRecognizer:longPress];
        longPress = nil;
        
        cel.selectionStyle = UITableViewCellSelectionStyleNone;
        [cel layoutIfNeeded]; // <- added
        return cel;
    }
    
    else //if (indexPath.section == 1)
    {
        static NSString *cellIdentifier = @"PeopleSayTableViewCell";
        PeopleSayTableViewCell *cel = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cel == nil) {
            cel = [[PeopleSayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault    reuseIdentifier:cellIdentifier] ;
        }
        
        cel.clipsToBounds = YES;
        NSDictionary *currentSaysDict = [saysArray objectAtIndex:indexPath.section-1];
        NSString *colorIndex = [NSString stringWithFormat:@"%@",[currentSaysDict objectForKey:@"say_color"]];
        [cel.peopleSayTitleLabel setTextColor:[UIColor whiteColor]];
        
        if (cel.tag != indexPath.section) {
            [cel.viewLikeList setHidden:YES];
        }
        else {
            [cel.viewLikeList setHidden:NO];
        }
        
        cel.layer.cornerRadius = 0.015 * cel.bounds.size.width;
        cel.layer.masksToBounds = YES;
        cel.layer.borderWidth = 1;
        cel.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        
        cel.viewMore.layer.cornerRadius = 0.03 * cel.viewMore.bounds.size.width;
        cel.viewMore.layer.masksToBounds = YES;
        cel.viewMore.layer.borderWidth = 1;
        cel.viewMore.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        [cel.viewMore.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        NSURL *imgURL = [NSURL URLWithString:[currentSaysDict objectForKey:@"profile_image"]];
        if  (imgURL && [imgURL scheme] && [imgURL host]) {
            [cel.imgViewProfilePic setImageURL:imgURL];
        }
        else {
            [cel.imgViewProfilePic setImageURL:[NSURL URLWithString:@"http://2.bp.blogspot.com/-6QyJDHjB5XE/Uscgo2DVBdI/AAAAAAAACS0/DFSFGLBK_fY/s1600/facebook-default-no-profile-pic.jpg"]];
        }
        
        cel.imgViewProfilePic.layer.cornerRadius = 0.5 * cel.imgViewProfilePic.bounds.size.width;
        cel.imgViewProfilePic.layer.masksToBounds = YES;
        cel.imgViewProfilePic.layer.borderWidth = 1;
        cel.imgViewProfilePic.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        cel.peopleSayTitleLabel.text = [NSString stringWithFormat:@"%@", [currentSaysDict objectForKey:@"by"]];
        cel.dateLabel.text = [currentSaysDict objectForKey:@"date"];
        cel.likesLabel.text = [NSString stringWithFormat:@"%@",[currentSaysDict objectForKey:@"like_count"]];
        cel.peopleSayLabel.text = [currentSaysDict objectForKey:@"text"];
        cel.btnHide.tag = indexPath.section-1;
        cel.btnUndo.tag = indexPath.section-1;
        cel.btnProfile.tag = indexPath.section-1;
        cel.btnReport.tag = indexPath.section-1;
        cel.btnReportLabel.tag = indexPath.section-1;
        cel.btnInstagram.tag = indexPath.section-1;
        cel.btnInstagramLabel.tag = indexPath.section-1;
        cel.btnShareFB.tag = indexPath.section-1;
        cel.btnShare.tag = indexPath.section-1;
        cel.btnLikeCount.tag = indexPath.section-1;
        cel.btnDot.tag = indexPath.section-1;
        
        [cel.viewMore setHidden:YES];
        [cel.btnDot setSelected:NO];
        [cel.btnLikeCount setHighlighted:NO];
        NSDictionary *indexDict = [[AppDelegate sharedDelegate].colorDict objectForKey:colorIndex];
        [cel setBackgroundColor:[self colorWithHexString: [indexDict objectForKey:@"back"]]];
        [cel.peopleSayLabel setTextColor:[self colorWithHexString: [indexDict objectForKey:@"fore"]]];
        [cel.peopleSayLabel sizeToFit];
        CGSize expectedSize = [CommonHelper expectedSizeForLabel:cel.peopleSayLabel attributes:nil];
        cel.peopleSayLabel.frame = CGRectMake(cel.peopleSayLabel.frame.origin.x, cel.peopleSayLabel.frame.origin.y, expectedSize.width, expectedSize.height);
        cel.peopleSayView.frame =CGRectMake(cel.peopleSayView.frame.origin.x, cel.peopleSayView.frame.origin.y, expectedSize.width, expectedSize.height);
        
        [cel.likeButton setTag:indexPath.section-1];
        
        if ([[currentSaysDict objectForKey:@"liked"] isEqualToString:@"true"]) {
            [cel.likeButton setSelected:YES];
        }
        else {
            [cel.likeButton setSelected:NO];
        }
        
        NSString *index = [NSString stringWithFormat:@"%ld", (long)indexPath.section-1];
        if ([[dictHideSay objectForKey:index] isEqualToString:@"isHide"]) {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
            UIView *hideView = [[UIView alloc]initWithFrame:CGRectMake(15, 10, tableView.frame.size.width-30, [tableView rectForRowAtIndexPath:indexPath].size.height - 20)];
            [hideView setBackgroundColor:[UIColor colorWithRed:205/255.f green:205/255.f blue:205/255.f alpha:1]];
            UILabel *lblHideInfo = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, hideView.frame.size.width-40, 20)];
            [lblHideInfo setText:@"this say will be hidden from your profile"];
            [lblHideInfo setFont:[UIFont fontWithName:@"Arial" size:12]];
            [lblHideInfo setTextAlignment:NSTextAlignmentCenter];
            [lblHideInfo setTextColor:[UIColor darkGrayColor]];
            [hideView addSubview:lblHideInfo];
            
            UIButton *btnUndo = [[UIButton alloc]initWithFrame:CGRectMake((hideView.frame.size.width-50)/2, lblHideInfo.frame.origin.y+lblHideInfo.frame.size.height+0, 50, 25)];
            btnUndo.tag = indexPath.section-1;
            [btnUndo addTarget:self action:@selector(btnUndoClicked:) forControlEvents:UIControlEventTouchUpInside];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Undo"
                                                                                     attributes:
                                                      @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                                        NSForegroundColorAttributeName: [UIColor colorWithRed:23/255.f green:174/255.f blue:201/255.f alpha:1],
                                                        NSFontAttributeName: [UIFont fontWithName:@"Arial" size:14]}]];
            [btnUndo setAttributedTitle:attributedString forState:UIControlStateNormal];
            [hideView addSubview:btnUndo];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:hideView];
            [cel layoutIfNeeded]; // <- added
            return cel;
        }
        else {
            [cel.hideSayView setHidden:YES];
        }
        if (isFriendProfile) {
            [cel.btnHide setHidden:YES];
        }
        else {
            [cel.btnHide setHidden:NO];
        }
        if ([cel.likesLabel.text integerValue] < 1) {
            [cel.btnLikeCount setEnabled:NO];
            // [cel.btnLikeCount setTag:[[currentSaysDict objectForKey:@"say_id"] integerValue]];
        }
        else {
            [cel.btnLikeCount setEnabled:YES];
            //[cel.btnLikeCount setTag:[[currentSaysDict objectForKey:@"say_id"] integerValue]];
        }
        
        
        if (cel.tag == indexPath.section+999) {
            [cel.viewMore setHidden:NO];
            [cel.btnDot setSelected:YES];
        }
        else {
            [cel.viewMore setHidden:YES];
            [cel.btnDot setSelected:NO];
        }
        cel.selectionStyle = UITableViewCellSelectionStyleNone;
        [cel layoutIfNeeded]; // <- added
        return cel;
    }
    [cell layoutIfNeeded]; // <- added
    return cell;
}

- (UIView*)getCharmsDisplay:(CGFloat)chartHeight withScore:(NSInteger)score {
    
    UIView *viewToAttach = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, chartHeight)];
    viewToAttach.backgroundColor = [UIColor whiteColor];
    CGFloat heightPerUnit = chartHeight/11.5;
    
    NSInteger roundedScore = 0;
    if (score < 10) {
        roundedScore = 10;
    }
    else if (score%10 < 5) {
        roundedScore = score/10*10;
    }
    else {
        roundedScore = score/10*10+10;
    }
    
    for (int i=10; i<= roundedScore;) {
        int multiplier = (100-i)/10 +1;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, multiplier*heightPerUnit+1, 50, heightPerUnit-1)];
        view.layer.cornerRadius = 0.03 * view.bounds.size.width;
        view.layer.masksToBounds = YES;
        view.layer.borderWidth = 1;
        view.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        
        view.backgroundColor = [self getColor:i];
        [viewToAttach addSubview:view];
        i=i+10;
        
        if (i > roundedScore) {
            UILabel *lblScore = [[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.origin.y - 25, 50, 30)];
            lblScore.text = [NSString stringWithFormat:@"%li", (long)score];
            lblScore.textColor = kColorLabel;
            lblScore.textAlignment = NSTextAlignmentCenter;
            lblScore.font = [UIFont systemFontOfSize:14.0 weight:bold];
            [viewToAttach addSubview:lblScore];
        }
    }
    return viewToAttach;
}


- (UIColor*)getColor:(NSInteger)index {
    UIColor *color;
    switch (index) {
        case 10:
            color = kColor10;
            break;
        case 20:
            color = kColor20;
            break;
        case 30:
            color = kColor30;
            break;
        case 40:
            color = kColor40;
            break;
        case 50:
            color = kColor50;
            break;
        case 60:
            color = kColor60;
            break;
        case 70:
            color = kColor70;
            break;
        case 80:
            color = kColor80;
            break;
        case 90:
            color = kColor90;
            break;
        case 100:
            color = kColor100;
            break;
        default:
            color = kColorDefault;
            break;
    }
    return color;
}

#pragma mark - IBAction

- (IBAction)btnDotlicked:(id)sender {
    UIButton *button = (UIButton*)sender;
    PeopleSayTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
    if (button.selected == NO) {
        [cell.viewMore setHidden:NO];
        [cell.btnDot setSelected:YES];
        cell.tag = [sender tag]+1000;
    }
    else {
        [cell.viewMore setHidden:YES];
        [cell.btnDot setSelected:NO];
        cell.tag = 5000;
    }
}

- (IBAction)btnInstagramClicked:(id)sender {
    //TODO
    UIImage *image = [UIImage imageNamed:@"3dot"];
    MGInstagram *test = [[MGInstagram alloc]init];
    if ([MGInstagram isAppInstalled] && [MGInstagram isImageCorrectSize:image]) {
        [test postImage:image inView:self.view];
    }
    else {
        //    NSLog(@"Error Instagram is either not installed or image is incorrect size");
    }
}

- (IBAction)btnShowSkipClicked:(id)sender {
    [self.viewSkip setHidden:NO];
    [self.view bringSubviewToFront:self.viewSkip];
}

- (IBAction)btnLetsRateClicked:(id)sender {
    [self.viewSkip setHidden:YES];
}

- (IBAction)btnSkipClicked:(id)sender {
    [self.viewSkip setHidden:YES];
    chartState = ChartStateDefault;
    [self requestSkipRating];
}

- (IBAction)btnHideClicked:(id)sender {
    // NSLog(@"btnClick : %ld", (long)[sender tag]);
    NSString *index = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    [dictHideSay setObject:@"isHide" forKey:index];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (IBAction)btnUndoClicked:(id)sender {
    // NSLog(@"btnUndo : %ld", (long)[sender tag]);
    NSString *index = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    [dictHideSay setObject:@"isNoHide" forKey:index];
    //[self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)btnAddSayTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    chartState = ChartStateViewing;
    AddNewSayViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddNewSayViewController"];
    ProfileOwnerModel *model = [[ProfileOwnerModel alloc]init];
    model.Name = [profileDictionary objectForKey:@"name"];
    model.ProfileImage = [profileDictionary objectForKey:@"picture"];
    model.CoverImage = [profileDictionary objectForKey:@"cover_url"];
    model.UserID = requestedID;
    vc.model = model;
    vc.delegate = self;
    vc.colorDict = [AppDelegate sharedDelegate].colorDict;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnReportClicked:(id)sender {
    // NSLog(@"btnReport : %ld", (long)[sender tag]);
    ReportSayViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportSayViewController"];
    NSDictionary *dict = [saysArray objectAtIndex:[sender tag]];
    vc.say_id = [dict objectForKey:@"say_id"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnShareProfileClicked:(id)sender {
    // NSLog(@"btnShare : %ld", (long)[sender tag]);
    if (isFriendProfile == YES) {
        NSString *desc = [NSString stringWithFormat:@"%@'s friends think they're the most %@\nClick to find out what your friends think about you", [profileDictionary objectForKey:@"name"],[self getHighestTraits]];
        [self requestGetProfileImage:[sender tag] withDescription:desc andID:requestedID];
    }
    else {
        NSString *desc = [NSString stringWithFormat:@"%@'s friends think they're the most %@\nClick to find out what your friends think about you", [profileDictionary objectForKey:@"name"],[self getHighestTraits] ];
        [self requestGetProfileImage:[sender tag] withDescription:desc andID:[[AppDelegate sharedDelegate].profileOwner UserID]];
    }
    
}

- (IBAction)btnShareProfileToFacebookClicked:(id)sender {
    // NSLog(@"btnShare : %ld", (long)[sender tag]);
    if (isFriendProfile == YES) {
        NSString *desc = [NSString stringWithFormat:@"These are %@'s best traits \nClick to discover how charming you are", [profileDictionary objectForKey:@"name"]];
        [self requestGetProfileImage:[sender tag] withDescription:desc andID:requestedID];
    }
    else {
        NSString *desc = @"These are my best traits \nClick to discover how charming you are";
        [self requestGetProfileImage:[sender tag] withDescription:desc andID:[[AppDelegate sharedDelegate].profileOwner UserID]];
    }
}

- (IBAction)btnShareSayClicked:(id)sender {
    // NSLog(@"btnShare : %ld", (long)[sender tag]);
    NSDictionary *dict = [saysArray objectAtIndex:[sender tag]];
    // NSString *by = [dict objectForKey:@"by"];
    NSString *to = [profileDictionary objectForKey:@"name"];
    //    if ([[dict objectForKey:@"user_id"] isEqualToString:profileModel.UserID]) {
    //        by = @"I";
    //    }
    //    if ([[profileDictionary objectForKey:@"id"] isEqualToString:profileModel.UserID]) {
    //        to = @"Me";
    //    }
    NSString *desc = [NSString stringWithFormat:@"This is what people said about %@\nClick to find out what your friends said about you", to];
    [self requestGetSayImage:[dict objectForKey:@"say_id"] withDescription:desc isFB:NO];
    
}

- (IBAction)btnShareSayToFBClicked:(id)sender {
    // NSLog(@"btnShare : %ld", (long)[sender tag]);
    NSDictionary *dict = [saysArray objectAtIndex:[sender tag]];
    NSString *by = [dict objectForKey:@"by"];
    NSString *to = [profileDictionary objectForKey:@"name"];
    if ([[dict objectForKey:@"user_id"] isEqualToString:profileModel.UserID]) {
        by = @"I";
    }
    if ([[profileDictionary objectForKey:@"id"] isEqualToString:profileModel.UserID]) {
        to = @"Me";
    }
    NSString *desc = [NSString stringWithFormat:@"%@ Said This About %@ on Yousay", by, to];
    
    [self requestGetSayImage:[dict objectForKey:@"say_id"] withDescription:desc isFB:YES];
}


- (IBAction)btnLikesClicked:(id)sender {
    // NSLog(@"btnLikes : %ld", (long)[sender tag]);
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    if ([button isSelected]) {
        PeopleSayTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
        NSInteger likeCount = [[cell.likesLabel text] integerValue] + 1;
        [cell.likesLabel setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        [self requesLikeSay:sender];
    }
    else {
        PeopleSayTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
        NSInteger likeCount = [[cell.likesLabel text] integerValue] - 1;
        [cell.likesLabel setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        [self requesUnlikeSay:sender];
    }
}

- (IBAction)btnLikesCountClicked:(id)sender {
    PeopleSayTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
    likelistVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WhoLikeThisViewController"];
    likelistVC.delegate = self;
    
    NSDictionary *currentSaysDict = [saysArray objectAtIndex:[sender tag]];
    likelistVC.say_id = [currentSaysDict objectForKey:@"say_id"];
    [likelistVC.view setFrame:CGRectMake(likelistVC.view.frame.origin.x, likelistVC.view.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
    cell.tag = [sender tag]+1;
    likelistVC.section = [sender tag]+1;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush; //choose your animation
    [likelistVC.view.layer addAnimation:transition forKey:nil];
    [cell.viewLikeList addSubview:likelistVC.view];
    
    
    [cell.viewLikeList setHidden:NO];
}

-(IBAction)btnOpenMenu:(UIButton*)sender{
    [[SlideNavigationController sharedInstance]openMenu:MenuRight withCompletion:nil];
}

-(IBAction)btnDoneEdit:(UIButton*)sender{
    // do some logic
    [charmView endEditing];

   
    //[self.tableView reloadData];
   
    

    
}

-(void)afterDonebutton{
    
    
    
    chartState = ChartStateDefault;
    
    [self.tableView reloadData];
    
    [self performSelector:@selector(afterDonebuttonClicked) withObject:self afterDelay:2.0 ];


}

-(void)afterDonebuttonClicked{
  
        if (isFriendProfile) {
            chartState = ChartStateRate;
            [self loadSharePopUp:@"icn_awesome-1" Title:@"You just rated your friend anonymously!" SubTitle:@"Let them know about this" State:YES];
        }
        else{
            
            if(rateState==YES){
                
                 [self loadSharePopUp:@"icn_awesome-1" Title:@"Whoa! Your personality and looks score is super high!" SubTitle:@"Share with friends to get it even higher" State:YES];
            }
            
            else{
                
                  [self loadSharePopUp:@"icn_awesome-1" Title:@"You have new traits!" SubTitle:@"Ask your friends to rate you and become even more popular!" State:NO];
            }
            

        }

    
}

-(IBAction)btnCancelEdit:(UIButton*)sender{
    chartState = ChartStateDefault;
    [self.tableView reloadData];
}

-(IBAction)btnProfileClicked:(UIButton*)sender{
    isAfterCharm = NO;
    // NSLog(@"btnProfile : %ld", (long)[sender tag]);
    chartState = ChartStateViewing;
    if  (!isFriendProfile && [dictHideSay allKeys].count >0) {
        [self requestHideSay];
        chartState = ChartStateViewing;
    }
    PeopleSayTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]+1]];
    [cell.peopleSayTitleLabel setTextColor:[UIColor darkGrayColor]];
    NSDictionary *value = [saysArray objectAtIndex:[sender tag]];
    requestedID = [value objectForKey:@"user_id"];
    [self requestProfile:[value objectForKey:@"user_id"]];
}

-(void)StartRateMode{
    
    [charmView beginRatingOwnProfile];
}

- (void)EnableCharmRateMode {
    [charmView beginEditing];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (void)logout {
    FBSDKLoginManager *fb = [[FBSDKLoginManager alloc]init];
    [fb logOut];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"yousayuserid"];
    [defaults setObject:nil forKey:@"yousaytoken"];
    [AppDelegate sharedDelegate].ownerDict = nil;
    [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
}

- (void)hideImageAfterAnimation:(ProfileTableViewCell*)cell {
    [cell.imgHand setHidden:YES];
    
}

- (NSString*)getHighestTraits {
    NSString *highestTraits = @"";
    int rate = 0;
    for (int i=0; i<arrActiveCharm.count; i++) {
        NSDictionary *dict = arrActiveCharm[i];
        
        int currentRate = [[dict objectForKey:@"rate"] integerValue];
        if (currentRate >= rate) {
            highestTraits = [dict objectForKey:@"name"];
        }
        else {
            rate = currentRate;
        }
    }
    
    return [highestTraits lowercaseString];
}


#pragma mark - FBInviteDelegate
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"YouSay" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Chart Delegate
-(void)didBeginEditing:(CharmView *)charm{
    if (isFriendProfile) {
        chartState = ChartStateRate;
    }
    else{
        chartState = ChartStateEdit;
    }
    [self.tableView reloadData];
    
}

-(void)didBeginEditingRateOwnProfile:(CharmView *)charm{
    chartState = ChartStateRate;
    [self.tableView reloadData];
    
}

-(void)didEndEditing:(CharmView *)charm{
    if (charm.state == ChartStateRate) {
        [self requestEditCharm:charm];
    }
    else if (charm.state == ChartStateEdit) {
        chartState = ChartStateEdit;
        int counter = 0;
        for (int i= 0; i<5; i++) {
            NSDictionary *dict = [arrayOriginalCharm objectAtIndex:i];
            NSDictionary *dict2 = [arrayFilteredCharm objectAtIndex:i];
            
            if (![[dict objectForKey:@"name"] isEqualToString: [dict2 objectForKey:@"name"]]) {
                [self requestChangeCharm:[dict2 objectForKey:@"name"] andCharmOut:[dict objectForKey:@"name"]];
            }
            else {
                counter = counter+1;
            }
        }
        if (counter==5) {
            chartState = ChartStateDefault;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

-(void)showSelectionOfCharm:(NSArray*)charmNameAndIndex {
    charmIndexRow =  [[charmNameAndIndex objectAtIndex:1] integerValue];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    charmsSelection = [storyboard instantiateViewControllerWithIdentifier:@"SelectCharmsViewController"];
    charmsSelection.parent = self;
    charmsSelection.delegate = self;
    [charmsSelection setCharmOut:[charmNameAndIndex objectAtIndex:0]];
    [charmsSelection setActiveCharm:arrayFilteredCharm];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:charmsSelection];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - CharmSelectionDelegate

- (void) SelectCharmDidDismissed:(NSString*)charmIn {
    
    chartState = ChartStateEdit;
    if (charmIn) {
        for (NSDictionary *dict in charmsArray) {
            if ([[dict objectForKey:@"name"] isEqualToString:charmIn]) {
                if (arrActiveCharm.count > 0) {
                    [arrActiveCharm replaceObjectAtIndex:charmIndexRow withObject:dict];
                }
                [arrayFilteredCharm replaceObjectAtIndex:charmIndexRow withObject:dict];
                continue;
            }
            else {
                NSMutableDictionary *addNewDict = [[NSMutableDictionary alloc] init];
                [addNewDict setObject:charmIn forKey:@"name"];
                [addNewDict setObject:@"0" forKey:@"rate"];
                [addNewDict setObject:@"true" forKey:@"active"];
                [addNewDict setObject:@"false" forKey:@"rated"];
                if (arrActiveCharm.count > 0) {
                    [arrActiveCharm replaceObjectAtIndex:charmIndexRow withObject:addNewDict];
                }
                [arrayFilteredCharm replaceObjectAtIndex:charmIndexRow withObject:addNewDict];
                [charmsSelection setActiveCharm:arrActiveCharm];
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUserDefaults *firstTimeDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isNOTFirstTime = [firstTimeDefaults boolForKey:@"SAY_NOT_FIRSTTIME"];
    
    if(!isNOTFirstTime){
        CGPoint scrollViewOffset = scrollView.contentOffset;
        CGFloat minOffset = 350;
        if (IS_IPHONE_6){
            minOffset = 300;
        }
        else if(IS_IPHONE_6PLUS){
            minOffset = 280;
        }
        else if(IS_IPHONE_4){
            minOffset = 440;
        }
        
        if (scrollViewOffset.y > minOffset) {
            scrollViewOffset.y = minOffset;
            [scrollView setContentOffset:scrollViewOffset];
            
            CGFloat tip1y =  105;
            CGFloat tip2y =  340;
            CGFloat tip2x =  33;
            CGFloat tip3x =  100;
            
            if (IS_IPHONE_6) {
                tip1y = 215;
                tip2y = 440;
                tip2x = 33;
                tip3x = 110;
            }
            else if(IS_IPHONE_6PLUS){
                tip1y = 270;
                tip2y = 505;
                tip2x = 38;
                tip3x = 120;
            }
            else if(IS_IPHONE_4){
                tip1y = 70;
                tip2y = 240;
                tip2x = 33;
                tip3x = 100;
            }
            
            //TOOLTIP
            //3.
            if (!isFriendProfile && !tooltipIsVisible) {
                tooltipIsVisible = YES;
                UIView *background = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
                [background setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
                UIWindow* window = [UIApplication sharedApplication].keyWindow;
                if (!window)
                    window = [[UIApplication sharedApplication].windows objectAtIndex:0];
                [[[window subviews] objectAtIndex:0] addSubview:background];
                //tip
                UITooltip *tip1 = [[UITooltip alloc]initWithFrame:CGRectMake(((background.frame.size.width-210)/2), tip1y, 191, 90)];
                tip1.tipArrow = TipArrowBottomLeft;
                tip1.tooltipText = @"This is what your friends wrote about you\nLike and share their awesome says";
                [tip1 showToolTip:background];
                
                UITooltip *tip2 = [[UITooltip alloc]initWithFrame:CGRectMake(tip2x, tip2y+15, 181, 85 )];
                tip2.tipArrow = TipArrowBottomLeft;
                tip2.tooltipText = @"Click %i to like this say\nClick on the number next to it, to see who liked it already";
                tip2.imgMap = @{@"%i":@"Likes"};
                UITooltip *tip3 = [[UITooltip alloc]initWithFrame:CGRectMake(tip3x, tip2y+20, 170, 80)];
                tip3.tipArrow = TipArrowBottomLeft;
                tip3.tooltipText = @"Click %i to share this with your friends";
                tip3.imgMap = @{@"%i":@"shareProfile"};
                
                [tip1 onButtonTap:^{
                    [tip1 closeToolTip];
                    [tip2 showToolTip:background];
                }];
                
                [tip2 onButtonTap:^{
                    [tip2 closeToolTip];
                    [tip3 showToolTip:background];
                    
                }];
                
                [tip3 onButtonTap:^{
                    [tip3 closeToolTip];
                    [background removeFromSuperview];
                    tooltipIsVisible = NO;
                    [firstTimeDefaults setBool:YES forKey:@"SAY_NOT_FIRSTTIME"];
                    
                }];
            }
            
            //Friend Profile Say
            if(isFriendProfile && !tooltipIsVisible){
                tooltipIsVisible = YES;
                UIView *background = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
                [background setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
                UIWindow* window = [UIApplication sharedApplication].keyWindow;
                if (!window)
                    window = [[UIApplication sharedApplication].windows objectAtIndex:0];
                [[[window subviews] objectAtIndex:0] addSubview:background];
                //tip
                UITooltip *tip2 = [[UITooltip alloc]initWithFrame:CGRectMake(tip2x, tip2y+15, 181, 85)];
                tip2.tipArrow = TipArrowBottomLeft;
                tip2.tooltipText = @"Click %i to like this say\nClick on the number next to it, to see who liked it already";
                tip2.imgMap = @{@"%i":@"Likes"};
                [tip2 showToolTip:background];
                
                UITooltip *tip3 = [[UITooltip alloc]initWithFrame:CGRectMake(tip3x, tip2y+20, 170, 80)];
                tip3.tipArrow = TipArrowBottomLeft;
                tip3.tooltipText = @"Click %i to share this with your friends";
                tip3.imgMap = @{@"%i":@"shareProfile"};
                
                [tip2 onButtonTap:^{
                    [tip2 closeToolTip];
                    [tip3 showToolTip:background];
                    
                }];
                
                [tip3 onButtonTap:^{
                    [tip3 closeToolTip];
                    [background removeFromSuperview];
                    tooltipIsVisible = NO;
                    [firstTimeDefaults setBool:YES forKey:@"SAY_NOT_FIRSTTIME"];
                    
                }];
                
                
            }
        }
        
    }
    
    
    
    
    if (scrollView.contentOffset.y < -50) isScrollBounce = YES;
    if (fabs(scrollView.contentOffset.y) < 1 && isScrollBounce) {
        isScrollBounce = NO;
        [self requestProfile:[profileDictionary objectForKey:@"id"]];
    }
}

#pragma mark - AddNewSayDelegate

- (void)AddNewSayDidDismissed {
    isAfterAddNewSay = YES;
    _isAddSay = NO;
    
    if (_isRequestingProfile == NO) {
        NSMutableDictionary *event =
        [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                                action:@"AddSay"
                                                 label:@"AddSay"
                                                 value:nil] build];
        [[GAI sharedInstance].defaultTracker send:event];
        [[GAI sharedInstance] dispatch];
        
        if (requestedID) {
            [self requestProfile:requestedID];
            
        }
        else{
            [self requestProfile:[[AppDelegate sharedDelegate].profileOwner UserID]];
        }
        
    }
}

- (void) AddNewSayDidDismissedWithCancel {
    isFriendProfile = YES;
    _isAddSay = NO;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) refreshPage:(NSNotification *)notif {
    chartState = ChartStateDefault;
    if ([AppDelegate sharedDelegate].isFirstLoad == YES) {
        return;
    }
    else if ([[[AppDelegate sharedDelegate].profileOwner UserID] isEqualToString:requestedID]){
        profileDictionary = [AppDelegate sharedDelegate].ownerDict;
        [self.tableView reloadData];
    }
    else if (requestedID==nil){
        return;
    }
    else if ([[AppDelegate sharedDelegate].profileOwner UserID]) {
        [self requestProfile:[[AppDelegate sharedDelegate].profileOwner UserID]];
    }
}


#pragma mark LikeListDelegate
- (void) LikeListViewClosed:(NSString*)section {
    PeopleSayTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[section integerValue]]];
    CATransition *transition = [CATransition animation];
    transition.type =kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 0.5f;
    transition.delegate = self;
    [cell.viewLikeList.layer addAnimation:transition forKey:nil];
    [cell.viewLikeList setHidden:YES];
    cell.tag = 9999;
}


- (void) ListDismissedAfterClickProfile:(NSMutableDictionary*)data {
    if (data) {
        [self requestProfile:[data objectForKey:@"user_id"]];
        NSInteger section = [[data objectForKey:@"section"] integerValue];
        PeopleSayTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        [cell.viewLikeList setHidden:YES];
        cell.tag = 9999;
    }
    
}


- (void)dealloc {
    //[super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:vc animated:NO];
    return NO;
}

#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (isAfterShareFB == YES) {
        isAfterShareFB = NO;
        [self.txtSearch setText:@""];
        [self.txtSearch resignFirstResponder];
    }
}

#pragma mark FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    isAfterShareFB = YES;
    if (isProfileShared == YES) {
        [self requestProfileShared:profileShared];
    }
    else {
        [self requestSayShared:sayShared];
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    isAfterShareFB = YES;
    [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error!", nil) message:NSLocalizedString(@"There is an error while sharing! Please try Again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil]show];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    //HideLoader();
    isAfterShareFB = YES;
    [self keyboardWillHide:nil];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == shareSayTag) {
        alertView.tag = 0;
        [self btnShareSayToFBClicked:alertView];
    }
    else if (buttonIndex == 1 && alertView.tag == shareAfterRateTag) {
        alertView.tag = 1000;
        [self btnShareProfileToFacebookClicked:alertView];
    }
}

@end

