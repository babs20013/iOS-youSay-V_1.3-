//
//  SearchViewController.m
//  youSay
//
//  Created by Baban on 04/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+Networking.h"
#import "SlideNavigationController.h"
#import "WhoLikeListTableViewCell.h"
#import "FriendModel.h"
#import "MainPageViewController.h"

#define kColorSearch [UIColor colorWithRed:42.0/255.0 green:180.0/255.0 blue:202.0/255.0 alpha:1.0]
#define kColorBG [UIColor colorWithRed:202.0/255.0 green:207.0/255.0 blue:211.0/255.0 alpha:1.0]

@interface SearchViewController (){
    NSMutableArray *arrayUser;
    BOOL isShowRecentSearch;
    BOOL isSearchingFB;
    BOOL isRequesting;
    CGFloat _currentKeyboardHeight;
}
@property (nonatomic, weak) IBOutlet UILabel *lblRecentSearch;
@property (strong, nonatomic) IQURLConnection *userSearchRequest;
@property (nonatomic, weak) IBOutlet UIButton *btnClear;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *btnViewConstraint;
@property (nonatomic, weak) IBOutlet UIButton *btnRightMenu;
@property (nonatomic, weak) IBOutlet UIView *viewButton;
@property (nonatomic, strong) IBOutlet UITextField * txtSearch;

@end

