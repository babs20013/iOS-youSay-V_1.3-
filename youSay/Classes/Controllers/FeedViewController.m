//
//  FeedViewController.m
//  youSay
//
//  Created by Baban on 26/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedTableViewCell.h"
#import "UIImageView+Networking.h"
#import "AppDelegate.h"
#import "CommonHelper.h"
#import "SlideNavigationController.h"
#import "ProfileViewController.h"
#import "MainPageViewController.h"
#import "ViewPagerController.h"
#import "ReportSayViewController.h"
#import "WhoLikeThisViewController.h"
#import "CustomActivityProvider.h"
#import "SearchViewController.h"

#define kColorSearch [UIColor colorWithRed:42.0/255.0 green:180.0/255.0 blue:202.0/255.0 alpha:1.0]


@interface FeedViewController ()
{
    
    BOOL isScrollBounce;
    int index;
    BOOL isNoMoreFeed;
    BOOL isLikeListReleased;
    BOOL isRequesting;
    NSString *sayShared;
    NSString *profile;
    BOOL isAfterShareFB;
    WhoLikeThisViewController *likeListVC;
}


@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField * txtSearch;
@end

@implementation FeedViewController

@synthesize arrayFeed;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isScrollBounce = YES;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self requestFeed:[NSString stringWithFormat:@"%i", index]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"Feed";
    isLikeListReleased = NO;
    arrayFeed = [[NSMutableArray alloc]init];
    index = 1;
    
    UIImageView *imgMagnifyingGlass = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 15, 15)];
    imgMagnifyingGlass.image = [UIImage imageNamed:@"search"];
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [leftView addSubview:imgMagnifyingGlass];
    self.txtSearch.leftView = leftView;
    self.txtSearch.textColor = [UIColor whiteColor];
    self.txtSearch.leftViewMode = UITextFieldViewModeAlways;
    self.txtSearch.layer.cornerRadius = round(self.txtSearch.frame.size.height / 2);
    self.txtSearch.layer.borderWidth = 1;
    self.txtSearch.layer.borderColor = kColorSearch.CGColor;
    self.txtSearch.autocorrectionType = UITextAutocorrectionTypeNo;
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Search your friends" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.txtSearch.attributedPlaceholder = str;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Request

- (void)requestFeed:(NSString*)startFrom {
    
    isRequesting = YES;
    
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    
    [dictRequest setObject:REQUEST_FEED forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token]  forKey:@"token"];
    [dictRequest setObject:@"yousay_ios" forKey:@"app_name"];
    [dictRequest setObject:@"1.0" forKey:@"app_version"];
    [dictRequest setObject:@"10" forKey:@"max_items"];
    [dictRequest setObject:startFrom forKey:@"start_from"];
    [dictRequest setObject:@"1" forKey:@"sort"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        HideLoader();
        isRequesting = NO;
        if (result)
        {
            isScrollBounce = YES;
            NSDictionary *dictResult = result;
            
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                index = index+10;
                NSArray *arrResult = [dictResult objectForKey:@"items"];
                if (arrResult.count == 0) {
                    isNoMoreFeed = YES;
                }
                [arrayFeed addObjectsFromArray:arrResult];
                [self.tableView reloadData];
                if ([startFrom integerValue] == 1 && arrResult.count > 0) {
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

- (void)requesLikeSay:(id)sender{
    NSMutableDictionary *feedDict = [[NSMutableDictionary alloc]init];
    feedDict = [[arrayFeed objectAtIndex:[sender tag]] mutableCopy];
    
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
                [feedDict setObject:@"yes" forKey:@"like_status"];
                [feedDict setObject:[NSNumber numberWithInteger:count] forKey:@"like_count"];
                [arrayFeed replaceObjectAtIndex:[sender tag] withObject:feedDict];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:[sender tag]]] withRowAnimation:UITableViewRowAnimationNone];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
                [cell.btnLikes setSelected:NO];
                NSInteger likeCount = [[cell.lblLikes text]integerValue] - 1;
                [cell.lblLikes setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
            }
        }
        else if (error)
        {
            FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
            [cell.btnLikes setSelected:NO];
            NSInteger likeCount = [[cell.lblLikes text]integerValue] - 1;
            [cell.lblLikes setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        }
        else{
            FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
            [cell.btnLikes setSelected:NO];
            NSInteger likeCount = [[cell.lblLikes text]integerValue] - 1;
            [cell.lblLikes setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        }
    }];
}

