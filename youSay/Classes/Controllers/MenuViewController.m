//
//  MenuViewController.m
//  youSay
//
//  Created by muthiafirdaus on 10/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "MenuViewController.h"
#import "SlideNavigationController.h"
#import "ShowWebVC.h"
#import "WhoLikeListTableViewCell.h"

#define kColorBlue [UIColor colorWithRed:44.0/255.0 green:161.0/255.0 blue:189.0/255.0 alpha:1.0]


@interface MenuViewController ()
{
    NSArray *arrayMenu;
    NSArray *arrayImage;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrayMenu = [[NSArray alloc]initWithObjects:@"Invite Friends", @"Contact Us",@"Privacy Policy",  @"About", @"Log Out",nil];
    UIImage *menu1 = [UIImage imageNamed:@"chatIcon"];
    UIImage *menu2 = [UIImage imageNamed:@"contactus"];
    UIImage *menu3 = [UIImage imageNamed:@"privacy"];
    UIImage *menu4 = [UIImage imageNamed:@"about"];
    UIImage *menu5 = [UIImage imageNamed:@"logout"];
    
    arrayImage = [[NSArray alloc]initWithObjects:menu1, menu2, menu3, menu4, menu5, nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableLeadingConstraint.constant =70;
    [SlideNavigationController sharedInstance].portraitSlideOffset = self.tableLeadingConstraint.constant+20;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITable View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrayMenu count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    cell.textLabel.frame = CGRectMake(70, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
    cell.textLabel.text = [arrayMenu objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:19.0]];
    if (indexPath.row == 0) {
        [cell.textLabel setTextColor:kColorBlue];
    }
    else {
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    }
    
    cell.imageView.image = [arrayImage objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) //InviteFriends
    {
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
            FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
            content.appLinkURL = [NSURL URLWithString:@"http://yousayweb.com/yousay/profileshare.html"];
            content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://yousayweb.com/yousay/images/Invite_Friends.png"];
            [FBSDKAppInviteDialog showFromViewController:self.parentViewController withContent:content delegate:self];
        }];
    }
    
    if (indexPath.row == 1) {
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
            ShowWebVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowWebVC"];
            //initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            [vc setUrl:@"http://yousayweb.com/yousay/profileshare.html#contactus"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [nav setNavigationBarHidden:YES];
            [[SlideNavigationController sharedInstance] presentViewController:nav animated:YES completion:nil];}];
        
    }
    else if (indexPath.row == 2){
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
            ShowWebVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowWebVC"];
            //initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            [vc setUrl:@"http://yousayweb.com/yousay/profileshare.html#privacypolicy"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [nav setNavigationBarHidden:YES];
            [[SlideNavigationController sharedInstance] presentViewController:nav animated:YES completion:nil];}];
    }
    
    else if (indexPath.row == 3) {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
            
          
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"YouSay" message:[NSString stringWithFormat: @" What's your rating?\n Version:%@",[NSString stringWithFormat:@"%@",version]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
    else if (indexPath.row == 4) {
        FBSDKLoginManager *fb = [[FBSDKLoginManager alloc]init];
        [fb logOut];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:@"yousayuserid"];
       [defaults setObject:nil forKey:@"yousaytoken"];
    [AppDelegate sharedDelegate].ownerDict = nil;
        [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
    }
    
}

#pragma mark - FBInviteDelegate
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"YouSay" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


@end
