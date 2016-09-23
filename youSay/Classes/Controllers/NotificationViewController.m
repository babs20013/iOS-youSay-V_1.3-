//
//  NotificationViewController.m
//  youSay
//
//  Created by Baban on 18/01/2016.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import "NotificationViewController.h"
#import "UIImageView+Networking.h"
#import "NotificationTableViewCell.h"
#import "CommonHelper.h"
#import "MainPageViewController.h"
#import "SearchViewController.h"

#define kColorSearch [UIColor colorWithRed:42.0/255.0 green:180.0/255.0 blue:202.0/255.0 alpha:1.0]

@interface NotificationViewController (){
    NSMutableArray *arrNotification;
    int index;
    BOOL isNoMoreNotification;
    BOOL isScrollBounce;
}
@property (nonatomic, strong) IBOutlet UITextField * txtSearch;
@end

@implementation NotificationViewController
@synthesize say_id;

- (void)viewDidLoad {
    [super viewDidLoad];
    arrNotification = [[NSMutableArray alloc]init];
    isNoMoreNotification = NO;
    self.screenName = @"Notification";
    isScrollBounce = YES;
    index = 1;
    self.tblView.layer.cornerRadius = 0.015 * self.tblView.bounds.size.width;
    self.tblView.layer.masksToBounds = YES;
    self.tblView.layer.borderWidth = 1;
    self.tblView.layer.borderColor = [UIColor clearColor].CGColor;
    
    [self.txtSearch setDelegate:self];
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

- (void)viewDidAppear:(BOOL)animated {
    ShowLoader();
    index = 1;
    [self requestGetNotification:[NSString stringWithFormat:@"%d", index]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [arrNotification objectAtIndex:indexPath.row];
    
    NSArray *arrProfile = [dict objectForKey:@"profiles"];
    NSDictionary *dictProfile;
    NSString *string;
    if (arrProfile && [arrProfile isKindOfClass:[NSArray class]] && arrProfile.count > 0) {
        dictProfile = [arrProfile objectAtIndex:0];
        string = [[NSString alloc]initWithString:[[dict objectForKey:@"message"] stringByReplacingOccurrencesOfString:@"%1" withString:[dictProfile objectForKey:@"name"]]];
        return 74;
    }
    else {
        string = [dict objectForKey:@"message"];
        CGSize expectedSize = [CommonHelper expectedSizeForString:string width:tableView.frame.size.width-40 font:[UIFont fontWithName:@"Arial" size:12] attributes:nil];
        if (expectedSize.height < 60) {
            return 50;
        }
        
        return expectedSize.height-10;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arrNotification ) {
        return [arrNotification count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
    static NSString *cellIdentifier = @"NotificationTableViewCell";
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (! cell) {
        
        cell = [[NotificationTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    NSDictionary *dict = [arrNotification objectAtIndex:indexPath.row];
    NSArray *arrProfile = [dict objectForKey:@"profiles"];
    NSDictionary *dictProfile;
    NSString *string;
    if (arrProfile && [arrProfile isKindOfClass:[NSArray class]] && arrProfile.count>0) {
        dictProfile = [arrProfile objectAtIndex:0];
        string = [[NSString alloc]initWithString:[[dict objectForKey:@"message"] stringByReplacingOccurrencesOfString:@"%1" withString:[dictProfile objectForKey:@"name"]]];
        if (string == nil){
            string = @"";
        }
    }
    else {
        string = [dict objectForKey:@"message"];
    }
    
    NSString *urlString = [dictProfile objectForKey:@"avatar"];
    
    [cell.profileView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    cell.notificationDesc.text = string;
    [cell.notificationDesc setFont:[UIFont fontWithName:@"Arial" size:12]];
    [cell.notificationDesc setTextColor:[UIColor darkGrayColor]];
    [cell.notificationDesc setNumberOfLines:0];
    
    cell.notificationDate.text = [dict objectForKey:@"time_ago"];
    [cell.notificationDate setFont:[UIFont fontWithName:@"Arial" size:10]];
    [cell.notificationDate setTextColor:[UIColor lightGrayColor]];
    
    [cell.btnAvatar setTag:indexPath.row];
    if (urlString.length == 0){
        [cell.profileView setHidden:YES];
        [cell.btnAvatar setHidden:YES];
        
        [cell.profileView setFrame:CGRectMake(13, 0, 0, 0)];
    }
    else {
        [cell.profileView setHidden:NO];
        [cell.btnAvatar setHidden:NO];
        [cell.profileView setFrame:CGRectMake(13, (cell.frame.size.height-45)/2 , 45, 45)];
    }
    
    [cell.profileView setImageURL:[NSURL URLWithString:urlString]];
    cell.profileView.layer.cornerRadius = cell.profileView.frame.size.width/2;
    cell.profileView.layer.masksToBounds = YES;
    cell.profileView.layer.borderWidth = 1;
    cell.profileView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [arrNotification objectAtIndex:indexPath.row];
    
    if ([[[dict valueForKey:@"type"] valueForKey:@"code"] integerValue] == 8) {
        FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
        content.appLinkURL = [NSURL URLWithString:@"http://yousayweb.com/yousay/profileshare.html"];
        content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://yousayweb.com/yousay/images/Invite_Friends.png"];
        [FBSDKAppInviteDialog showFromViewController:self.parentViewController withContent:content delegate:self];
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
    vc.isFromFeed = YES;
    vc.requestedID = [dict objectForKey:@"profile_id"];
    vc.sayID = [dict objectForKey:@"say_id"];
    vc.colorDictionary = [AppDelegate sharedDelegate].colorDict;
    vc.profileModel = [AppDelegate sharedDelegate].profileOwner;
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark Request

- (void)requestGetNotification:(NSString*)startFrom  {
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_GET_NOTIFICATION forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token] forKey:@"token"];
    [dictRequest setObject:@"yousay_ios" forKey:@"app_name"];
    [dictRequest setObject:@"1.0" forKey:@"app_version"];
    [dictRequest setObject:@"10" forKey:@"max_items"];
    [dictRequest setObject:startFrom forKey:@"start_from"];
    [dictRequest setObject:@"1" forKey:@"sort"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
//        NSString* path = [[NSBundle mainBundle] pathForResource:@"notification"
//                                                         ofType:@"txt"];
//        NSString* content = [NSString stringWithContentsOfFile:path
//                                                      encoding:NSUTF8StringEncoding
//                                                         error:NULL];
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        
        
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                index = index+10;
                isScrollBounce = YES;
                NSArray *arrResult = [dictResult objectForKey:@"items"];
                if (arrResult.count == 0) {
                    isNoMoreNotification = YES;
                }
                [arrNotification addObjectsFromArray:arrResult];
                [self.tblView reloadData];
                
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
                [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark Method

- (void)logout {
    FBSDKLoginManager *fb = [[FBSDKLoginManager alloc]init];
    [fb logOut];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"yousayuserid"];
   [defaults setObject:nil forKey:@"yousaytoken"];
    [AppDelegate sharedDelegate].ownerDict = nil;
    [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
}

- (IBAction)avatarClicked:(id)sender {
   // NSLog(@"AVATAR CLICKED");
    
    NSDictionary *dict = [arrNotification objectAtIndex:[sender tag]];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
    vc.isFromFeed = YES;
    NSArray *arrProfile = [dict objectForKey:@"profiles"];
    if (arrProfile && [arrProfile isKindOfClass:[NSArray class]]) {
        NSDictionary *dictProfile = [arrProfile objectAtIndex:0];
        vc.requestedID = [dictProfile objectForKey:@"profile_id"];
    }
    if (![vc.requestedID isEqualToString:[[AppDelegate sharedDelegate] profileOwner].UserID]) {
        vc.isFriendProfile = YES;
    }
    vc.sayID = [dict objectForKey:@"say_id"];
    vc.colorDictionary = [AppDelegate sharedDelegate].colorDict;
    vc.profileModel = [AppDelegate sharedDelegate].profileOwner;
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)btnOpenMenu:(UIButton*)sender{
    [[SlideNavigationController sharedInstance]openMenu:MenuRight withCompletion:nil];
}

#pragma mark -- App Invite Delegate

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {

}
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"YouSay" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:vc animated:NO];
    return NO;
}

#pragma mark - ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -50) isScrollBounce = YES;
    
    if (fabs(scrollView.contentOffset.y) < 1 && isScrollBounce) {
        isScrollBounce = NO;
        if (!isNoMoreNotification) {
            isScrollBounce = NO;
            [self requestGetNotification:[NSString stringWithFormat:@"%i", index]];
        }
        else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.opacity = 0.1;
            hud.color = [UIColor blackColor];
            hud.labelText = @"No more notification";
            hud.labelFont = [UIFont systemFontOfSize:12];
            hud.margin = 10.f;
            hud.yOffset = 10.f;
            hud.dimBackground = NO;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:1.0];
        }
    }
//    
//    
//    if(self.tblView.contentOffset.y >= (self.tblView.contentSize.height - self.tblView.bounds.size.height) && isScrollBounce) {
//        if (!isNoMoreNotification) {
//            isScrollBounce = NO;
//            [self requestGetNotification:[NSString stringWithFormat:@"%i", index]];
//        }
//    }
}


@end