- (void)requesUnlikeSay:(id)sender{
    NSMutableDictionary *feedDict = [[NSMutableDictionary alloc]init];
    feedDict = [[arrayFeed objectAtIndex:[sender tag]] mutableCopy];
    
    
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
                [feedDict setObject:@"no" forKey:@"like_status"];
                [feedDict setObject:[NSNumber numberWithInteger:count] forKey:@"like_count"];
                [arrayFeed replaceObjectAtIndex:[sender tag] withObject:feedDict];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:[sender tag]]] withRowAnimation:UITableViewRowAnimationNone];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
                [cell.btnLikes setSelected:YES];
                NSInteger likeCount = [[cell.lblLikes text]integerValue] + 1;
                [cell.lblLikes setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
            }        }
        else if (error)
        {
            FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
            [cell.btnLikes setSelected:YES];
            NSInteger likeCount = [[cell.lblLikes text]integerValue] + 1;
            [cell.lblLikes setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        }
        else{
            FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
            [cell.btnLikes setSelected:YES];
            NSInteger likeCount = [[cell.lblLikes text]integerValue] + 1;
            [cell.lblLikes setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        }
    }];
}

- (void)requestGetSayImage:(NSString *)sayID withDescription:(NSString*)desc isFB:(BOOL)isFacebook{
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_GET_SAY_IMG forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:sayID forKey:@"say_id"];
    sayShared = sayID;
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                if (isFacebook == YES) {
                    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                    NSString *url = [NSString stringWithFormat:@"https://go.onelink.me/3683706271?pid=ios&c=say%@&af_dp=yousay://&af_web_dp=http://yousayweb.com&af_force_dp=true&profile=%@&sayid=%@",[dictResult valueForKey:@"selected_image"], profile, sayID];
                    
                    //MM-- Specify title and desc specifically for facebook
                    NSString *title = [dictResult valueForKey:@"say_facebook_share_line1"];
                    NSString *description = [NSString stringWithFormat:@"%@", [dictResult valueForKey:@"say_facebook_share_line2"]];
                    
                    content.contentTitle = title;
                    content.imageURL = [NSURL URLWithString:[dictResult objectForKey:@"url"]];
                    content.contentURL = [NSURL URLWithString:url];
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
                    NSString *url = [NSString stringWithFormat:@"https://go.onelink.me/3683706271?pid=ios&c=say%@&af_dp=yousay://&af_web_dp=http://yousayweb.com&af_force_dp=true&is_retargeting=true&profile=%@&sayid=%@",[dictResult valueForKey:@"selected_image"], profile, sayID];
                    ShowLoader();
                    [imgView setImageURL:[NSURL URLWithString:[dictResult objectForKey:@"url"]] withCompletionBlock:^(BOOL succes, UIImage *image, NSError *error) {
                        HideLoader();
                        CustomActivityProvider *activityProvider = [[CustomActivityProvider alloc]initWithPlaceholderItem:@""];
                        activityProvider.urlString = url;
                        //--Change share 23 May 2016
                        NSString *shareText = [dictResult valueForKey:@"say_generic_share"];
                        
                        NSArray *activityItems = [NSArray arrayWithObjects:image, activityProvider, shareText, nil];
                        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                        activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        [self presentViewController:activityViewController animated:YES completion:nil];
                        
                        [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
                            if (!completed) return;
                            [self requestSayShared:sayShared];
                        }];
                        
                        
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


#pragma mark UITableView

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *currentSaysDict = [arrayFeed objectAtIndex:indexPath.section];
    NSArray *arrProfiles = [currentSaysDict objectForKey:@"profiles"];
    if (arrProfiles.count == 1) {
        return 115;
    }
    else if (arrProfiles.count == 0){
        return 0;
    }
    return 289;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSDictionary *currentSaysDict = [arrayFeed objectAtIndex:section];
    NSArray *arrProfiles = [currentSaysDict objectForKey:@"profiles"];
    if (arrProfiles.count == 0) {
        return 0;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc]init];
    footerView.backgroundColor = [UIColor colorWithRed:180.0/255.0 green:185.0/255.0 blue:187.0/255.0 alpha:1.0];
    return footerView;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return arrayFeed.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self consctructTableForFeed:tableView withIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (UITableViewCell*)consctructTableForFeed:(UITableView*)tableView withIndexPath:(NSIndexPath*)indexPath {
    static NSString *cellIdentifier = @"FeedTableViewCell";
    
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[FeedTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.clipsToBounds = YES;
   // NSLog(@"tag = %d", cell.tag);
    
    NSDictionary *currentSaysDict = [arrayFeed objectAtIndex:indexPath.section];
    NSArray *arrProfiles = [currentSaysDict objectForKey:@"profiles"];
    NSString *string = [currentSaysDict valueForKey:@"feed_message"];
    CGSize expectedSize = [CommonHelper expectedSizeForString:string width:tableView.frame.size.width-65 font:[UIFont fontWithName:@"Arial" size:14] attributes:nil];
    
    
    [cell.btnLikeCount setTag:indexPath.section];
    
    if (arrProfiles.count>0) {
        NSDictionary *profile1 = [arrProfiles objectAtIndex:0];
        NSURL *avatar = [NSURL URLWithString:[profile1 objectForKey:@"avatar"]];
        if  (avatar && [avatar scheme] && [avatar host]) {
            [cell.imgViewProfile1 setImageURL:avatar];
        }
        else {
            [cell.imgViewProfile1 setImageURL:[NSURL URLWithString:@"http://2.bp.blogspot.com/-6QyJDHjB5XE/Uscgo2DVBdI/AAAAAAAACS0/DFSFGLBK_fY/s1600/facebook-default-no-profile-pic.jpg"]];
        }
        
        cell.imgViewProfile1.layer.cornerRadius = 0.5 * cell.imgViewProfile1.bounds.size.width;
        cell.imgViewProfile1.layer.masksToBounds = YES;
        cell.imgViewProfile1.layer.borderWidth = 1;
        cell.imgViewProfile1.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        
        cell.viewMore.layer.cornerRadius = 0.03 * cell.viewMore.bounds.size.width;
        cell.viewMore.layer.masksToBounds = YES;
        cell.viewMore.layer.borderWidth = 1;
        cell.viewMore.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        [cell.viewMore.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        cell.lblSaidAbout.text = [profile1 objectForKey:@"name"];
        [cell.btnProfile1 setTag:indexPath.section];
        [cell.btnLblProfile1 setTag:indexPath.section];
        [cell.btnReport setTag:indexPath.section];
        [cell.btnReportLabel setTag:indexPath.section];
        [cell.btnShare setTag:indexPath.section];
        [cell.btnShareFB setTag:indexPath.section];
        [cell.btnDot setTag:indexPath.section];
        
    }
    
    if (arrProfiles.count == 0) {
        [cell.lblSaidAbout setText:@""];
        [cell.lblSaidAbout2 setText:@""];
        [cell.viewBottom setHidden:YES];
        [cell.lbl1ProfileSay setHidden:YES];
        [cell.imgViewProfile1 setHidden:YES];
        [cell.imgViewProfile2 setHidden:YES];
        [cell.lblDate setHidden:YES];
        [cell.btnAddSay setHidden:YES];
        if (string == nil) {
            [cell.viewSays setHidden:YES];
        }
    }
    
    if (arrProfiles.count == 1) {
        [cell.imgViewProfile1 setHidden:NO];
        [cell.lblSaidAbout setHidden:YES];
        [cell.imgViewProfile2 setHidden:YES];
        [cell.lblSaidAbout2 setHidden:YES];
        [cell.viewSays setHidden:YES];
        [cell.viewBottom setHidden:YES];
        [cell.lbl1ProfileSay setHidden:NO];
        [cell.lblDate setHidden:YES];
        [cell.btnAddSay setHidden:NO];
        [cell.btnAddSay setTag:indexPath.section];
        
        NSDictionary *profile1 = [arrProfiles objectAtIndex:0];
        NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:[[currentSaysDict valueForKey:@"feed_title"] stringByReplacingOccurrencesOfString:@"%1" withString:[profile1 objectForKey:@"name"]]];
        if (attributedText == nil){
            attributedText = [[NSAttributedString alloc]initWithString:@""];
        }
        cell.lbl1ProfileSay.attributedText = attributedText;
    }
    else if (arrProfiles.count == 2){
        [cell.lbl1ProfileSay setHidden:YES];
        [cell.imgViewProfile1 setHidden:NO];
        [cell.imgViewProfile2 setHidden:NO];
        [cell.lblSaidAbout2 setHidden:NO];
        [cell.viewSays setHidden:NO];
        [cell.viewBottom setHidden:NO];
        [cell.btnAddSay setHidden:YES];
        [cell.lblSaidAbout setHidden:NO];
        [cell.lblDate setHidden:NO];
        
        [cell.btnLikes setTag:indexPath.section];
        
        if ([[currentSaysDict objectForKey:@"like_status"] isEqualToString:@"yes"]) {
            [cell.btnLikes setSelected:YES];
        }
        else {
            [cell.btnLikes setSelected:NO];
        }
        [cell.viewSays setFrame:CGRectMake(cell.viewSays.frame.origin.x, cell.viewSays.frame.origin.y, cell.viewSays.frame.size.width, expectedSize.height)];
        
        NSDictionary *profile2 = [arrProfiles objectAtIndex:1];
        string = [string stringByReplacingOccurrencesOfString:@"%2"
                                                   withString:@""];
        [cell.lblSaidAbout2 setText:[profile2 objectForKey:@"name"]];
        [cell.lblSaidAbout2 setNumberOfLines:0];
        if (![profile2 objectForKey:@"name"]) {
            [cell.lblSaidAbout2 setText:@""];
        }
        
        cell.lblSaidAbout.text = [cell.lblSaidAbout.text stringByReplacingOccurrencesOfString:@"%2" withString:@""];
        [cell.btnProfile2 setTag:indexPath.section];
        [cell.btnLblProfile2 setTag:indexPath.section];
    }
    NSString *key = [NSString stringWithFormat:@"%@",[currentSaysDict objectForKey:@"say_color"]];
    if ([key isEqualToString:@"(null)"]){
        key = [NSString stringWithFormat:@"%@",[currentSaysDict objectForKey:@"color"]];
    }
    NSDictionary *dicColor = [AppDelegate sharedDelegate].colorDict;
    NSDictionary *indexDict = [dicColor objectForKey:key];
    
    [cell setBackgroundColor:[self colorWithHexString: [indexDict objectForKey:@"back"]]];
    
    [cell.lblSays setFrame:CGRectMake(cell.lblSays.frame.origin.x, cell.lblSays.frame.origin.y, cell.lblSays.frame.size.width, expectedSize.height)];
    [cell.lblSays setTextColor:[self colorWithHexString:[indexDict objectForKey:@"fore"]]];
    cell.lblSays.text = string;
    cell.lblDate.text = [currentSaysDict valueForKey:@"time_ago"];
    cell.lblLikes.text = [NSString stringWithFormat:@"%@", [currentSaysDict valueForKey:@"like_count"]];
    
    if ([cell.lblLikes.text integerValue] < 1) {
        [cell.btnLikeCount setEnabled:NO];
    }
    else {
        [cell.btnLikeCount setEnabled:YES];
    }
    
    if (cell.tag == indexPath.section+1) {
        [cell.viewMore setHidden:NO];
        [cell.btnDot setSelected:YES];
    }
    else {
        [cell.viewMore setHidden:YES];
        [cell.btnDot setSelected:NO];
    }
    
    if (cell.tag == indexPath.section+999) {
        [cell.viewLikeList setHidden:NO];
    }
    else {
        [cell.viewLikeList setHidden:YES];
    }
    cell.layer.cornerRadius = 0.015 * cell.bounds.size.width;
    cell.layer.masksToBounds = YES;
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    if (hex == nil) {
        NSArray *arrRandomColor = [[NSArray alloc]initWithObjects:@"#473C8B", @"#F4A460", @"#FA8072", @"#DC143C", @"#D2691E", @"#C71585", @"#A52A2A", @"#8FBC8F", nil];
        int r = arc4random() % [arrRandomColor count];
        hex = [arrRandomColor objectAtIndex:r];
    }
    
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    cString = [cString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor colorWithRed:237.0/255.0 green:155.0/255.0 blue:73.0/255.0 alpha:1.0];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor colorWithRed:237.0/255.0 green:155.0/255.0 blue:73.0/255.0 alpha:1.0];
    
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

-(IBAction)btnOpenMenu:(UIButton*)sender{
    [[SlideNavigationController sharedInstance]openMenu:MenuRight withCompletion:nil];
}

-(IBAction)btnLikesClicked:(UIButton*)sender{
  //  NSLog(@"btnLikes : %ld", (long)[sender tag]);
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    if ([button isSelected]) {
        FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
        NSInteger likeCount = [[cell.lblLikes text] integerValue] + 1;
        [cell.lblLikes setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        [self requesLikeSay:sender];
    }
    else {
        FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
        NSInteger likeCount = [[cell.lblLikes text] integerValue] - 1;
        [cell.lblLikes setText:[NSString stringWithFormat:@"%li", (long)likeCount]];
        [self requesUnlikeSay:sender];
    }
}

- (IBAction)btnReportClicked:(id)sender {
    ReportSayViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportSayViewController"];
    NSDictionary *dict = [arrayFeed objectAtIndex:[sender tag]];
    vc.say_id = [dict objectForKey:@"say_id"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnLikeCountClicked:(id)sender {
    FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
    
    likeListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WhoLikeThisViewController"];
    likeListVC.delegate = self;
    likeListVC.section = [sender tag];
    NSDictionary *currentDixt = [arrayFeed objectAtIndex:[sender tag]];
    likeListVC.say_id = [currentDixt objectForKey:@"say_id"];
    [likeListVC.view setFrame:CGRectMake(likeListVC.view.frame.origin.x, likeListVC.view.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
    [cell setTag:[sender tag]+999];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush; //choose your animation
    [likeListVC.view.layer addAnimation:transition forKey:nil];
    [cell.viewLikeList addSubview:likeListVC.view];
    [cell.viewLikeList setHidden:NO];
}

- (void) refreshFeed:(NSNotification *)notif {
    arrayFeed = [[NSMutableArray alloc]init];
    index = 1;
    isNoMoreFeed = NO;
    if (isRequesting == NO) {
        [self requestFeed:[NSString stringWithFormat:@"%i", index]];
    }
}

- (IBAction)btnAddSayClicked:(id)sender {
    
    NSDictionary *currentSaysDict = [arrayFeed objectAtIndex:[sender tag]];
    NSArray *arrProfiles = [currentSaysDict objectForKey:@"profiles"];
    NSDictionary *profileDictionary = [arrProfiles objectAtIndex:0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
    vc.isFriendProfile = YES;
    vc.isFromFeed = YES;
    vc.isAddSay = YES;
    vc.requestedID = [profileDictionary objectForKey:@"profile_id"];
    vc.colorDictionary = [AppDelegate sharedDelegate].colorDict;
    vc.profileModel = [AppDelegate sharedDelegate].profileOwner;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnDotlicked:(id)sender {
    UIButton *button = (UIButton*)sender;
    FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
    if (button.selected == NO) {
        [cell.viewMore setHidden:NO];
        [cell.btnDot setSelected:YES];
        cell.tag = [sender tag]+1;
    }
    else {
        [cell.viewMore setHidden:YES];
        [cell.btnDot setSelected:NO];
        cell.tag = 50000;
    }
}

#pragma mark - ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) && isScrollBounce) {
        if (!isNoMoreFeed) {
            isScrollBounce = NO;
            [self requestFeed:[NSString stringWithFormat:@"%i", index]];
        }
    }
    //    if (likeListVC) {
    //        [likeListVC.view removeFromSuperview];
    //    }
}

-(IBAction)btnProfile1Clicked:(UIButton*)sender{
    [self highlightProfileName1:sender];
}

-(IBAction)btnProfile2Clicked:(UIButton*)sender{
    [self highlightProfileName2:sender];
}

-(IBAction)btnLblProfile1Clicked:(UIButton*)sender{
    [self highlightProfileName1:sender];
}

-(IBAction)btnLblProfile2Clicked:(UIButton*)sender{
    [self highlightProfileName2:sender];
}

- (IBAction)btnShareSayClicked:(id)sender {
   // NSLog(@"btnShare : %ld", (long)[sender tag]);
    NSDictionary *currentSaysDict = [arrayFeed objectAtIndex:[sender tag]];
    NSArray *arrProfiles = [currentSaysDict objectForKey:@"profiles"];
    NSDictionary *dictProfile1 = [arrProfiles objectAtIndex:0];
    NSDictionary *dictProfile2 = [arrProfiles objectAtIndex:1];
    NSString *desc = [NSString stringWithFormat:@"This is what people said about %@\nClick to find out what your friends said about you", [dictProfile2 objectForKey:@"name"]];
    if ([[dictProfile2 objectForKey:@"name"] isEqualToString:[[AppDelegate sharedDelegate].profileOwner Name]]) {
        desc = [NSString stringWithFormat:@"This is what people said about %@\nClick to find out what your friends said about you", [dictProfile1 objectForKey:@"name"]];
        profile = [[AppDelegate sharedDelegate].profileOwner UserID];
    }
    else if ([[dictProfile1 objectForKey:@"name"] isEqualToString:[[AppDelegate sharedDelegate].profileOwner Name]]){
        desc = [NSString stringWithFormat:@"This is what people said about %@\nClick to find out what your friends said about you", [dictProfile2 objectForKey:@"name"]];
        profile = [dictProfile2 objectForKey:@"profile_id"];
    }
    else {
        profile = [dictProfile2 objectForKey:@"profile_id"];
    }
    [self requestGetSayImage:[currentSaysDict objectForKey:@"say_id"] withDescription:desc isFB:NO];
    
}

- (IBAction)btnShareSayToFBClicked:(id)sender {
   // NSLog(@"btnShare : %ld", (long)[sender tag]);
    NSDictionary *currentSaysDict = [arrayFeed objectAtIndex:[sender tag]];
    NSArray *arrProfiles = [currentSaysDict objectForKey:@"profiles"];
    NSDictionary *dictProfile1 = [arrProfiles objectAtIndex:0];
    NSDictionary *dictProfile2 = [arrProfiles objectAtIndex:1];
    NSString *desc = [NSString stringWithFormat:@"%@ Said This About %@ on Yousay", [dictProfile1 objectForKey:@"name"] , [dictProfile2 objectForKey:@"name"]];
    if ([[dictProfile2 objectForKey:@"name"] isEqualToString:[[AppDelegate sharedDelegate].profileOwner Name]]) {
        desc = [NSString stringWithFormat:@"%@  Said This About Me on Yousay", [dictProfile2 objectForKey:@"name"]];
        profile = [[AppDelegate sharedDelegate].profileOwner UserID];
    }
    else if ([[dictProfile1 objectForKey:@"name"] isEqualToString:[[AppDelegate sharedDelegate].profileOwner Name]]){
        desc = [NSString stringWithFormat:@"I Said This About %@ on Yousay", [dictProfile2 objectForKey:@"name"]];
        profile = [dictProfile2 objectForKey:@"profile_id"];
    }
    else {
        profile = [dictProfile2 objectForKey:@"profile_id"];
    }
    [self requestGetSayImage:[currentSaysDict objectForKey:@"say_id"] withDescription:desc isFB:YES];
    
}

- (void)highlightProfileName1:(UIButton*)sender {
    NSDictionary *value = [arrayFeed objectAtIndex:[sender tag]];
    NSArray *arrayProfile = [value objectForKey:@"profiles"];
    NSDictionary *requestedProfile = [arrayProfile objectAtIndex:0];
    
    FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
    
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithString:cell.lblSaidAbout.text];
    NSString *name =  [requestedProfile objectForKey:@"name"];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor lightGrayColor]
                 range:NSMakeRange(0,name.length)];
    [cell.lblSaidAbout setAttributedText: text];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
    vc.isFriendProfile = YES;
    vc.isFromFeed = YES;
    vc.requestedID = [requestedProfile objectForKey:@"profile_id"];
    vc.colorDictionary = [AppDelegate sharedDelegate].colorDict;
    vc.profileModel = [AppDelegate sharedDelegate].profileOwner;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)highlightProfileName2:(UIButton*)sender {
    FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sender tag]]];
    [cell.lblSaidAbout2 setTextColor:[UIColor lightGrayColor]];
    [cell.lblSaidAbout2 setHighlighted:YES];
    
    NSDictionary *value = [arrayFeed objectAtIndex:[sender tag]];
    NSArray *arrayProfile = [value objectForKey:@"profiles"];
    NSDictionary *requestedProfile = [arrayProfile objectAtIndex:1];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
    vc.isFriendProfile = YES;
    vc.isFromFeed = YES;
    vc.requestedID = [requestedProfile objectForKey:@"profile_id"];
    vc.colorDictionary = [AppDelegate sharedDelegate].colorDict;
    vc.profileModel = [AppDelegate sharedDelegate].profileOwner;
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark LikeListDelegate
- (void) LikeListViewClosed:(NSString*)section {
    FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[section integerValue]]];
    CATransition *transition = [CATransition animation];
    transition.type =kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 0.5f;
    transition.delegate = self;
    [cell.viewLikeList.layer addAnimation:transition forKey:nil];
    [cell.viewLikeList setHidden:YES];
    [cell setTag:9999];
}


- (void) ListDismissedAfterClickProfile:(NSMutableDictionary*)data {
    if (data && !isLikeListReleased) {
        NSInteger section = [[data objectForKey:@"section"] integerValue];
        FeedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        [cell.viewLikeList setHidden:YES];
        [cell setTag:9999];
        isLikeListReleased = !isLikeListReleased;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
        vc.isFriendProfile = YES;
        vc.isFromFeed = YES;
        vc.requestedID = [data objectForKey:@"user_id"];
        vc.colorDictionary = [AppDelegate sharedDelegate].colorDict;
        [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    isAfterShareFB = YES;
    [self requestSayShared:sayShared];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    isAfterShareFB = YES;
    [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error!", nil) message:NSLocalizedString(@"There is an error while sharing! Please try Again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil]show];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    isAfterShareFB = YES;
}
@end
