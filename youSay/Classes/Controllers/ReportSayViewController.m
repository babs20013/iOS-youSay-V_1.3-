//
//  ReportSayViewController.m
//  youSay
//
//  Created by Baban on 06/01/2016.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import "ReportSayViewController.h"


@interface ReportSayViewController (){
    NSArray *arrReportList;
}
@end

@implementation ReportSayViewController
@synthesize say_id;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"Report";
    arrReportList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ReportList" ofType:@"plist"]];
    self.tableHeightConstraint.constant = arrReportList.count * 40;
    [self.tblView needsUpdateConstraints];
    self.tblView.layer.cornerRadius = 0.015 * self.tblView.bounds.size.width;
    self.tblView.layer.masksToBounds = YES;
    self.tblView.layer.borderWidth = 1;
    self.tblView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 40;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrReportList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
    static NSString *SimpleTableIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    
    if(cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: SimpleTableIdentifier];
    }
    cell.textLabel.text = [arrReportList objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self requestReportSay:indexPath.row];
}

#pragma mark Request

- (void)requestReportSay:(NSInteger)index {
    ShowLoader();
    
    NSMutableDictionary *dictRequest =  [[NSMutableDictionary alloc]init];
    [dictRequest setObject:REQUEST_REPORT_SAY forKey:@"request"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner UserID] forKey:@"user_id"];
    [dictRequest setObject:[[AppDelegate sharedDelegate].profileOwner token] forKey:@"token"];
    [dictRequest setObject:say_id forKey:@"say_id"];
    [dictRequest setObject:[NSNumber numberWithInteger:index+1] forKey:@"report_reason"];
    [dictRequest setObject:[arrReportList objectAtIndex:index] forKey:@"report_text"];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:dictRequest completionBlock:^(id result, NSError *error) {
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:MSG_REPORT_SENT delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self dismissViewControllerAnimated:YES completion:nil];
                
                NSMutableDictionary *event =
                [[GAIDictionaryBuilder createEventWithCategory:@"Action"
                                                        action:@"ReportSay"
                                                         label:@"ReportSay"
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

#pragma mark IBAction

- (IBAction)btnBackOrCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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


@end