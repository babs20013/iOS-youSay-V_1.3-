//
//  ViewController.m
//  youSay
//
//  Created by macbokpro on 10/20/15.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"
#import "JSONDictionaryExtensions.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "MainPageViewController.h"
#import "ProfileOwnerModel.h"
#import "RequestModel.h"
#import "ProfileViewController.h"
#import "CommonHelper.h"
#import "UIImageView+Networking.h"
#import <BFAppLinkReturnToRefererView.h>
#import <BFAppLinkReturnToRefererController.h>

@interface ViewController ()
{
    NSString * accessToken;
    NSString * fbID;
    FBSDKAccessToken *currentToken;
    ProfileOwnerModel *profileModel;
    NSDictionary *profileDict;
    NSDictionary *colorDict;
    BOOL isNewRegister;
    NSString *tempToken;
    CGRect screenRect;
    PageControl *pageControl;
    UIImageView *cover1;
    UIButton *btnSkipDone;
    int counter;
    BOOL timedOut;
}
@property (weak, nonatomic) BFAppLinkReturnToRefererView *appLinkReturnToRefererView;
@property (strong, nonatomic) BFAppLink *appLink;
@end

@implementation ViewController

@synthesize scrollView;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.appLinkReturnToRefererView) {
        self.appLinkReturnToRefererView.hidden = YES;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.parsedUrl) {
        self.appLink = [delegate.parsedUrl appLinkReferer];
        [self _showRefererBackView];
    }
    delegate.parsedUrl = nil;
}

- (void) _showRefererBackView {
    if (nil == self.appLinkReturnToRefererView) {
        // Set up the back link navigation view
        BFAppLinkReturnToRefererView *backLinkView  = [[BFAppLinkReturnToRefererView alloc] initWithFrame:CGRectMake(0, 30, 320, 40)];
        self.appLinkReturnToRefererView = backLinkView;
    }
    self.appLinkReturnToRefererView.hidden = NO;
    // Initialize the back link view controller
    BFAppLinkReturnToRefererController *alc =[[BFAppLinkReturnToRefererController alloc] init];
    alc.view = self.appLinkReturnToRefererView;
    // Display the back link view
    [alc showViewForRefererAppLink:self.appLink];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    counter = 0;
    timedOut = NO;
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                            action:@"app_launched"
                                             label:@"app_launched"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    accessToken = @"";
    if ([[FBSDKAccessToken currentAccessToken].expirationDate compare:[NSDate date]] == NSOrderedDescending) {
        [self goToMainPage];
    }
    else if ([[FBSDKAccessToken currentAccessToken].expirationDate compare:[NSDate date]] == NSOrderedAscending ) {
        [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (result) {
                [self goToMainPage];
            }
        }];
    }
    else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"yousayid"]) {
                [self showWalkthrough];
        }
    }
}

- (void)showWalkthrough {
    // Do any additional setup after loading the view.
    screenRect = [[UIScreen mainScreen] bounds];
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    scrollView.delegate = self;
    scrollView.canCancelContentTouches = NO;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    [scrollView setContentSize:CGSizeMake(screenRect.size.width*4, screenRect.size.height)];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    
    pageControl = [[PageControl alloc] initWithFrame:CGRectMake(0, screenRect.size.height-30, screenRect.size.width, 15)] ;
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 0;
    pageControl.delegate = self;
    pageControl.dotColorCurrentPage = [UIColor clearColor];
    pageControl.dotColorOtherPage = [UIColor clearColor];
    
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];
    
    btnSkipDone = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width-80, screenRect.size.height-50, 80, 40)];
    btnSkipDone.backgroundColor = [UIColor clearColor];
    [btnSkipDone addTarget:self action:@selector(btnSkipDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnSkipDone];
    
    [self setupCover];
}

-(void)setupCover{
    UIImage *img1 = [UIImage imageNamed:@"Walkthrough1"];
    cover1 = [[UIImageView alloc]initWithImage:img1];
    cover1.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    [self.scrollView addSubview:cover1];
    
    UIImage *img2 = [UIImage imageNamed:@"Walkthrough2"];
    UIImageView *cover2 = [[UIImageView alloc]initWithImage:img2];
    cover2.frame = CGRectMake(screenRect.size.width*1, 0, screenRect.size.width, screenRect.size.height);
    [self.scrollView addSubview:cover2];
    
    UIImage *img3 = [UIImage imageNamed:@"Walkthrough3"];
    UIImageView *cover3 = [[UIImageView alloc]initWithImage:img3];
    cover3.frame = CGRectMake(screenRect.size.width*2,0, screenRect.size.width, screenRect.size.height);
    [self.scrollView addSubview:cover3];
    
    UIImage *img4 = [UIImage imageNamed:@"Walkthrough4"];
    UIImageView *cover4 = [[UIImageView alloc]initWithImage:img4];
    cover4.frame = CGRectMake(screenRect.size.width*3,0, screenRect.size.width, screenRect.size.height);
    [self.scrollView addSubview:cover4];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSkipDoneClicked:(id)sender {
    [pageControl removeFromSuperview];
    [scrollView removeFromSuperview];
    [btnSkipDone removeFromSuperview];
}

- (void)goToMainPage {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
    vc.profileDictionary = profileDict;
    vc.colorDictionary = colorDict;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)faceBookAction:(id)sender {
    [AppDelegate sharedDelegate].isFirstLoad = YES;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
     //   NSLog(@"There is no internet connection");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERR_MSG_TITLE_SORRY
                                                        message:ERR_MSG_NO_INTERNET
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        tempToken = [FBSDKAccessToken currentAccessToken].tokenString;
   //     NSLog(@"There IS internet connection");
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        login.loginBehavior = FBSDKLoginBehaviorNative;
        [login logInWithReadPermissions:@[@"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error){
            if (error) {
                // Process error
            } else if (result.isCancelled) {
                // Handle cancellations
            }
            else {
                //--TODO - Check for new register-- this is only temporary solution
                if (tempToken == nil) {
                    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                                                                         action:@"new_registration"
                                                                                          label:@"new_registration"
                                                                                          value:nil] build];
                    [[GAI sharedInstance].defaultTracker send:event];
                    [[GAI sharedInstance] dispatch];
                }
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                accessToken = [FBSDKAccessToken currentAccessToken].tokenString;
                if([accessToken isKindOfClass:[NSString class]]){
                    [self goToMainPage];
                }
                HideLoader();
            }
        }];
    }
}


- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

#pragma mark - FBInviteDelegate
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"YouSay" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mark - Activate Staging / Production
- (IBAction)buttonClicked:(id)sender
{
    //--Production doesnt need this
    /*
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(timedOut)
                                   userInfo:nil
                                    repeats:NO];
    if (++counter >= 5) {
        NSLog(@"User clicked button 5 times within 3 secs");
        
        // for nitpickers
        timedOut = NO;
        counter = 0;
        [URL setHTTPServer];
        
        if ([HTTP_URL_SERVER isEqualToString:HTTP_PRODUCTION]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Yousay" message:@"You are now working on the production server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Yousay" message:@"You are now working on the staging server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }*/
//    if ((++counter >= 5) && !timedOut) {
//        NSLog(@"User clicked button 5 times within 3 secs");
//        
//        // for nitpickers
//        timedOut = NO;
//        counter = 0;
//    }
}

- (void)timedOut
{
    timedOut = YES;
}

@end