@implementation SearchViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewWillAppear:(BOOL)animated {
    // Fetch the devices from persistent data store
    if ([[AppDelegate sharedDelegate].profileOwner UserID]) {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Search"];
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K like %@",@"id", [[AppDelegate sharedDelegate].profileOwner UserID]];
        [fetchRequest setPredicate:predicateID];
        
        [AppDelegate sharedDelegate].arrRecentSeacrh = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"SearchUser";
    [self.tblView setDataSource:self];
    [self.tblView setDelegate:self];
    [self.txtSearch setDelegate:self];
    [self.txtSearch becomeFirstResponder];
    [_txtSearch addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];
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
    
    UIButton *clearTextButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 45)];
    [clearTextButton setImage:[UIImage imageNamed:@"ClearText"] forState:UIControlStateNormal];
    [clearTextButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [clearTextButton addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
    [self.txtSearch setRightView:clearTextButton];
    [self.txtSearch setClearButtonMode:UITextFieldViewModeNever];
    [self.txtSearch setRightViewMode:UITextFieldViewModeWhileEditing];
    
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Search your friends" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.txtSearch.attributedPlaceholder = str;
    
    self.tblView.layer.cornerRadius = 0.015 * self.tblView.bounds.size.width;
    self.tblView.layer.masksToBounds = YES;
    self.tblView.layer.borderWidth = 1;
    self.tblView.layer.borderColor = kColorBG.CGColor;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (isSearchingFB == YES) {
        return 60;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc]init];
    footerView.backgroundColor = kColorBG;
    if (isSearchingFB == YES) {
        MBProgressHUD *loading = [[MBProgressHUD alloc]initWithView:footerView];
        [loading setFrame:footerView.frame];
        [loading setBackgroundColor:[UIColor clearColor]];
        [loading setLabelText:@"Searching users"];
        [loading setLabelFont:[UIFont systemFontOfSize:12]];
        [loading setAlpha:0.5];
        [footerView addSubview:loading];
        [loading show:YES];
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isShowRecentSearch) {
        if ([[AppDelegate sharedDelegate].arrRecentSeacrh count] == 0) {
            [self.btnClear setHidden:YES];
        }
        else {
            [self.btnClear setHidden:NO];
        }
        return [[AppDelegate sharedDelegate].arrRecentSeacrh count];
    }
    return [arrayUser count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
    static NSString *cellIdentifier = @"WhoLikeListTableViewCell";
    WhoLikeListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (! cell) {
        
        cell = [[WhoLikeListTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    FriendModel *model;
    if (isShowRecentSearch == YES) {
        [self.lblRecentSearch setText:@"Recent Search"];
        NSManagedObject *recentSearch = [[AppDelegate sharedDelegate].arrRecentSeacrh objectAtIndex:indexPath.row];
        NSURL *image = [NSURL URLWithString:[recentSearch valueForKey:@"profileImage"]];
        if (image && [image scheme] && [image host]) {
            [cell.profileView setImageURL:image];
        }
        else {
            [cell.profileView setImageURL:[NSURL URLWithString:@"http://2.bp.blogspot.com/-6QyJDHjB5XE/Uscgo2DVBdI/AAAAAAAACS0/DFSFGLBK_fY/s1600/facebook-default-no-profile-pic.jpg"]];
        }
        
        cell.profileView.layer.cornerRadius = cell.profileView.frame.size.width/2;
        cell.profileView.layer.masksToBounds = YES;
        cell.profileView.layer.borderWidth = 1;
        cell.profileView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        
        [cell.profileName setText:[recentSearch valueForKey:@"name"]];
    }
    else {
        [self.lblRecentSearch setText:@"Profiles Found"];
        model = [arrayUser objectAtIndex:indexPath.row];
        [cell.profileView setImageURL:[NSURL URLWithString:model.ProfileImage]];
        cell.profileView.layer.cornerRadius = cell.profileView.frame.size.width/2;
        cell.profileView.layer.masksToBounds = YES;
        cell.profileView.layer.borderWidth = 1;
        cell.profileView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
        
        [cell.profileName setText:model.Name];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_userSearchRequest cancel];
    //--Add the profile to recent search
    if (![AppDelegate sharedDelegate].arrRecentSeacrh) {
        [AppDelegate sharedDelegate].arrRecentSeacrh = [[NSMutableArray alloc]init];
    }
    FriendModel *model;
    if (isShowRecentSearch == YES) {
        NSManagedObject *recentSearchClicked = [[AppDelegate sharedDelegate].arrRecentSeacrh objectAtIndex:indexPath.row];
        model = [[FriendModel alloc]init];
        model.Name = [recentSearchClicked valueForKey:@"name"];
        model.ProfileImage = [recentSearchClicked valueForKey:@"profileImage"];
        model.CoverImage = [recentSearchClicked valueForKey:@"coverImage"];
        model.userID = [recentSearchClicked valueForKey:@"userID"];
    }
    else {
        model = [arrayUser objectAtIndex:indexPath.row];
        if (model.isNeedProfile == NO) {
            [self convertModelToObject:model];
        }
        //[self convertModelToObject:model];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
    if (![model.userID isEqualToString:[[AppDelegate sharedDelegate] profileOwner].UserID]) {
    vc.isFriendProfile = YES;
    }
    vc.isFromFeed = YES;
    vc.friendModel = model;
    vc.requestedID = model.userID;
    vc.profileModel = [AppDelegate sharedDelegate].profileOwner;
    vc.colorDictionary = [AppDelegate sharedDelegate].colorDict;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [_btnClear setHidden:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text length]==0){
        [self.btnClear setHidden:NO];
        isShowRecentSearch = YES;
        [self.tblView reloadData];
    }
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField*)textField {
    HideLoader();
    [_userSearchRequest cancel];
    [textField becomeFirstResponder];
    self.btnViewConstraint.constant = 0;
    [self.viewButton needsUpdateConstraints];
    [self.btnRightMenu setHidden:YES];
    
    if ([textField.text length]==0){
        [self.btnClear setHidden:NO];
        isShowRecentSearch = YES;
        [self.tblView reloadData];
    }
    else {
        isShowRecentSearch = NO;
        [self.btnClear setHidden:YES];
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), queue, ^{
        if ([textField.text length]>2 && isRequesting == NO){
            isRequesting = YES;
            [self.btnClear setHidden:YES];
            arrayUser = nil;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                ShowLoader();
                [self requestUser:textField.text withSearchID:@""];
            }];
        }
    });
}

#pragma mark - Request
- (void)requestUser:(NSString*)searchString withSearchID:(NSString*)searchID {
    isRequesting = YES;
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_SEARCH_USER forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token] forKey:@"token"];
    [dictRequest setObject:searchString forKey:@"search_text"];
    [dictRequest setObject:AUTHORITY_TYPE_FB forKey:@"authority_type"];
    [dictRequest setObject:[FBSDKAccessToken currentAccessToken].tokenString forKey:@"authority_access_token"];
    [dictRequest setObject:searchID forKey:@"search_id"];
    
    
    _userSearchRequest =  [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        
        if (result)
        {
            HideLoader();
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                isSearchingFB = YES;
                if ([dictResult objectForKey:@"yousay_users"]) {
                    NSString *searchid = [dictResult objectForKey:@"search_id"];
                    [self requestUser:searchString withSearchID:searchid];
                    NSArray *tempArr = [dictResult objectForKey:@"yousay_users"];
                    for (int i = 0; i < tempArr.count; i++) {
                        NSDictionary *dict = [tempArr objectAtIndex:i];
                        FriendModel *model = [[FriendModel alloc]init];
                        model.Name = [dict objectForKey:@"name"];
                        model.ProfileImage = [dict objectForKey:@"image_url"];
                        model.userID = [dict objectForKey:@"user_id"];
                        model.isNeedProfile = NO;
                        if (arrayUser == nil) {
                            arrayUser = [[NSMutableArray alloc]init];
                        }
                        [arrayUser addObject:model];
                    }
                    [self.tblView reloadData];
                }
                else if ([dictResult objectForKey:@"facebook_users"]) {
                    isSearchingFB = NO;
                    isRequesting = NO;
                    NSArray *tempArr = [[dictResult objectForKey:@"facebook_users"] allObjects];
                    for (int i = 0; i < tempArr.count; i++) {
                        NSDictionary *dict = [tempArr objectAtIndex:i];
                        FriendModel *model = [[FriendModel alloc]init];
                        model.Name = [dict objectForKey:@"name"];
                        model.userID = [dict objectForKey:@"id"];
                        NSDictionary *dictPic = [[dict objectForKey:@"picture"] objectForKey:@"data"];
                        model.ProfileImage = [dictPic objectForKey:@"url"];
                        model.CoverImage = [[dict objectForKey:@"cover"] objectForKey:@"source"];
                        if (model.CoverImage == nil) {
                            model.CoverImage = DEFAULT_COVER_IMG;
                        }
                        if (model.ProfileImage == nil) {
                            model.ProfileImage = DEFAULT_PROFILE_IMG;
                        }
                        model.isNeedProfile = YES;
                        if (arrayUser == nil) {
                            arrayUser = [[NSMutableArray alloc]init];
                        }
                        [arrayUser addObject:model];
                    }
                    
                    if (arrayUser.count == 0) {
                        [self.lblRecentSearch setText:@"No Profiles Found"];
                    }
                    [self.tblView reloadData];
                    
                    [AppDelegate sharedDelegate].num_of_new_notifications = [[dictResult valueForKey:@"num_of_new_notifications"] integerValue];
                    
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:kNotificationUpdateNotification object:nil];
                }
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else if ([[dictResult valueForKey:@"rc"] integerValue] == 602) {
                [self requestUser:searchString withSearchID:searchID];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else if (error)
        {
            HideLoader();
            isRequesting = NO;
        }
        else{
            HideLoader();
            isRequesting = NO;
        }
    }];
}

