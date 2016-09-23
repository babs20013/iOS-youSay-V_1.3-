//
//  MainPageViewController.m
//  youSay
//
//  Created by Baban on 06/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "MainPageViewController.h"
#import "AppDelegate.h"


@interface MainPageViewController (){
    NSUInteger numberOfTabs;
    BOOL isClick;
    BOOL isSameTab;
}

@end

@implementation MainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reload)
                                                 name:kNotificationUpdateNotification
                                               object:nil];
    numberOfTabs = 3;
    
    self.dataSource = self;
    self.delegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reload{
    [self reloadTab];
}
#pragma mark - ViewPagerDataSource

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return numberOfTabs;
}
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    NSString *notif = [NSString stringWithFormat:@"Notications %ld",(long)[AppDelegate sharedDelegate].num_of_new_notifications];
    
    NSString *notifications = @"Notications";
    NSString *count = [NSString stringWithFormat:@"%ld",(long)[AppDelegate sharedDelegate].num_of_new_notifications];
    
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithString:notif];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithRed:1.0 green:0.8 blue:0.4 alpha:1.0]
                 range:NSMakeRange(notifications.length+1,count.length)];
    NSAttributedString *feed = [[NSAttributedString alloc]initWithString:@"Feed"];
    NSAttributedString *profile = [[NSAttributedString alloc]initWithString:@"Profile"];
    NSArray *arrTabString = [NSArray arrayWithObjects:feed, profile, text, nil];
    
    UILabel *label = [UILabel new];
    label.attributedText = text;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:12.0];
    label.textColor = [UIColor whiteColor];
    label.attributedText = [arrTabString objectAtIndex:index];
    label.textAlignment = NSTextAlignmentLeft;
    
    [label sizeToFit];
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    if(index == 0){
        FeedViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
        if (isClick == YES) {
            isClick = NO;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"refreshpage" object:nil];
        }
        
       return cvc;
        
    }
    else if (index == 1){
        ProfileViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        cvc.colorDictionary = self.colorDictionary;
        cvc.profileDictionary = self.profileDictionary;
        cvc.isFriendProfile = _isFriendProfile;
        cvc.isFromFeed = _isFromFeed;
        cvc.friendModel = _friendModel;
        cvc.profileModel = _profileModel;
        cvc.isSameTab = isSameTab;
        cvc.isAddSay = _isAddSay;
        cvc.saysID = _sayID;
       // NSLog(@"sayID dr main page = %@", _sayID);
        
        if (_isFromFeed == YES && _friendModel == nil) {
            _isFromFeed = NO;
            [cvc requestProfile:_requestedID];
        }
        else if (_isFromFeed == YES && _friendModel){
            if (_friendModel.isNeedProfile == YES) {
                NSString *string = [NSString stringWithFormat:@"%@?fields=cover",_friendModel.userID];
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                              initWithGraphPath:string
                                              parameters:nil
                                              HTTPMethod:@"GET"];
                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                      id result,
                                                      NSError *error) {
                    NSDictionary *dict = result;
                    _friendModel.CoverImage = [[dict objectForKey:@"cover"] objectForKey:@"source"];
                    if (_friendModel.CoverImage == nil) {
                        _friendModel.CoverImage = @"";
                    }
                    [cvc requestCreateProfile:_friendModel];
                    
                }];
            }
            else {
                [cvc requestProfile:_friendModel.userID];
            }
        }
        else if (isClick == YES && _isFromFeed == NO && _requestedID == nil && isSameTab == YES) {
            [cvc setIsFriendProfile:NO];
            cvc.isFromFeed = NO;
            isClick = NO;
            
            cvc.requestedID = nil;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"notification" object:nil];
        }
        return cvc;
    }
    else if (index == 2){
        NotificationViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
        return cvc;
    }
    else {
        UIViewController *vc= [[UIViewController alloc]init];
        return vc;
    }
}


#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 1.0;
        case ViewPagerOptionCenterCurrentTab:
            return 0.0;
        case ViewPagerOptionTabLocation:
            return 0.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 0.0;
        case ViewPagerOptionTabWidth:
            return self.view.frame.size.width/numberOfTabs;
        case ViewPagerOptionFixFormerTabsPositions:
            return 0.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 0.0;
        default:
            return value;
    }
}
- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [UIColor colorWithRed:236/255.f green:157/255.f blue:18/255.f alpha:1];
        case ViewPagerTabsView:
            return [UIColor colorWithRed:0/255.f green:172/255.f blue:196/255.f alpha:1];
        case ViewPagerContent:
            return [UIColor whiteColor];
        default:
            return color;
    }
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index didSwipe:(BOOL)swipe isFromSameTab:(BOOL)tab {
    if (index==1) {
        isSameTab = tab;
        _requestedID = nil;
        isClick = YES;
        _isFromFeed = NO;
        [self viewPager:viewPager contentViewControllerForTabAtIndex:index];
    }
    else if (index==0 && tab == YES) {
        _requestedID = nil;
        isClick = YES;
        [self viewPager:viewPager contentViewControllerForTabAtIndex:index];
    }
   // NSLog(@"index %lu", (unsigned long)index);
}

@end