#pragma mark Method

- (IBAction)btnClearSearchClicked:(id)sender {
    arrayUser= [[NSMutableArray alloc]init];
    NSManagedObjectContext *context = [self managedObjectContext];
    for (int i = 0; i < [[AppDelegate sharedDelegate].arrRecentSeacrh count]; i++) {
        [context deleteObject:[[AppDelegate sharedDelegate].arrRecentSeacrh objectAtIndex:i]];
    }
    [AppDelegate sharedDelegate].arrRecentSeacrh = [[NSMutableArray alloc]init];
    NSError *error = nil;
    if (![context save:&error]) {
       // NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    [context deletedObjects];
    
    [self.tblView reloadData];
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
          //  NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        [[AppDelegate sharedDelegate].arrRecentSeacrh insertObject:newSearch atIndex:0];
    }
}

- (IBAction)clearTextField:(id)sender {
    if ([self.txtSearch.text length] == 0) {
        [self.txtSearch resignFirstResponder];
        [self.btnRightMenu setHidden:NO];
        self.btnViewConstraint.constant = 38;
        [self.viewButton needsUpdateConstraints];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else {
        [self.txtSearch setText:@""];
        isShowRecentSearch = YES;
        [self.tblView reloadData];
    }
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

- (void)keyboardDidShow:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    _currentKeyboardHeight = keyboardFrameBeginRect.size.height;
    self.tableBottomConstraint.constant = _currentKeyboardHeight;
}

- (void)keyboardDidHide:(NSNotification*)notification {
    _currentKeyboardHeight = 0.0;
    self.tableBottomConstraint.constant = 10;
}

@end